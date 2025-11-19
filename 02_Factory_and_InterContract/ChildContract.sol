// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Child Contract (Deployable Unit)
 * @dev A simple contract designed to be deployed by a Factory. It can receive 
 * Ether and return its current balance.
 */
contract ChildContract{
    // Function to read the current Ether balance of this specific contract instance.
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    // Payable function: Allows the contract to receive Ether (Deposit).
    function deposit( ) public payable { // Renamed from 'deposite'
        // The Ether is sent to the contract's address implicitly.
    }
}
