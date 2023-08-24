// Interact with FUND ME Contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script , console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/fundme.sol";
contract Interaction is Script {
    uint constant PRICE_TO_SEND = 1e18;

    function fundContract(address fundmeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundmeAddress)).fund{value : PRICE_TO_SEND }();
        vm.stopBroadcast();
        console.log();
    }

    function run() public {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
             block.chainid
        );
        fundContract(mostRecentDeployed);
    }
}
