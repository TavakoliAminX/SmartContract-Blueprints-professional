// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;
import "./ChildContract.sol";

/**
 * @title Factory Pattern Implementation
 * @dev This contract (The Factory) deploys and manages instances of the ChildContract, 
 * demonstrating inter-contract communication and reference storage.
 */
contract ChildFactory{ // Renamed from MotherContract
    // Array to store the references (addresses) of all deployed ChildContract instances.
    ChildContract[] public deployedChildren; // Renamed from 'arryy'

    // Function to deploy a new ChildContract instance. (The Factory Method)
    function createChild() public { // Renamed from 'creator'
        ChildContract newChild = new ChildContract(); // Deploy new instance
        deployedChildren.push(newChild); // Store the reference
    }

    // Function to retrieve the contract reference by its index.
    function getChildAddress(uint _index) public view returns(ChildContract) { // Renamed from 'gerAdr'
        require(deployedChildren.length > _index, "Index out of bounds."); 
        return deployedChildren[_index]; 
    }

    // Function to read the Ether balance of a deployed child contract via external call.
    function getChildBalance(uint _index) public view returns(uint){ // Renamed from 'getBalance1'
        ChildContract setChild = deployedChildren[_index]; 
        return setChild.getBalance(); // Call the external function
    }

    // Function to call the payable deposit function on a deployed child contract.
    function depositToChild(uint _index ) public { // Renamed from 'deposite'
        ChildContract setChild = deployedChildren[_index];
        setChild.deposit(); 
    }
}