// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// @title DataStorage
// @notice A simple contract designed to store a number and demonstrate struct usage.
// This contract is intended for dynamic deployment by a Factory contract.
contract DataStorage {
    uint public storedNumber; // Renamed for clarity.
    
    /// @dev Defines a structure to hold name components.
    struct Name {
        string firstName; // [Spelling Fix]: Corrected 'firsName' to 'firstName'.
        string lastName;
    }
    
    Name[] public namesArray; // Array of Name structs.
    
    /// @notice Stores a new unsigned integer value.
    /// @param _number The value to be stored in the contract.
    function store(uint _number) public { // [Spelling Fix]: Corrected 'stor' to 'store'.
        storedNumber = _number;
    }

    /// @notice Retrieves the currently stored number.
    /// @return The value of the storedNumber variable.
    function get() public view returns(uint) { 
        return storedNumber;
    }
}