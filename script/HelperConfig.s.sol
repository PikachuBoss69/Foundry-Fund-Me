//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address pricefeed;
    }

    NetworkConfig public activeNetworkConfig;
    uint8 public constant decimal = 8; // 8 decimals for pricefeed
    int256 public constant input_price = 2000 * 10 ** 8; // // 2000 USD with 8 decimals
    //used these so we don't just randomly create a magic number

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepholiaEthConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getorcreateAnvilEthConfig();
        } else {
            revert("Network not supported");
        }
    }

    function getSepholiaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({pricefeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getorcreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.pricefeed != address(0)) {
            return activeNetworkConfig; // if the pricefeed is already set, return it
        }

        vm.startBroadcast();
        MockV3Aggregator mockpricefeed = new MockV3Aggregator(decimal, input_price); // 2000 USD with 8 decimals
        // 8 decimals means that the price is represented as 2000 * 10^8, which is 2000000000
        // This is the price of 1 ETH
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            pricefeed: address(mockpricefeed) // 2000 USD with 8 decimals
        });
        return anvilConfig;
    }
}
