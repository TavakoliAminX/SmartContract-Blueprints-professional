// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    MasterCaller:
    - A contract designed to remotely interact with two external contracts:
        1. DataStore
        2. EtherReceiver

    - All interactions use low-level calls (call / staticcall)
      to demonstrate manual ABI encoding and decoding.

    - Functions:
        * callSetMessage      → calls DataStore.setMessage(string)
        * callGetMessage      → calls DataStore.getMessage()
        * callRevertFunction  → calls a function that intentionally reverts
        * callDepositEther    → sends Ether to EtherReceiver and calls depositAndVerify(address)
*/

contract MasterCaller {
    // Address of the EtherReceiver contract (must be payable to send Ether)
    address payable public etherReceiverAddress;

    // Address of the DataStore contract
    address public dataStoreAddress;

    /*
        Constructor:
        - Initializes the contract with addresses of EtherReceiver and DataStore contracts.
    */
    constructor(address payable _etherReceiverAddress, address _dataStoreAddress) {
        etherReceiverAddress = payable(_etherReceiverAddress);
        dataStoreAddress = _dataStoreAddress;
    }

    /*
        callSetMessage:
        - Encodes the function call for setMessage(string)
        - Uses low-level call to DataStore
        - Requires success
        - Decodes returned value (bool)
    */
    function callSetMessage(string memory _msg) public returns (bool remot) {
        bytes memory payload = abi.encodeWithSignature("setMessage(string)", _msg);
        (bool success, bytes memory data) = dataStoreAddress.call(payload);
        require(success, "DataStore.setMessage failed");
        remot = abi.decode(data, (bool));
    }

    /*
        callGetMessage:
        - Calls the view function getMessage() using staticcall
        - Requires success
        - Decodes returned string
    */
    function callGetMessage() public view returns (string memory remot) {
        bytes memory payload = abi.encodeWithSignature("getMessage()");
        (bool success, bytes memory data) = dataStoreAddress.staticcall(payload);
        require(success, "DataStore.getMessage failed");
        remot = abi.decode(data, (string));
    }

    /*
        callRevertFunction:
        - Calls a function that intentionally reverts
        - If the call fails, the revert message is decoded and returned
        - If the call unexpectedly succeeds, returns a fallback message
    */
    function callRevertFunction() public returns (string memory remot) {
        bytes memory payload = abi.encodeWithSignature("revertFunction()");
        (bool success, bytes memory data) = dataStoreAddress.call(payload);

        if (!success) {
            // Returned data is revert message ABI-encoded as bytes
            return abi.decode(data, (string));
        }

        return "Call succeeded unexpectedly (No revert occurred)";
    }

    /*
        callDepositEther:
        - Prepares the call for depositAndVerify(address)
        - Sends Ether using {value: _amountToSend}
        - Requires the call to succeed
    */
    function callDepositEther(uint _amountToSend) public {
        bytes memory payload = abi.encodeWithSignature("depositAndVerify(address)", address(this));
        (bool success, ) = etherReceiverAddress.call{value: _amountToSend}(payload);
        require(success, "EtherReceiver.depositAndVerify failed");
    }
}
