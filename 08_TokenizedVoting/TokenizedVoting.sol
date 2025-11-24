// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title TokenizedVoting
 * @dev Implements a simple governance system where voting power is determined by token balance.
 * Users' voting power is equal to their token balance.
 */
contract TokenizedVoting{
    // The contract administrator, set upon deployment. Immutable saves gas and enhances security.
    address public immutable admin; 
    
    // --- State Variables ---

    // Token balances: determines the voting power of each address.
    mapping (address => uint) public balances; 

    struct Proposal{
        string description;
        uint forVotes;      // Sum of voting power (token balance) for 'Yes'
        uint againstVotes;  // Sum of voting power (token balance) for 'No'
        bool executed;      // Whether the proposal results have been acted upon (initially false)
        uint deadLine;      // The timestamp when voting ends
    }
    
    // Mapping: uint (Proposal ID) => Proposal (Details of the proposal)
    mapping (uint => Proposal) public Proposals;

    // Nested Mapping: uint (Proposal ID) => address (Voter) => bool (True if voted)
    mapping (uint => mapping (address => bool)) public hasVoted;
    
    // Counter for assigning unique IDs to new proposals. Starts from 1.
    uint private nextProposalId = 1;

    // --- Constructor and Modifiers ---
    
    constructor(){
        admin = msg.sender;
        // Allocate initial tokens (voting power) to the admin for distribution.
        balances[admin] = 10000;
    }

    /**
     * @dev Restricts function access to the contract administrator.
     */
    modifier onlyAdmin(){
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }
    
    // --- Events ---
    
    event ProposalCreated(uint indexed ID, string description, uint deadline);
    event Voted(address indexed voter, uint indexed ID, uint power);

    // --- Core Functions ---

    /**
     * @dev Allows the admin to transfer voting tokens to another address.
     * This distributes voting power across users.
     * @param _to The recipient address.
     * @param _amount The amount of tokens to transfer.
     */
    function transferToken(address _to, uint _amount) public onlyAdmin{
        // Check: Ensure the sender has enough tokens.
        require(balances[msg.sender] >= _amount, "Insufficient token balance."); 
        
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    /**
     * @dev Allows the admin to create a new voting proposal.
     * @param _description The brief description of the proposal.
     * @param _durationInHours The voting period duration in hours.
     * @return The ID of the newly created proposal.
     */
    function createProposal(string memory _description, uint _durationInHours) public onlyAdmin returns (uint) {
        // 1. Action: Get the next ID and increment the counter.
        uint newId = nextProposalId;
        nextProposalId++;
        
        // 2. Action: Calculate the deadline (current time + duration in seconds).
        uint deadlineTime = block.timestamp + (_durationInHours * 1 hours);

        // 3. Action: Store the new proposal struct in the mapping.
        Proposals[newId] = Proposal({
            description: _description,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            deadLine: deadlineTime
        });
        
        // 4. Effect: Emit event.
        emit ProposalCreated(newId, _description, deadlineTime);
        
        return newId;
    }

    /**
     * @dev Allows users with tokens to cast their vote (Yes/No).
     * Voting power is equal to the user's current token balance.
     * @param _proposalID The ID of the proposal being voted on.
     * @param _support True for Yes (ForVotes), False for No (AgainstVotes).
     */
    function vote(uint _proposalID, bool _support) public {
        // --- Checks ---
        
        // 1. Check: Voting period is still active.
        require(Proposals[_proposalID].deadLine > block.timestamp, "Voting period has ended.");
        
        // 2. Check: User has tokens (voting power).
        uint power = balances[msg.sender];
        require(power > 0, "Zero token balance, no voting power.");
        
        // 3. Check: User has not voted on this proposal yet.
        require(hasVoted[_proposalID][msg.sender] == false, "Already voted on this proposal.");

        // --- Actions / Effects ---
        
        // 4. Action: Add voting power based on support choice.
        if(_support) {
            Proposals[_proposalID].forVotes += power;
        } else {
            Proposals[_proposalID].againstVotes += power;
        }

        // 5. Effect: Mark the user as having voted.
        hasVoted[_proposalID][msg.sender] = true;
        
        // 6. Effect: Emit event.
        emit Voted(msg.sender, _proposalID, power);
    }
}
