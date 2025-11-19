// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Basic Data Interaction (Set and Get)
 * @dev Demonstrates how to initialize variables using a constructor and perform 
 * simple Create, Read, and Delete (CRUD) operations on mappings.
 */

contract SetContract {
    address public owner;
    // Mapping: Stores a string value associated with a user's address.
    mapping (address => string ) public userLists;

    // Constructor: Sets the initial contract owner upon deployment.
    constructor(address _owner){
        owner  = _owner; 
    }

    // Function to set (or update) a string value for a specific address.
    function setList(address _user, string memory _name) public {
        userLists[_user] = _name;
    }

    // Function to get (read) the string value associated with an address.
    function getList(address _user) public view returns(string memory){
        return userLists[_user];
    }
}


contract GetContract {
    // Mapping: Stores user data.
    mapping (address => string ) public userEntryList;

    // Function to set or update a string value.
    function setEntry(address _user, string memory _name) public {
        userEntryList[_user] = _name;
    }

    // Function to get a string value.
    function getEntry(address _user) public view returns(string memory){
        return userEntryList[_user];
    }

    // Function to delete (reset to empty) the value associated with an address.
    function deleteEntry(address _user) public {
        delete userEntryList [_user];
    }
}
