// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    EtherReceiver:
    - A simple contract designed to receive Ether.
    - When a user sends Ether through depositAndVerify, the contract:
        * Accepts the payment
        * Emits an event containing:
            - The address that actually sent the Ether (msg.sender)
            - The amount of Ether received (msg.value)
            - A user-provided address meant for verification or tagging
    - The contract also exposes a function to check its Ether balance.
*/

contract EtherReceiver {

    // Event emitted whenever Ether is deposited into the contract
    event DepositConfirmed(
        address indexed senderAddress,   // The actual sender calling the function
        uint amountReceived,             // The amount of Ether sent
        address indexed verifiedAddress  // An address provided by the sender for verification
    );

    /*
        depositAndVerify:
        - Marked payable so it can receive Ether.
        - Emits an event with:
            * msg.sender  -> who called the function
            * msg.value   -> how much Ether was sent
            * _sender     -> any address the caller wants to attach for identification
        - Ether stays stored inside the contract.
    */
    function depositAndVerify(address _sender) external payable {
        emit DepositConfirmed(msg.sender, msg.value, _sender);
    }

    /*
        getBalance:
        - Returns the total Ether stored in this contract.
        - Uses address(this).balance to read balance directly.
    */
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
