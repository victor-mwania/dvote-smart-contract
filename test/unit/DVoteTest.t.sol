// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DeployDVote} from "../../script/DeployDVote.s.sol";
import {DVote} from "../../src/DVote.sol";

contract DVoteTest is StdCheats, Test {
    struct Proposal {
        string name;
        int256 count;
    }

    address public PLAYER = makeAddr("player");

    DVote dVote;

    function setUp() external {
        DeployDVote deployer = new DeployDVote();
        dVote = deployer.run();
    }

    function testCanVoteForProposal() public {
        vm.prank(PLAYER);
        vm.warp(block.timestamp);
        skip(3600);

        dVote.voteForProposal(0);
    }

    function testCannotVoteForProposalIfAlreadyVoted() public {
        vm.prank(PLAYER);
        vm.warp(block.timestamp);
        skip(3600);
        dVote.voteForProposal(0);

        vm.prank(PLAYER);
        vm.expectRevert(DVote.DVote_HasVoted.selector);
        dVote.voteForProposal(1);
    }

    function testCannotVoteWhenElectionHasNotStarted() public {
        vm.prank(PLAYER);
        vm.warp(block.timestamp);
        rewind(1);

        vm.expectRevert(DVote.DVote_ElectionHasNotStarted.selector);

        dVote.voteForProposal(0);
    }

    function testCannotVoteAfterElectionHasEnded() public {
        vm.prank(PLAYER);
        vm.warp(block.timestamp);
        skip(10900);

        vm.expectRevert(DVote.DVote_ElectionHasEnded.selector);

        dVote.voteForProposal(0);
    }

    function testCannotCalcuatedVotesBeforeElectionsHasEnded() public {
        vm.prank(PLAYER);
        vm.warp(block.timestamp);
        skip(3600);

        dVote.voteForProposal(0);

        vm.expectRevert(DVote.DVote_ElectionHasNotEndedYet.selector);

        vm.prank(PLAYER);
        dVote.calcuateVotes();
    }

    function testGetDefaultWinningProposalIfNoProposalIsVotedFor() public {
        vm.warp(block.timestamp);
        skip(10900);
        vm.prank(PLAYER);
        dVote.calcuateVotes();
        string memory _winninProposal = dVote.getWinnerProposal();

        assertEq(_winninProposal, "none");
    }

    function testGetsWinningProposalIfPropalGetMoreVotes() public {
        vm.prank(PLAYER);
        vm.warp(block.timestamp);
        skip(3600);

        dVote.voteForProposal(0);

        vm.warp(block.timestamp);
        skip(10900);
        vm.prank(PLAYER);
        dVote.calcuateVotes();
        string memory _winninProposal = dVote.getWinnerProposal();

        assertEq(_winninProposal, "Renewable Energy Implementation");
    }

    function testGetElectionName() public {
        string memory expectedElectionName = "2023 Community Development Projects";
        string memory electionName = dVote.getElectionName();

        assertEq(electionName, expectedElectionName);
    }

    function testGetElectionStartTime() public {
        uint256 expectedElectionStartTime = block.timestamp + 1 minutes;
        uint256 electionStartTime = dVote.getElectionStartTime();

        assertEq(electionStartTime, expectedElectionStartTime);
    }

    function testGetElectionEndTime() public {
        uint256 expectedElectionEndTime = block.timestamp + 3 hours;
        uint256 electionEndTime = dVote.getElectionEndTime();

        assertEq(electionEndTime, expectedElectionEndTime);
    }

    function testGetProposals() public {
        DVote.Proposal[] memory proposals = dVote.getProposals();

        assertEq(proposals.length, 2);
    }
}
