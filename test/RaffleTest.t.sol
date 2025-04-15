//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { Raffle } from "src/Raffle.sol";
import { DeployRaffle } from "script/DeployRaffle.s.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {

    HelperConfig helperConfig;
    Raffle raffle;
    address vrfCoordinator;
    uint256 entranceFee;
    uint256 interval;

    address public PLAYER = makeAddr("Player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerDeclared(address indexed player);

    function setUp() external{
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;

        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testRaffleInitializeInOpenState() view public {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRevertIfNotGiveEntranceFee() public {
        vm.expectRevert(Raffle.Raffle__PayMinimunEntranceFee.selector);
        raffle.enterRaffle();
    }

    function testPlayersArrayGetsUpadatedAfterEntering() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        assert(raffle.getNumberOfPlayers() == 1);
        assert(raffle.getPlayer(0) == PLAYER);
    }

    function testEventTriggeredWhenEntered() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testPlayerCannotEnterWhileCalculatingWinner() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        raffle.enterRaffle{value: entranceFee}();

    }

    modifier playerEntered {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testRequestIdEmitted() public playerEntered {

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 reqId = entries[1].topics[1];
        assert(uint256(reqId) > 0);

    }

    modifier onlyLocal {
        if(block.chainid != 31337) {
            return;
        }
        _;
    }

    function testE2E() public onlyLocal playerEntered {

        address expectedWinner = address(1);

        //add more players
        uint160 extraPlayers = 3;
        for(uint160 i=1;i<= extraPlayers;i++){
            address player = address(i);
            hoax(player, 2 ether);
            raffle.enterRaffle{value : entranceFee}();
        }

        uint256 beforeBalance = expectedWinner.balance;

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 reqId = entries[1].topics[1];

        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(reqId), address(raffle));

        uint256 afterBalance = raffle.getRecentWinner().balance;

        assertEq(expectedWinner, raffle.getRecentWinner());
        assertEq(beforeBalance + (4*entranceFee), afterBalance);
        assertEq(address(raffle).balance, 0);
        assertEq(uint256(raffle.getRaffleState()), 0);
        assertEq(raffle.getNumberOfPlayers(), 0);
    }
}