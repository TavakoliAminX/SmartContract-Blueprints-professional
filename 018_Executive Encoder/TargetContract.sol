// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TargetContract
 * @notice This contract is used as a demonstration target for ABI encoding techniques:
 *         - abi.encodeWithSignature
 *         - abi.encodeWithSelector
 *         - abi.encodeCall
 *
 *         Each function is intentionally simple so learners can clearly understand
 *         how calldata is generated and used when interacting with external contracts.
 */
contract TargetContract {
 
    // ------------------------------------------------------------
    // Storage variables (public for visibility during testing)
    // ------------------------------------------------------------
    uint256 public balance;              // Example numeric state variable
    address public admin;                // Example address state variable
    string public statusMessage;         // Example string (not used in functions)
    address[] public users;              // Example dynamic array of addresses
    uint256[] public userBalances;       // Corresponding balances for users
    string public name;                  // Example simple string variable


    // ------------------------------------------------------------
    // 1. Function for abi.encodeWithSignature
    // ------------------------------------------------------------
    /**
     * @notice Updates the 'name' variable.
     * @dev This function is intentionally simple.
     *      It is commonly used when demonstrating:
     *          abi.encodeWithSignature("updateName(string)", newName)
     * @param newName The new name value to be stored.
     */
    function updateName(string calldata newName) public {
        name = newName;
    }


    // ------------------------------------------------------------
    // 2. Function for abi.encodeWithSelector
    // ------------------------------------------------------------
    /**
     * @notice Sets the admin and balance values.
     * @dev Demonstrates how ABI encoding with function selector works:
     *      bytes4 selector = TargetContract.setAdminAndBalance.selector
     *      abi.encodeWithSelector(selector, admin, balance)
     * @param newAdmin Address to assign as the new admin.
     * @param newBalance Numeric balance value.
     */
    function setAdminAndBalance(address newAdmin, uint256 newBalance) public {
        admin = newAdmin;
        balance = newBalance;
    }


    // ------------------------------------------------------------
    // 3. Function for abi.encodeCall
    // ------------------------------------------------------------
    /**
     * @notice Adds a new user along with an initial balance.
     * @dev Demonstrates the safest and most modern method of ABI encoding:
     *      abi.encodeCall(TargetContract.addUserWithBalance, (user, amount))
     * @param newUser Address of the new user.
     * @param initialBalance Initial numeric balance for the user.
     */
    function addUserWithBalance(address newUser, uint256 initialBalance) public {
        users.push(newUser);
        userBalances.push(initialBalance);
    }

}
