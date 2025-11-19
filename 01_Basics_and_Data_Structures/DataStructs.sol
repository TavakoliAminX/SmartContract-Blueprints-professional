// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Struct and Mapping Demonstration
 * @dev Shows how to define custom data types (Structs) and map them to unique IDs 
 * for inventory or registry tracking.
 */
contract ItemManager { // Renamed from Struct
    // Struct: A custom data type to group related variables for a single item.
    struct Item{
        string name;
        uint price; 
        address seller;
    }
    
    // Counter for assigning unique IDs to new items.
    uint public idCount; 
    
    // Mapping: Stores Item structs, accessible by a unique uint ID.
    mapping (uint => Item) public Items;

    // Function to add a new item to the inventory.
    function addItem(string memory _name , uint _price , address _seller) public { // Renamed from Add
        // 1. Create a new Item struct and assign it to the current ID.
        Items[idCount] = Item({
            name : _name,
            price : _price,
            seller: _seller
        });
        // 2. Increment the counter for the next item's ID.
        idCount++;
    }
}

contract AddressBook { // Renamed from Struct2
    // Struct: Renamed from 'Add' to 'Entry' for clarity.
    struct Entry{
        string name;
        uint price;
        address seller; 
    }
    // Mapping: Stores Entry structs, accessible by a unique uint ID.
    mapping (uint => Entry) public entries; // Renamed from 'adds'

    // Function to add a new entry using a specified ID.
    function addEntry(string memory _name , uint _price , address _seller , uint ID) public { // Renamed from 'addTo'
        entries[ID] = Entry({ 
            name : _name,
            price : _price,
            seller : _seller
        });
    }
}