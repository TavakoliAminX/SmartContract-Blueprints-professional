// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SenderHub is responsible for sending Ether to the VaultContract.
// It keeps track of the last sent note, amount, total sent Ether,
// and stores a history of all transactions per sender.
contract SenderHub {

    // Address of the VaultContract where Ether will be forwarded.
    address payable public VaultContracts;

    // State variables to track the last note and amount sent.
    string public lastSentNot;
    uint public lastSentAmount;

    // State variable to track the total Ether sent from this contract.
    uint public totalSent;

    // Event emitted when Ether is successfully forwarded to VaultContract.
    // 'indexed' allows filtering logs by sender.
    event EtherForwarded(
        address indexed sender, // Address of the sender
        uint amount,            // Amount of Ether forwarded
        string note             // Note/message sent with the Ether
    );

    // Constructor initializes the VaultContract address.
    constructor(address payable _VaultContracts){
        VaultContracts = payable(_VaultContracts);
    }

    // Struct to represent each transaction with details.
    struct Transaction {
        address to;      // Destination address (VaultContract)
        uint amount;     // Amount of Ether sent
        string note;     // Message sent with the transaction
        uint timestamp;  // Block timestamp when transaction occurred
    }

    // Mapping from sender address to an array of their transactions.
    // Allows storing the full history of transactions per sender.
    mapping (address => Transaction[]) public sentHistory;

    // Function to forward Ether to the VaultContract.
    // 'payable' allows this function to receive Ether.
    function forwardEther(string memory _note) public payable {
        require(msg.value > 0, "Must send some Ether");

        // Encode the function call to VaultContract with the note as parameter.
        bytes memory paylod = abi.encodeWithSignature("receiverETH(string)", _note);

        // Call the VaultContract with the Ether and encoded payload.
        (bool success, ) = VaultContracts.call{value: msg.value}(paylod);
        require(success, "Transfer failed");

        // Emit an event to log this transaction.
        emit EtherForwarded(msg.sender, msg.value, _note);

        // Optional: Could also push this transaction to sentHistory if needed.
        // sentHistory[msg.sender].push(Transaction(VaultContracts, msg.value, _note, block.timestamp));
    }

    // View function to get the current balance of the VaultContract.
    function getbalance() public view returns(uint remot){
        bytes memory paylod = abi.encodeWithSignature("getBalance()");
        (bool success, bytes memory data) = VaultContracts.staticcall(paylod);
        require(success, "Call failed");
        remot = abi.decode(data, (uint));
    }
}
