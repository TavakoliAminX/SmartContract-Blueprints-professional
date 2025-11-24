// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title SimpleMultiSig
 * @dev A basic Multi-Signature Wallet requiring a minimum number of confirmations 
 * from owners before a transaction (Ether withdrawal) can be executed.
 */
contract SimpleMultiSig {
    // ------------------- State Variables and Events -------------------

    // Array of addresses that are owners of this wallet.
    address[] public owners;
    
    // Minimum number of confirmations required to execute a transaction.
    uint public required;
    
    // Total number of transactions submitted so far. Used for generating new IDs.
    uint public transactionCount;
    
    // Mapping for fast lookup: Address => Is Owner?
    mapping(address => bool) public isOwner;

    /**
     * @dev Structure defining the details of a transaction proposal.
     */
    struct Transaction {
        address destination;
        uint value;
        bytes data; // Used for calling external functions on other contracts (advanced)
        bool executed; // True if the transaction has been sent.
        uint numConfirmations; // Count of owner confirmations received.
    }
    
    // Mapping: Transaction ID => Transaction details.
    mapping(uint => Transaction) public transactions;
    
    // Nested Mapping: Transaction ID => Owner Address => Has Confirmed?
    mapping(uint => mapping(address => bool)) public isConfirmed;
    
    // --- Events ---
    
    event Confirmation(address indexed owner, uint indexed txId);
    event Revocation(address indexed owner, uint indexed txId);
    event Submission(uint indexed txId);
    event Execution(uint indexed txId);

    // ------------------- Constructor and Modifiers -------------------

    /**
     * @dev Constructor initializes the wallet with a list of owners and required confirmations.
     * @param _owners List of initial owners.
     * @param _required Minimum number of confirmations needed for execution.
     */
    constructor(address[] memory _owners, uint _required) {
        // --- Security Checks (as discussed) ---
        require(_required > 0, "Required confirmations must be > 0.");
        require(_owners.length > 0, "Owners list cannot be empty.");
        require(_required <= _owners.length, "Required cannot exceed total owners.");
        
        // Initialize state variables
        owners = _owners;
        required = _required;

        // Populate isOwner mapping and check for zero address
        for (uint i = 0; i < _owners.length; i++) {
            address ownerAddress = _owners[i];
            require(ownerAddress != address(0), "Owner cannot be zero address.");
            
            // Check for duplicate owners (Recommended for production, simple version checks zero address)
            require(isOwner[ownerAddress] == false, "Owner address is duplicated.");
            
            isOwner[ownerAddress] = true;
        }
    }

    /**
     * @dev Modifier to ensure only a valid owner can call the function.
     */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Caller is not an owner."); 
        _;
    }

    /**
     * @dev Ensures a transaction with the given ID exists.
     */
    modifier txExists(uint _txId) {
        require(_txId < transactionCount, "Transaction does not exist.");
        _;
    }

    /**
     * @dev Ensures a transaction has not been executed yet.
     */
    modifier notExecuted(uint _txId) {
        require(transactions[_txId].executed == false, "Transaction already executed.");
        _;
    }

    // Allows the wallet to receive Ether.
    receive() external payable {}

    // ------------------- Core Multi-Sig Functionality -------------------

    /**
     * @dev Creates a new transaction proposal. Owner who submits automatically confirms.
     * @param _destination Target address for the transfer.
     * @param _value Amount of Ether to send (in Wei).
     * @param _data Calldata for optional function call.
     * @return The ID of the newly created transaction.
     */
    function submitTransaction(address _destination, uint _value, bytes memory _data) 
        public 
        onlyOwner 
        returns (uint txId) 
    {
        // --- Checks ---
        require(_destination != address(0), "Destination cannot be zero address.");
        
        // --- Actions / Effects ---
        txId = transactionCount; 
        
        transactions[txId] = Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        });

        transactionCount++; // Increment for the NEXT transaction.

        emit Submission(txId);
        
        // Best Practice: The owner who submits should automatically confirm.
        confirmTransaction(txId);
    }
    
    /**
     * @dev Confirms an outstanding transaction.
     * @param _txId ID of the transaction to confirm.
     */
    function confirmTransaction(uint _txId) 
        public 
        onlyOwner 
        txExists(_txId) 
        notExecuted(_txId)
    {
        // --- Checks ---
        // 1. Check if the owner has already confirmed this transaction.
        require(isConfirmed[_txId][msg.sender] == false, "Transaction already confirmed by owner.");

        // --- Effects ---
        // 2. Register confirmation.
        isConfirmed[_txId][msg.sender] = true;
        
        // 3. Increment confirmation count.
        transactions[_txId].numConfirmations++;
        
        emit Confirmation(msg.sender, _txId);
    }

    /**
     * @dev Executes a transaction if it has reached the required number of confirmations.
     * Implements Checks-Effects-Interactions (CEI) pattern for security.
     * @param _txId ID of the transaction to execute.
     */
    function executeTransaction(uint _txId) 
        public 
        onlyOwner // Only owners can initiate execution
        txExists(_txId) 
        notExecuted(_txId) 
    {
        Transaction storage tx = transactions[_txId];
        
        // 1. Check: Must have the minimum required confirmations.
        require(tx.numConfirmations >= required, "Not enough confirmations.");

        // 2. Effect (Security): Mark as executed BEFORE sending funds (CEI Pattern).
        tx.executed = true; 

        // 3. Interaction: Send the funds/call the external contract.
        (bool success, ) = tx.destination.call{value: tx.value}(tx.data);
        
        // 4. Check: Revert if the transfer/call failed.
        require(success, "Transaction execution failed.");
        
        emit Execution(_txId);
    }
}
