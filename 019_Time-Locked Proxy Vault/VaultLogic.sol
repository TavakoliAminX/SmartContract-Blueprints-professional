// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    --------------------------------------------------------------
    VaultLogic – Educational Version
    --------------------------------------------------------------
    This contract represents the logic/implementation layer of a
    vault system. It is designed to be used directly or as the
    implementation behind a proxy (e.g., via delegatecall).

    The contract includes:
    - Ownership control
    - A time-lock mechanism
    - Basic deposit/withdraw functionality
    - A selfdestruct-based emergency escape function

    Every function is explained in detail below for learners.
*/
contract VaultLogic {
    // ----------------------------------------------------------
    // Storage Variables
    // ----------------------------------------------------------

    // Address with full control over the contract.
    // In a proxy pattern, this variable must match the storage
    // layout of the proxy contract to avoid storage collisions.
    address public owner;

    // Timestamp until which the vault is locked.
    // Withdrawals cannot be made before this time.
    uint public lockTime;

    // This variable tracks the total balance the contract has handled.
    // (Note: It is not automatically used; learners can expand it.)
    uint public totalBalance;

    // ----------------------------------------------------------
    // Modifiers
    // ----------------------------------------------------------

    // Restricts access to only the owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Ensures the time-lock period has passed before executing
    // critical actions such as withdrawals.
    modifier TimeLockPassed() {
        require(block.timestamp >= lockTime, "Time lock still active");
        _;
    }

    // ----------------------------------------------------------
    // Initialization Function
    // ----------------------------------------------------------
    /*
        initialize()
        ----------------------------------------------------------
        This function is typically used when the logic contract is
        deployed behind a proxy. Because proxies do not run the
        constructor of the logic contract, initialization must be
        done manually.

        - Can only be executed once (owner == address(0))
        - Sets the initial owner
        - Sets the time-lock duration
    */
    function initialize(address _newOwner, uint _duration) public {
        require(owner == address(0), "Already initialized");
        owner = _newOwner;
        lockTime = block.timestamp + _duration;
    }

    // ----------------------------------------------------------
    // Deposit Function
    // ----------------------------------------------------------
    /*
        deposit()
        ----------------------------------------------------------
        Allows anyone to send ETH into the vault.

        Note:
        - The function is intentionally simple.
        - A payable function without logic is common in vaults.
        - totalBalance could be updated here if desired.
    */
    function deposite() public payable {}

    // ----------------------------------------------------------
    // Withdrawal Function
    // ----------------------------------------------------------
    /*
        withdraw(uint amount)
        ----------------------------------------------------------
        Allows the owner to withdraw ETH *only* after the time-lock
        period has expired.

        Checks performed:
        - Caller must be the owner
        - Time-lock must have passed
        - Contract balance must be sufficient

        The transfer uses .call{}("") which:
        - Forwards all remaining gas
        - Returns success / failure
        - Is the recommended low-level send method in Solidity 0.8+
    */
    function withdraw(uint _amount)
        public
        onlyOwner
        TimeLockPassed
    {
        require(address(this).balance >= _amount, "Insufficient balance");

        (bool success, ) = payable(owner).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    // ----------------------------------------------------------
    // Read-only Balance Function
    // ----------------------------------------------------------
    /*
        getBalance()
        ----------------------------------------------------------
        Returns the current ETH balance of the contract.
    */
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // ----------------------------------------------------------
    // Emergency Self-Destruct
    // ----------------------------------------------------------
    /*
        emergencyDestroy(address recipient)
        ----------------------------------------------------------
        Allows the owner to destroy the contract and send *all*
        contract balance to the specified address.

        Very important concepts for learners:
        -------------------------------------
        - selfdestruct removes all bytecode from the blockchain.
        - Any remaining ETH is forcibly transferred to the recipient.
        - If used behind a proxy (via delegatecall), the proxy contract
          itself would be destroyed, not this logic contract.

        This is intentionally dangerous and is included for teaching
        purposes around security and delegatecall risks.
    */
    function emergencyDestroy(address payable _recipient)
        public
        onlyOwner
    {
        selfdestruct(_recipient);
    }
}
