// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Secure Bank and Account Management
 * @dev Demonstrates mapping-based balance tracking, deposit/withdrawal logic, 
 * and inheritance with the 'super' keyword.
 */
contract Bank{
    // Mapping: Stores the Ether balance (in Wei) for each user address.
    mapping (address => uint) public balances; 

    // Payable function: Allows users to deposit funds.
    function deposit(uint _amount) public payable { // Corrected from 'deposite'
        balances[msg.sender] += _amount; 
    }
    
    // Function to handle withdrawal requests.
    function withdraw(uint _amount , uint _maxWithdrawLimit) public returns(bool) {
        // 1. Checks: Ensure sufficient balance and check the limit.
        require(balances[msg.sender] >= _amount, "Insufficient funds.");
        require(_amount <= _maxWithdrawLimit, "Exceeds max limit.");
        
        // 2. Effects: Deduct balance BEFORE external interaction (Security Best Practice).
        balances[msg.sender] -= _amount;
        
        // Note: For a complete system, a secure transfer (like 'call') must be executed here.
        return true; 
    }
}

contract CustomerAccount is Bank{ // Renamed from 'customer'
    uint public constant MAX_WITHDRAW_LIMIT = 10000; 
    
    // Function wrapper using super to call the parent's logic.
    function guardedWithdraw(uint _amount, uint _maxWithdrawLimit) public returns(bool){ // Renamed from 'withdraw1'
        // Calls the implementation in the immediate parent contract (Bank).
        super.withdraw(_amount,_maxWithdrawLimit); 
        return true;
    }
}