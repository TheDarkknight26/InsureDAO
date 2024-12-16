// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Governancetoken} from "./Governancetoken.sol"; 
import {DAOProposol} from "./DAOcontract.sol";

contract InsurancePool {
    
    IERC20 public governanceToken;
    Governancetoken public governancetoken; 
    DAOProposol public daoProposol; 

    struct User {
        string name;
        string occupation;
        uint256 contribution;
        string plan;
        bool exists;
    }

    mapping(address => User) public Userprofiles;
    uint256 private totalbalance = 0; 

    mapping(address => uint256) public individualcontribution; 

    event PremiumPaid(address indexed user, uint256 amount);
    event NewUser(address indexed user, string name);
    event ProposalCreated(uint256 proposolId, string description);
    event PayoutExecuted(address indexed user, uint256 amount);
    event TokensMinted(address indexed user, uint256 tokensMinted);


    constructor(
        address _governanceTokenAddress,
        address _daoProposolAddress,
        address _governanceTokenContract
    ) {
        governanceToken = IERC20(_governanceTokenAddress);
        daoProposol = DAOProposol(_daoProposolAddress); // Initialize DAO contract
        governancetoken = Governancetoken(_governanceTokenContract); // Initialize GovernanceToken contract
    }

    // Profile creation
    function ProfileCreation(
        string memory name,
        string memory occupation,
        string memory plan
    ) public {
        require(!Userprofiles[msg.sender].exists, "Profile already exists");

        Userprofiles[msg.sender] = User({
            name: name,
            occupation: occupation,
            contribution: 0, // Initial contribution will be 0
            plan: plan,
            exists: true
        });

        emit NewUser(msg.sender, name);
    }

    // Function to pay premium in Ether and mint tokens in proportion to the payment
    function payPremium() public payable {
        require(Userprofiles[msg.sender].exists, "User profile does not exist");
        require(msg.value > 0, "Payment should be greater than zero");

        uint256 tokenAmount = msg.value ; // Mint tokens based on Ether paid
        governancetoken.mint(msg.sender, tokenAmount); // Mint tokens for the user

        individualcontribution[msg.sender] += msg.value; // Add Ether contribution to the user
        totalbalance += msg.value; // Add Ether to the total balance

        emit PremiumPaid(msg.sender, msg.value);
        emit TokensMinted(msg.sender, tokenAmount); // Emit event for token minting
    }

    // Retrieve the total pool balance in Ether
    function getTotalPoolBalance() public view returns (uint256) {
        return totalbalance;
    }

    // This function will be triggered by DAOProposol when proposal is accepted
    function executePayout(address user, uint256 amount) external {
        // Only the DAO contract should be able to trigger payouts
        require(
            msg.sender == address(daoProposol),
            "Only DAOProposol contract can trigger payouts"
        );

        // Check if the pool has enough funds
        require(totalbalance >= amount, "Insufficient pool balance");

        // Perform the payout (Example: Payout to a predefined user or claim)
        // Transfer the requested amount from the pool to the user
        require(
            governanceToken.transfer(user, amount),
            "Payout transfer failed"
        );

        // Update the pool balance
        totalbalance -= amount;

        emit PayoutExecuted(user, amount); // Emit event for payout
    }
}
