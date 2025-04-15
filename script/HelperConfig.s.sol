//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract Constants {
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is Script, Constants {

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        uint256 subscriptionId;
        bytes32 keyHash;
        uint32 callbakGasLimit;
        address link;
        address account;
    }

    NetworkConfig public s_localNetworkConfig;

    function getConfig() public returns(NetworkConfig memory config) {
        if(block.chainid == ETH_SEPOLIA_CHAIN_ID){
            return getSepoliaNetworkConfig();
        }
        else if(block.chainid == LOCAL_CHAIN_ID){
            return getOrCreateLocalNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            subscriptionId: 58544976833894055441589549053257508418968130526932391503535122505656799447233,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbakGasLimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            account: 0x93f2d5444bd7736116F7D382BeC2444fCB58e550
        });
        return config;
    }

    function getOrCreateLocalNetworkConfig() public returns(NetworkConfig memory) {
        if(s_localNetworkConfig.vrfCoordinator != address(0)){
            return s_localNetworkConfig;
        }
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock mockVrfCoordinator = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UINT_LINK);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        s_localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(mockVrfCoordinator),
            subscriptionId: 0,
            //keyhash doesn't matter
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbakGasLimit: 500000,
            link: address(linkToken),
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        });
        return s_localNetworkConfig;
    }

    function run() external returns(NetworkConfig memory config) {
        return getConfig();
    }

    function setConfig(NetworkConfig memory config) public {
        s_localNetworkConfig = config;
    }
}