// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title An Election Contract
 * @author Vicor Mwania
 * @notice This is a contract for an election with proposals which can be voted for
 */

contract DVote {
    /**
     * Errors
     */
    error DVote_HasVoted();
    error DVote_ElectionHasNotStarted();
    error DVote_ElectionHasEnded();
    error DVote_ElectionHasNotEndedYet();

    /**
     * State Variables
     */
    struct Proposal {
        string name;
        int256 count;
    }

    struct Voter {
        bool hasVoted;
    }

    string public i_electionName;
    uint256 private i_electionStartTime;
    uint256 private i_electionEndTime;

    Proposal[] private s_proposals;
    Proposal public _winningProposal;

    mapping(address => Voter) voters;

    /**
     * Modifiers
     */
    modifier HasNotVoted() {
        if (voters[msg.sender].hasVoted == true) revert DVote_HasVoted();
        _;
    }

    modifier ElectionStart() {
        if (block.timestamp < i_electionStartTime) revert DVote_ElectionHasNotStarted();
        _;
    }

    modifier ElectionEnd() {
        if (block.timestamp > i_electionEndTime) revert DVote_ElectionHasEnded();
        _;
    }

    modifier ElectionHasEnded() {
        if (block.timestamp < i_electionEndTime) revert DVote_ElectionHasNotEndedYet();
        _;
    }

    /**
     * Events
     */
    event DVote_Voted(address indexed voter, uint256 proposalIndex);
    event DVote_VotesCalculated(address indexed user, string winninProposalName, int256 count);

    constructor(string memory electionName, string[] memory proposals, uint256 startTime, uint256 endTime) {
        i_electionName = electionName;
        i_electionStartTime = startTime;
        i_electionEndTime = endTime;
        for (uint256 i = 0; i < proposals.length; i++) {
            s_proposals.push(Proposal({name: proposals[i], count: 0}));
        }
    }

    /**
     * External Functions
     */

    /**
     * @param proposal proposal index in proposals array
     * This function allows users to vote for a proposal. It correctly checks whether the user has voted, whether the election has started, and whether the election has ended. This ensures proper voting behavior.
     */
    function voteForProposal(uint256 proposal) external HasNotVoted ElectionStart ElectionEnd {
        voters[msg.sender].hasVoted = true;
        s_proposals[proposal].count += 1;
        emit DVote_Voted(msg.sender, proposal);
    }

    /**
     * This function calculates the winning proposal after the election has ended. It correctly identifies the winning proposal and emits an event with the results
     * @dev "none" will be the default value of the winning proposal of none of the submited proposal recieves votes
     */
    function calcuateVotes() external ElectionHasEnded {
        _winningProposal = Proposal("none", 0);
        for (uint256 p = 0; p < s_proposals.length; p++) {
            if (s_proposals[p].count > _winningProposal.count) {
                _winningProposal = s_proposals[p];
            }
        }

        emit DVote_VotesCalculated(msg.sender, _winningProposal.name, _winningProposal.count);
    }

    /**
     * Getter Functions
     */

    function getElectionName() external view returns (string memory) {
        return i_electionName;
    }

    function getElectionStartTime() external view returns (uint256) {
        return i_electionStartTime;
    }

    function getElectionEndTime() external view returns (uint256) {
        return i_electionEndTime;
    }

    function getWinnerProposal() external view returns (string memory _winningProposalName) {
        return _winningProposal.name;
    }

    function getProposals() external view returns (Proposal[] memory) {
        return s_proposals;
    }
}
