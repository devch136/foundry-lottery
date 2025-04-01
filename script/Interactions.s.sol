//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription {

    function run() external {
        createSubscription();
    }

    function createSubscription() public returns(uint256){
        HelperConfig helperConfig = new HelperConfig();
        return VRFCoordinatorV2_5Mock(helperConfig.getConfig().vrfCoordinator).createSubscription();
    }
    
}