// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Proxy
 * @dev A simple proxy contract that forwards all calls to an implementation contract
 *      using delegatecall. It allows manual interactions with the implementation,
 *      including initialize, getBalance, and emergency destruction.
 * 
 *      This contract demonstrates key Solidity concepts:
 *      1. delegatecall (upgradeable proxy pattern)
 *      2. Fallback and receive functions for ETH handling
 *      3. Low-level function calls
 */
contract Proxy {
    // The owner of the contract (not automatically used in proxy)
    address public owner;

    // Price feed address (for the implementation)
    address public priceFeed;

    // Address of the logic/implementation contract
    address public implementation;

    /**
     * @dev Constructor sets the initial implementation contract
     * @param _implementation The address of the deployed logic contract
     */
    constructor(address _implementation) {
        implementation = _implementation;
    }

    /**
     * @dev Receive ETH directly
     */
    receive() external payable {
        _delegatecall();
    }

    /**
     * @dev Fallback function for all other calls
     */
    fallback() external payable {
        _delegatecall();
    }

    /**
     * @dev Internal function to forward calls to the implementation
     *      using delegatecall. Executes code in the context of this proxy.
     */
    function _delegatecall() internal {
        (bool success, bytes memory returnData) = implementation.delegatecall(msg.data);
        if (!success) {
            revert(string(returnData));
        }
    }

    /**
     * @dev Manually initialize the logic contract through delegatecall
     * @param _owner Owner address for the logic contract
     * @param _priceFeed Price feed address for the logic contract
     */
    function manualInitialize(address _owner, address _priceFeed) public {
        bytes memory payload = abi.encodeWithSignature(
            "initialize(address,address)",
            _owner,
            _priceFeed
        );
        (bool success, bytes memory returnData) = implementation.delegatecall(payload);
        if (!success) {
            revert(string(returnData));
        }
    }

    /**
     * @dev Manually call getBalance() on the logic contract
     * @return uint256 The ETH balance stored in the logic contract (proxy's storage)
     */
    function manualGetBalance() public returns (uint256) {
        // Prepare the function selector for getBalance()
        bytes4 selector = bytes4(keccak256(bytes("getBalance()")));
        bytes memory payload = abi.encodeWithSelector(selector);

        (bool success, bytes memory returnData) = implementation.delegatecall(payload);
        if (!success) {
            revert(string(returnData));
        }

        // Decode the returned data
        return abi.decode(returnData, (uint256));
    }

    /**
     * @dev Manually call emergencyDestroy() on the logic contract
     *      This will destroy the proxy contract and send ETH to the recipient
     * @param _recipient The address to receive all ETH upon destruction
     */
    function manualDestroyCall(address payable _recipient) public {
        bytes memory payload = abi.encodeWithSignature(
            "emergencyDestroy(address)",
            _recipient
        );
        (bool success, bytes memory returnData) = implementation.delegatecall(payload);
        if (!success) {
            revert(string(returnData));
        }
    }
}
