// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    This contract verifies that a given message was signed by a specific address.
    It demonstrates how to:
      1. Hash a message
      2. Prefix it with the standard Ethereum signed message header
      3. Recover the signer address using ecrecover
*/

contract PersonalSignatureVerifier {

    /*
        verifySignature:
        - Checks whether `_signed` actually signed `_message` using `_sig`.
        - Returns true if the recovered address matches `_signed`.
    */
    function verifySignature(address _signed, string memory _message, bytes memory _sig)
        public
        pure
        returns (bool)
    {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, _sig) == _signed;
    }

    /*
        getMessageHash:
        - Hashes the input message using keccak256.
    */
    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    /*
        getEthSignedMessageHash:
        - Produces the hash that Ethereum signs, which adds a prefix.
        - This prevents crafted signatures from being interpreted as signed transactions.
    */
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    /*
        recoverSigner:
        - Extracts r, s, v from the signature
        - Recovers the signer using ecrecover.
    */
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /*
        splitSignature:
        - Breaks the signature bytes into r, s, v components.
        - Signature must be 65 bytes long.
    */
    function splitSignature(bytes memory _sig)
        internal
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(_sig.length == 65, "Invalid signature length");

        assembly {
            // First 32 bytes store the length of the bytes array
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}
