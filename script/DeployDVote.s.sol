//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DVote} from "../src/DVote.sol";

contract DeployDVote is Script {
    string public s_electionName;
    string[] public proposalNames;
    uint256 public startTime;
    uint256 public endTime;

    struct Proposal {
        string name;
        int256 count;
    }

    function run() external returns (DVote) {
        s_electionName = "2023 Community Development Projects";

        proposalNames = ["Renewable Energy Implementation", "Youth Education and Skill Development Program"];

        /**
         * @dev startTime defines when the election can started after one day or one hour or immedetialyy after deployment on the
         */
        startTime = block.timestamp + 1 minutes;
        endTime = block.timestamp + 3 hours;
        vm.startBroadcast();

        DVote dVote = new DVote(s_electionName, proposalNames, startTime, endTime);

        vm.stopBroadcast();

        return (dVote);
    }
}
