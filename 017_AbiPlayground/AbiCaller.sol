// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AbiCaller {
    address public targetContract;      // Address of the contract to call
    bytes public lastReturnData;        // Stores the last return data from a call
    bool public lastSuccess;            // Stores whether the last call was successful

    // Events for tracking calls
    event CallExecuted(address target, bytes4 selector, bool success, bytes returnData);
    event CallFailed(address target, bytes4 selector, string reason);
    event Executed(bytes lastReturnData, bool success);

    // -----------------------------
    // Example: Call using abi.encodeWithSignature
    // - Encodes function name and arguments into payload
    // - Executes call with value
    // - Stores return data and success status
    // - Emits event and reverts if call fails
    // -----------------------------
    function callWithSignatureExample(string memory _note) public payable {
        bytes memory payload = abi.encodeWithSignature("receiverNote(string)", _note);
        (bool success, bytes memory returnData) = targetContract.call{value: msg.value}(payload);
        lastReturnData = returnData;
        lastSuccess = success;
        emit Executed(returnData, success);
        require(success, "callWithSignature failed");
    }

    // -----------------------------
    // Example: Call using abi.encodeWithSelector
    // - Computes selector from keccak256 of function signature
    // - Encodes selector with arguments into payload
    // - Executes call with value
    // - Stores return data and success status
    // - Emits event and reverts if call fails
    // -----------------------------
    function callWithSelectorExample(string memory _note) public payable {
        bytes4 selector = bytes4(keccak256(bytes("receiverNote(string)")));
        bytes memory payload = abi.encodeWithSelector(selector, _note);
        (bool success, bytes memory returnData) = targetContract.call{value: msg.value}(payload);
        lastReturnData = returnData;
        lastSuccess = success;
        emit Executed(returnData, success);
        require(success, "callWithSelector failed");
    }

    // -----------------------------
    // Example: abi.encodePacked usage
    // - Concatenates multiple values into a single bytes sequence
    // - Useful for hashing and unique identifiers
    // -----------------------------
    function encodePackedExample(string memory A, string memory B) public pure returns(bytes32){
        return keccak256(abi.encodePacked(A, B));
    }

    // -----------------------------
    // Example: encode & decode
    // - Encodes arguments for call
    // - Executes low-level call
    // - Decodes multiple return values (string and uint)
    // - Stores result in local variables
    // -----------------------------
    function encodeDecodeExample(string memory _note) public returns(string memory st, uint256 x){
        bytes memory payload = abi.encodeWithSignature("receiverNoteWithNumber(string)", _note);
        (bool success, bytes memory data) = targetContract.call(payload);
        require(success, "encodeDecodeExample call failed");
        (st, x) = abi.decode(data, (string, uint256));
    }

    // -----------------------------
    // Example: staticCall for view functions
    // - Does not change state
    // - Executes call to read data
    // - Decodes return value
    // -----------------------------
    function staticCallExample(address _user) public view returns(uint256 x){
        bytes memory payload = abi.encodeWithSignature("getBalance(address)", _user);
        (bool success, bytes memory data) = targetContract.staticcall(payload);
        require(success, "staticCall failed");
        x = abi.decode(data, (uint256));
    }
}
