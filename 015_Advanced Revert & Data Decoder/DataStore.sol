// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    This contract is a simple DataStore that:
    - Keeps a counter (increments every time setMessage is called)
    - Stores the last message sent by any caller
    - Includes a function that intentionally reverts to demonstrate error handling
*/

contract DataStore {

    // Counter that tracks how many times setMessage has been called
    uint public counter;

    // Stores the last message provided by a caller
    string public lastCallerMessage;

    /*
        setMessage:
        - Accepts a string input from the caller
        - Increments the counter by one
        - Saves the message to contract storage
        - Returns true to indicate successful execution
    */
    function setMessage(string memory _msg) external returns (bool) {
        counter++;                      // Increase the counter
        lastCallerMessage = _msg;       // Store the user's message
        return true;                    // Return success status
    }

    /*
        getMessage:
        - Returns the most recently stored message
        - Marked as view because it only reads data and does not modify state
    */
    function getMessage() external view returns (string memory) {
        return lastCallerMessage;
    }

    /*
        revertFunction:
        - Always reverts intentionally
        - Demonstrates how revert works and how errors are thrown
    */
    function revertFunction() external pure {
        revert("RevertERROR: Intentional");   // Throwing an intentional error
    }
}
