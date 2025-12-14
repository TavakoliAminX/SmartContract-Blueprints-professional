// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MultiSigWallet
 * @author ---
 * @notice A simple multi-signature wallet implementation for learning purposes.
 * @dev This contract allows multiple owners to approve and execute transactions
 *      once a required number of approvals is reached.
 */
contract MultiSigWallet {
    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    /// @notice Emitted when ether is deposited into the wallet
    event Deposit(address indexed sender, uint256 value);

    /// @notice Emitted when a new transaction is submitted
    event Submit(uint256 indexed transactionId);

    /// @notice Emitted when an owner approves a transaction
    event Approve(address indexed owner, uint256 indexed transactionId);

    /// @notice Emitted when an owner revokes an approval
    event Revoke(address indexed owner, uint256 indexed transactionId);

    /// @notice Emitted when a transaction is executed
    event Execute(uint256 indexed transactionId);

    /* -------------------------------------------------------------------------- */
    /*                                   STORAGE                                  */
    /* -------------------------------------------------------------------------- */

    address[] public owners;                     // List of wallet owners
    mapping(address => bool) public isOwner;     // Owner lookup

    uint256 public required;                     // Required number of approvals

    struct Transaction {
        address to;                              // Target address
        uint256 value;                           // Ether value
        bytes data;                              // Call data
        bool executed;                           // Execution status
    }

    Transaction[] public transactions;           // List of transactions

    // transactionId => owner => approved
    mapping(uint256 => mapping(address => bool)) public approved;

    /* -------------------------------------------------------------------------- */
    /*                                 MODIFIERS                                  */
    /* -------------------------------------------------------------------------- */

    /// @dev Restricts function access to wallet owners only
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    /// @dev Ensures the transaction exists
    modifier txExists(uint256 transactionId) {
        require(transactionId < transactions.length, "tx does not exist");
        _;
    }

    /// @dev Ensures the transaction has not been executed
    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed, "tx already executed");
        _;
    }

    /// @dev Ensures the caller has not already approved the transaction
    modifier notApproved(uint256 transactionId) {
        require(!approved[transactionId][msg.sender], "tx already approved");
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                CONSTRUCTOR                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @param _owners List of wallet owners
     * @param _required Number of required approvals
     */
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid required number");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    /* -------------------------------------------------------------------------- */
    /*                              RECEIVE / FALLBACK                            */
    /* -------------------------------------------------------------------------- */

    /// @notice Allows the contract to receive ether
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /* -------------------------------------------------------------------------- */
    /*                             TRANSACTION LOGIC                              */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Submit a new transaction
     * @param to Target address
     * @param value Ether value
     * @param data Call data
     */
    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlyOwner {
        transactions.push(
            Transaction({
                to: to,
                value: value,
                data: data,
                executed: false
            })
        );

        emit Submit(transactions.length - 1);
    }

    /**
     * @notice Approve a transaction
     * @param transactionId Transaction index
     */
    function approveTransaction(uint256 transactionId)
        external
        onlyOwner
        txExists(transactionId)
        notExecuted(transactionId)
        notApproved(transactionId)
    {
        approved[transactionId][msg.sender] = true;
        emit Approve(msg.sender, transactionId);
    }

    /**
     * @notice Revoke a previously given approval
     * @param transactionId Transaction index
     */
    function revokeApproval(uint256 transactionId)
        external
        onlyOwner
        txExists(transactionId)
        notExecuted(transactionId)
    {
        require(approved[transactionId][msg.sender], "tx not approved");

        approved[transactionId][msg.sender] = false;
        emit Revoke(msg.sender, transactionId);
    }

    /**
     * @notice Execute a transaction once enough approvals are collected
     * @param transactionId Transaction index
     */
    function executeTransaction(uint256 transactionId)
        external
        onlyOwner
        txExists(transactionId)
        notExecuted(transactionId)
    {
        require(_getApprovalCount(transactionId) >= required, "not enough approvals");

        Transaction storage transaction = transactions[transactionId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit Execute(transactionId);
    }

    /* -------------------------------------------------------------------------- */
    /*                               VIEW FUNCTIONS                                */
    /* -------------------------------------------------------------------------- */

    /// @dev Returns number of approvals for a transaction
    function _getApprovalCount(uint256 transactionId)
        private
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < owners.length; i++) {
            if (approved[transactionId][owners[i]]) {
                count++;
            }
        }
    }
}
