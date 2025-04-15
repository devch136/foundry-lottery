//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns(Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if(config.subscriptionId == 0){
            CreateSubscription createSub = new CreateSubscription();
            uint256 subId = createSub.createSubscription(config.vrfCoordinator, config.account);
            config.subscriptionId = subId;

            // fund
            FundSubscription fundSub = new FundSubscription();
            fundSub.fundSubscription(config.link, config.vrfCoordinator, config.account, subId);
        }

        helperConfig.setConfig(config);

        vm.startBroadcast(config.account);

        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.subscriptionId,
            config.keyHash,
            config.callbakGasLimit
        );

        vm.stopBroadcast();
        
        //add consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.account, config.subscriptionId);

        return (raffle, helperConfig);
    }
}