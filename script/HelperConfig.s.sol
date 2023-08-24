// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/ChainlinkPriceFeedMock.t.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getETHconfig();
        } else {
            activeNetworkConfig = getAnvilConfigorCreate();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepolia = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepolia;
    }

    function getETHconfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ETH = NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return ETH;
    }

    function getAnvilConfigorCreate() public returns (NetworkConfig memory) {
        //What if the contract is deployed
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //Price Feed
        vm.startBroadcast();
        MockV3Aggregator a = new MockV3Aggregator(8 , 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvil = NetworkConfig(address(a));
        return anvil;
    }
}
