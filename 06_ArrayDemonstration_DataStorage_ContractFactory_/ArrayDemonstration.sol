// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// @title ArrayDemonstration
// @notice Contract to showcase operations on dynamic and fixed-size arrays in Solidity.
contract ArrayDemonstration {
    // A dynamic array. Elements can be added or removed.
    uint[] public dynamicArray;
    
    // A fixed-size array of 5 elements. Its length cannot be changed after deployment.
    uint[5] public fixedArray;

    /// @notice Adds a new element to the end of the dynamic array.
    /// @param _item The value to be pushed into the array.
    function pushItem(uint _item) public { 
        dynamicArray.push(_item); 
    }

    /// @notice Removes the last element from the dynamic array.
    /// @dev This operation requires at least one element to be present in the array.
    function popItem() public { 
        dynamicArray.pop();
    }

    /// @notice Returns the current length of the dynamic array.
    /// @return length The current size of the array.
    function getLength() public view returns(uint) {
        return dynamicArray.length; 
    }

    /// @notice Deletes an element at a specific index.
    /// @dev The `delete` keyword resets the value at the index to zero (or default), but does NOT reduce the array's length.
    /// @param _index The index of the element to delete.
    function removeItem(uint _index) public { 
        delete dynamicArray[_index]; 
    }

    /// @notice Demonstrates how to initialize an array in memory (not storage).
    function initializeMemoryArray() public {
        // [Syntax Fix]: Correct initialization of a memory array.
        // This array only exists for the duration of this function call.
        uint[] memory tempArray = new uint[](5); 
    }
}
