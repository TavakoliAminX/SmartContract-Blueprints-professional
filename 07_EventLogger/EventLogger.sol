// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// @title EventLogger
// @notice A contract demonstrating the use of structs, mappings, and events to log user data.
// Events are crucial for enabling off-chain services (like block explorers or dApps) to track contract activity.
contract EventLogger {
    
    /// @dev Defines the structure for storing a person's details.
    struct Person { // [Correction]: Renamed 'People' to 'Person' for singular structure definition.
        string name;
        uint age;
    }
    
    /// @dev Event fired whenever new person data is created and stored.
    /// @param sender The address that initiated the creation (msg.sender).
    /// @param name The name of the person being logged.
    /// @param age The age of the person being logged.
    event UserDataLogged(address sender, string name, uint age); // [Correction]: Renamed Log1 to UserDataLogged.
    
    // Mapping that stores a Person struct associated with an address key.
    mapping (address => Person) public peopleMapping; // [Correction]: Renamed mappPeople to peopleMapping.
    
    /// @notice Creates a new Person record and stores it in the mapping, then emits an event.
    /// @dev The record is keyed by the transaction initiator's address (msg.sender).
    /// @param _name The name of the person.
    /// @param _age The age of the person.
    function createPerson(string memory _name, uint _age) public { // [Correction]: Renamed creat to createPerson.
        // Store the new Person struct in the mapping.
        peopleMapping[msg.sender] = Person({name: _name, age: _age});
        
        // Emit an event to notify off-chain listeners about the state change.
        emit UserDataLogged(msg.sender, _name, _age);
    }
}
