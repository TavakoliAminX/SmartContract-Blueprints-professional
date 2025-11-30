// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TransactionManager is responsible for managing and recording transactions
// between SenderHub contracts and the VaultContract.
// It keeps a complete history of transactions for each sender.
contract TransactionManager {

    // Address of the VaultContract where Ether is ultimately stored.
    address payable public VaultContracts;

    // Address of the SenderHub contract which initiates transactions.
    address payable public SenderHubs;

    // Counter to track the total number of transactions recorded.
    uint public transactionCount;

    // Event emitted when a transaction is successfully recorded.
    // 'indexed' allows filtering by sender and recipient in logs.
    event TransactionRecorded(
        address indexed from,  // Address initiating the transaction
        address indexed to,    // Destination address (VaultContract)
        uint amount,           // Amount of Ether sent
        string data            // Note or message sent with the transaction
    );

    // Constructor initializes the VaultContract and SenderHub addresses.
    // Sets the transactionCount to 0 initially.
    constructor(address payable _VaultContracts, address payable _SenderHubs){
        VaultContracts = payable(_VaultContracts);
        SenderHubs = payable(_SenderHubs);
        transactionCount = 0;
    }

    // Struct representing each transaction with details.
    struct TransAction {
        address to;      // Destination address (VaultContract)
        uint value;      // Amount of Ether sent
        string note;     // Message or note attached to the transaction
        uint timestamp;  // Time when transaction occurred (block.timestamp)
    }

    // Mapping from sender address to an array of their transactions.
    // This allows tracking the complete history of transactions per sender.
    mapping (address => TransAction[]) public history;

    // Function to record a new transaction.
    // It forwards Ether to VaultContract and stores transaction details.
    function recordTransaction(uint _amount, string memory _note) public payable {
        // Encode the function call to VaultContract with the note as parameter.
        bytes memory paylod = abi.encodeWithSignature("receiverETH(string)", _note);

        // Call the VaultContract and send the specified Ether amount.
        (bool success, ) = VaultContracts.call{value: _amount}(paylod);
        require(success, "Transfer failed"); // Ensure transaction succeeded

        // Record the transaction in the sender's history array.
        history[msg.sender].push(TransAction({
            to: VaultContracts,
            value: _amount,
            note: _note,
            timestamp: block.timestamp
        }));

        // Increment the global transaction counter.
        transactionCount++;

        // Emit an event to log this transaction on-chain.
        emit TransactionRecorded(msg.sender, VaultContracts, _amount, _note);
    }

    // View function to get the complete transaction history of a sender.
    function getSenderHistory(address _adr) public view returns(TransAction[] memory){
        return history[_adr];
    }

    // View function to get the current balance of the VaultContract.
    // Uses staticcall to call getBalance() in the VaultContract.
    function getVaultBalance() public view returns(uint256 remot){
        bytes memory paylod = abi.encodeWithSignature("getBalance()");
        (bool success, bytes memory data) = VaultContracts.staticcall(paylod);
        require(success, "Call failed");
        remot = abi.decode(data, (uint256));
    } 
}
