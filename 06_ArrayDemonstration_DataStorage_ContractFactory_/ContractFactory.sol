// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// [Import Fix]: Import statement updated to the corrected filename.
import "./DataStorage.sol";

// @title ContractFactory
// @notice Implements the Factory pattern to dynamically deploy and manage instances of the DataStorage contract.
contract ContractFactory {
    // Array to track the addresses of all DataStorage instances deployed by this contract.
    DataStorage[] public deployedInstances; // Renamed for clarity.

    /// @notice Deploys a new instance of the DataStorage contract.
    /// @dev The `new` keyword is used for dynamic contract deployment.
    function deployNewInstance() public { 
        // Dynamic deployment: Creates a new DataStorage contract on the blockchain.
        DataStorage newInstance = new DataStorage();
        // Stores the address of the newly deployed instance.
        deployedInstances.push(newInstance); 
    }

    /// @notice Stores a value in the 'storedNumber' variable of a specific deployed instance.
    /// @param _index The index of the deployed instance in the array.
    /// @param _number The value to be stored in the instance.
    function storeValueInInstance(uint _index, uint _number) public { 
        // Inter-contract call: Calls the store() function on the external contract instance.
        deployedInstances[_index].store(_number); 
    }

    /// @notice Retrieves the stored number from a specific deployed instance.
    /// @param _instanceIndex The index of the deployed instance in the array.
    /// @return storedValue The value retrieved from the instance's 'storedNumber'.
    function getValueFromInstance(uint _instanceIndex) public view returns(uint) {
        // Inter-contract call: Calls the get() function on the external contract instance.
        return deployedInstances[_instanceIndex].get();
    }
}