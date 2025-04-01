//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { Raffle } from "src/Raffle.sol";
import { DeployRaffle } from "script/DeployRaffle.s.sol";
import { HelperConfig } from "script/HelperConfig.s.sol";


contract RaffleTest is Test {

    HelperConfig helperConfig;
    Raffle raffle;
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
}