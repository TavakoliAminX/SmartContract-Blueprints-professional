// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Dynamic Array and Loop Demonstration
 * @dev Shows how to initialize a dynamic array and calculate its sum using a for-loop.
 */
contract ArrayLoop{ // Renamed from Loop
    // Dynamic array to store numbers.
    uint[] public numbers; 

    // Constructor: Initializes the array with values passed during deployment.
    constructor(uint [] memory _numbers){ // Renamed _number to _numbers
        numbers = _numbers; 
    }

    // Function to calculate the sum of all elements in the 'numbers' array.
    function sumArray() public view returns(uint) { // Renamed from loopFor
        uint sum = 0;
        
        // Loop: Iterates through the array indices.
        for(uint i; i < numbers.length; i++){
            // Corrected: Sums the array value at the current index (numbers[i]).
            sum += numbers[i]; 
        } 
        return sum;
    }
}