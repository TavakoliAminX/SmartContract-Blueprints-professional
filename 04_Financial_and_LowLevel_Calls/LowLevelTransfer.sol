// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Low-Level Ether Transfer (Call) Demo
 * @dev Illustrates the use of the low-level 'call' function for secure Ether transfer, 
 * and how 'receive' functions handle incoming transactions.
 */
contract SenderContract{ // Renamed from 'sender'
    // receive: Allows the contract to receive raw Ether transfers (for funding).
    receive() external payable { } 
    
    // Function to send Ether back to the caller (withdrawal logic).
    function send(uint _amount) public {
        // Low-level call: Secure and recommended way to transfer Ether.
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        // Must check the success of the external call.
        require(success, "Transfer failed.");
    }
}

contract ReceiverContract{ // Renamed from 'receiver'
    // receive: Executed when Ether is sent to the contract without data.
    receive() external payable {
        // Logic: The contract immediately attempts to redirect all received Ether back to the caller.
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Redirection failed.");
     }
}
