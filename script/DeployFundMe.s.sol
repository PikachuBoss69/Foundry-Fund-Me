//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {FundMe} from "../src/FundMe.sol";

import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

    function run() external returns (FundMe) {
        // We can use the vm object to interact with the blockchain
        // vm is an instance of the Forge Std library   
        HelperConfig helperConfig = new HelperConfig();
        (address EthUsdprice) = helperConfig.activeNetworkConfig();/*because it's a struct, we can access the pricefeed address directly
        if there were more values on struct then we have to write as (address EthUsdprice, uint256 anotherValue) = helperConfig.activeNetworkConfig();
        */
        vm.startBroadcast();
        FundMe fundme = new FundMe(EthUsdprice);
        vm.stopBroadcast();
        return fundme;
    }

}