// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IDataVault
 * @notice Interface used for demonstrating abi.encodeCall.
 *         It exposes a single function that the proxy will trigger.
 */
interface IDataVault {
    function addUserWithBalance(address newUser, uint256 initialBalance) external;
}

/**
 * @title ExecutiveProxy
 * @notice This contract demonstrates three ABI-encoding techniques for making
 *         low-level calls to another contract:
 *
 *         1. abi.encodeWithSignature
 *         2. abi.encodeWithSelector
 *         3. abi.encodeCall
 *
 *         Each function performs the encoding manually, then sends a low-level
 *         call to the target contract.
 */
contract ExecutiveProxy {

    // ------------------------------------------------------------
    // Storage
    // ------------------------------------------------------------
    address public targetAddress;    // The external contract being called


    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------
    /**
     * @param _targetAddress Address of the target contract.
     */
    constructor(address _targetAddress) {
        targetAddress = _targetAddress;
    }


    // ------------------------------------------------------------
    // 1. abi.encodeWithSignature
    // ------------------------------------------------------------
    /**
     * @notice Calls updateName(string) on the target contract.
     * @dev Demonstrates ABI encoding using a function signature in string form.
     * @param newName The string argument to pass.
     */
    function executeSignatureUpdate(string memory newName) public {
        // Build calldata for: updateName(string)
        bytes memory payload =
            abi.encodeWithSignature("updateName(string)", newName);

        // Low-level call
        (bool success,) = targetAddress.call(payload);

        require(success, "Signature Call Failed");
    }


    // ------------------------------------------------------------
    // 2. abi.encodeWithSelector
    // ------------------------------------------------------------
    /**
     * @notice Calls setAdminAndBalance(address,uint256) on the target contract.
     * @dev Demonstrates manually building calldata using:
     *          - the function selector (first 4 bytes)
     *          - abi.encode for arguments
     *          - abi.encodePacked to combine them
     *
     * @param newAdmin Address to set as admin.
     * @param newBalance New balance value.
     */
    function executeSelectorUpdate(address newAdmin, uint256 newBalance) public {
        // Compute the function selector manually
        bytes4 selector =
            bytes4(keccak256("setAdminAndBalance(address,uint256)"));

        // Encode arguments
        bytes memory args = abi.encode(newAdmin, newBalance);

        // Combine selector + encoded args → full calldata
        bytes memory callData = abi.encodePacked(selector, args);

        // Low-level call
        (bool success,) = targetAddress.call(callData);

        require(success, "Selector Call Failed");
    }


    // ------------------------------------------------------------
    // 3. abi.encodeCall
    // ------------------------------------------------------------
    /**
     * @notice Calls addUserWithBalance(address,uint256) using abi.encodeCall.
     * @dev abi.encodeCall is the safest method because it derives the selector
     *      directly from the interface function reference.
     *
     * @param newUser Address of the new user.
     * @param initialBalance Balance to assign.
     */
    function executeCallUpdate(address newUser, uint256 initialBalance) public {
        IDataVault target = IDataVault(targetAddress);

        // Modern and safe calldata builder
        bytes memory payload =
            abi.encodeCall(target.addUserWithBalance, (newUser, initialBalance));

        // Low-level call
        (bool success,) = targetAddress.call(payload);

        require(success, "Call Encoding Failed");
    }
}
