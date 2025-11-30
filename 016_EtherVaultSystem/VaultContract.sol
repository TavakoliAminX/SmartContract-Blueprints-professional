// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// VaultContract is responsible for receiving and storing Ether securely.
// It also keeps track of the last message sent with Ether and the total amount received.
contract VaultContract {
    
    // State variable to store the latest note/message sent with Ether.
    string public lastNote;

    // State variable to track the total Ether received by this contract.
    uint public totalReceived;

    // Constructor runs only once when the contract is deployed.
    // Here we initialize totalReceived to 0.
    constructor() {
        totalReceived = 0;
    }

    // Event to log deposits. Events are stored in the blockchain logs
    // and can be listened to by off-chain applications.
    // 'indexed' allows filtering by sender when querying events.
    event Deposit(
        address indexed sender, // Address of the sender
        uint value,             // Amount of Ether received
        string note             // Message sent along with the Ether
    );

    // Main function to receive Ether and log a note.
    // 'payable' allows the contract to accept Ether.
    // Returns true as a confirmation.
    function receiverETH(string memory _note) public payable returns (bool) {
        lastNote = _note;            // Update the latest note
        totalReceived += msg.value;  // Update total received Ether
        emit Deposit(msg.sender, msg.value, _note); // Emit deposit event
        return true;                 // Return confirmation
    }

    // View function to check the current balance of the contract.
    // Uses 'address(this).balance' to get contract's Ether balance.
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
