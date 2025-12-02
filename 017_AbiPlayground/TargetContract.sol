// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TargetContract{
    // -----------------------------
    // Stores ether balance of each user
    // -----------------------------
    mapping (address => uint) public balances;

    // -----------------------------
    // Stores notes/messages for each user
    // -----------------------------
    mapping (address => string[]) public notes;

    // -----------------------------
    // Event emitted when ether + note is received
    // -----------------------------
    event NoteReceived(address indexed sender , uint value , string note);

    // -----------------------------
    // Function to receive ether and a note
    // - Updates balances and notes mapping
    // - Emits NoteReceived event
    // - Returns true on success
    // -----------------------------
    function receiver(string memory _note) public payable returns(bool){
        balances[msg.sender] += msg.value;
        notes[msg.sender].push(_note);
        emit NoteReceived(msg.sender, msg.value, _note);
        return true;
    }

    // -----------------------------
    // View function to get balance of a user
    // -----------------------------
    function getBalance(address _user) public view returns(uint){
        return balances[_user];
    }

    // -----------------------------
    // Pure function to compute keccak256 hash
    // - Demonstrates abi.encodePacked usage
    // -----------------------------
    function computeHash(string memory _A , string memory _B) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_A,_B));
    }

    // -----------------------------
    // Returns two values:
    // 1. number of notes for msg.sender
    // 2. the last note (or empty string if none)
    // - Useful for testing abi.decode with multiple return values
    // -----------------------------
    function complexReturn() public view returns(uint ,string memory){
        uint count =  notes[msg.sender].length;
        string memory lastNote = count > 0 ? notes[msg.sender][count - 1] : "";
        return (count,lastNote);
    }
}
