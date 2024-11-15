//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {console, Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address lastDeployed) public {
        vm.startBroadcast();
        FundMe(payable(lastDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded fundme with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentContractAddress = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentContractAddress);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawFundMe(address lastDeployed) public {
        vm.startBroadcast();
        FundMe(payable(lastDeployed)).withdraw();
        vm.stopBroadcast();
        // console.log("Funded fundme with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentContractAddress = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentContractAddress);
    }
}
 