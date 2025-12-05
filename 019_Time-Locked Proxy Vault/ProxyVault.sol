// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    --------------------------------------------------------------
    ProxyVault – Educational Version
    --------------------------------------------------------------

    This contract acts as a **minimal, transparent delegatecall proxy**.
    It forwards *all* incoming calls to an external implementation
    contract, while storing the actual state variables locally.

    Key concepts this contract demonstrates:
    ----------------------------------------
    1. **delegatecall** execution
       - The implementation contract's code is executed
         but storage is written inside the Proxy.

    2. **Proxy storage layout**
       - Storage variables must match the implementation contract
         (VaultLogic) to avoid corruption.

    3. **Selfdestruct through delegatecall**
       - If the implementation contains a `selfdestruct()`,
         calling it through delegatecall will destroy the Proxy,
         not the implementation.

    4. **Manually constructed function calls**
       - The proxy includes helper utilities to encode selectors
         and to manually trigger destructive functions.

    This file is ideal for teaching:
    - Upgradeable contracts
    - Delegatecall security pitfalls
    - Proxy design patterns
*/
contract ProxyVault {

    // ----------------------------------------------------------
    // Storage Variables
    // ----------------------------------------------------------

    /*
        The proxy must store the exact same variables in the exact
        same order as the implementation contract (VaultLogic).

        Reason:
        delegatecall uses the storage of the caller (the proxy).
        If the layout differs, the implementation will read/write
        incorrect storage slots.
    */
    address public owner;
    uint public lockTime;
    uint public totalBalance;

    // Address of the implementation (logic) contract.
    address public implementation;

    // ----------------------------------------------------------
    // Constructor
    // ----------------------------------------------------------

    /*
        The constructor sets the initial implementation contract.

        Note:
        Proxy constructors run normally, but the implementation's
        constructor does NOT run when using delegatecall. That is
        why the logic contract uses an initialize() function.
    */
    constructor(address _implementation) {
        implementation = _implementation;
    }

    // ----------------------------------------------------------
    // Fallback & Receive
    // ----------------------------------------------------------

    /*
        receive() – triggered when the proxy receives ETH without data.
        fallback() – triggered when the proxy receives a call that
                      does not match any function selector.

        Both forward execution to the implementation through delegatecall.
    */
    receive() external payable {
        _delegatecall();
    }

    fallback() external payable {
        _delegatecall();
    }

    // ----------------------------------------------------------
    // Internal delegatecall Function
    // ----------------------------------------------------------

    /*
        _delegatecall()

        This function performs the core proxy behavior:

        - Executes the implementation's code using delegatecall.
        - msg.data is passed directly to the implementation.
        - Return data is bubbled up.
        - Reverts correctly with the actual error message.

        This pattern is similar to how Transparent and UUPS proxies
        propagate errors.
    */
    function _delegatecall() internal {
        (bool success, bytes memory returnData) =
            implementation.delegatecall(msg.data);

        if (!success) {
            // Bubble up the revert reason from the implementation
            revert(string(returnData));
        }
    }

    // ----------------------------------------------------------
    // Utility Functions
    // ----------------------------------------------------------

    /*
        getWithdrawSelector()

        Returns the function selector for:
        withdraw(uint256)

        Purpose:
        - Helps developers understand how function selectors work.
        - Can be used in crafting low-level delegatecall payloads.

        Function selector = first 4 bytes of keccak256(function signature)
    */
    function getWithdrawSelector() public pure returns (bytes4) {
        return bytes4(keccak256(bytes("withdraw(uint256)")));
    }

    /*
        manualDestroyCall()

        Manually triggers the emergencyDestroy(address) function
        from the implementation contract via delegatecall.

        Critical learning point:
        ------------------------
        If `emergencyDestroy()` uses selfdestruct, calling it through
        delegatecall will destroy *this proxy contract* and send its
        entire balance to the recipient — NOT the implementation.

        This function is intentionally dangerous and included
        for educational demonstration of delegatecall risks.
    */
    function manualDestroyCall(address payable _recipient) public {
        // Build the function call payload manually
        bytes memory payload =
            abi.encodeWithSignature("emergencyDestroy(address)", _recipient);

        (bool success, bytes memory returnData) =
            implementation.delegatecall(payload);

        if (!success) {
            // Propagate the error message
            revert(string(returnData));
        }
    }
}
