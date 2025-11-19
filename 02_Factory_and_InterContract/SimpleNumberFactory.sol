// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
import "./NumberContract.sol"; 

/**
 * @title Simple Number Factory
 * @dev Deploys instances of NumberContract with a set initial number and retrieves the stored value.
 */
contract NumberFactory{ // Renamed from Contract A
    // Array to store the references of deployed contracts.
    NumberContract[] public contracts; 

    // Function to deploy a new contract instance.
    function deploy(uint _number) public { // Renamed from 'depoly' (fixed typo)
        NumberContract newContract = new NumberContract(_number); 
        contracts.push(newContract); 
    }
    
    // Function to call the getter on a deployed contract.
    function getNumber(uint _index) public view returns(uint){
        return contracts[_index].getNumber();
    }
}

contract NumberContract{ // Renamed from Contract B
    uint public number; 
    
    // Constructor: Initializes the 'number' state variable upon deployment.
    constructor(uint _number) {
        number = _number; 
    }
    
    // Getter function for the stored number.
    function getNumber() public view returns(uint){
        return number;
    }
}