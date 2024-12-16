// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {InsurancePool} from "./Insurancepool.sol";  // Import the InsurancePool contract

contract DAOProposol {
    IERC20 public governanceToken;
    InsurancePool public insurancePool;  // Declare InsurancePool contract

    struct Proposol {
        string description;
        uint256 votefor;
        uint256 voteagainst;
        bool executed;
        uint256 amount;  // Amount requested in the proposal
        uint256 creationTime; // Time when the proposal was created
    }

    event ProposolCreated(uint256 proposolId, string description);
    event Voted(uint256 proposolId, bool _vote, address person);
    event ProposolExecuted(uint256 proposolId);

    Proposol[] public proposol;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    constructor(address _tokenaddress, address _insurancePool) {
        governanceToken = IERC20(_tokenaddress);
        insurancePool = InsurancePool(_insurancePool);  // Initialize InsurancePool contract
    }

    function createProposol(string memory description, uint256 amount) external {
        proposol.push(
            Proposol({
                description: description,
                votefor: 0,
                voteagainst: 0,
                executed: false,
                amount: amount,  // Store the requested amount
                creationTime: block.timestamp
            })
        );
        emit ProposolCreated(proposol.length - 1, description);
    }

    function Vote(uint256 proposolId, bool _vote) external {
        require(
            governanceToken.balanceOf(msg.sender) > 0,
            "You must hold tokens to vote for the proposal"
        );

        Proposol storage proposalnew = proposol[proposolId];
        require(
            block.timestamp <= proposalnew.creationTime + 5 days,
            "Voting period has ended"
        );
        require(
            !hasVoted[proposolId][msg.sender],
            "You have already voted for this proposal"
        );

        if (_vote) {
            proposalnew.votefor += governanceToken.balanceOf(msg.sender);
        } else {
            proposalnew.voteagainst += governanceToken.balanceOf(msg.sender);
        }

        hasVoted[proposolId][msg.sender] = true;

        emit Voted(proposolId, _vote, msg.sender);
    }

    function executeProposol(uint256 proposolId) external {
        Proposol storage proposalnew = proposol[proposolId];
        require(proposalnew.executed == false, "Proposal is already executed");
        require(
            proposalnew.voteagainst < proposalnew.votefor,
            "Proposal is rejected"
        );
        require(
            block.timestamp <= proposalnew.creationTime + 5 days,
            "Proposal execution period has ended"
        );

        proposalnew.executed = true;

        // Trigger payout directly to the InsurancePool contract
        if (proposalnew.voteagainst < proposalnew.votefor) {
            // Call InsurancePool's executePayout function directly
            insurancePool.executePayout(msg.sender, proposalnew.amount);
        }

        emit ProposolExecuted(proposolId);
    }
}
