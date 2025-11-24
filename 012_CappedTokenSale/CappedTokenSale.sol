// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title CappedTokenSale
 * @dev A smart contract managing a token sale with a defined hard cap, 
 * price, and individual wallet limits.
 */
contract CappedTokenSale{
    address public immutable tokenOwner;
    bool public saleActive;
    
    // Constants (Hardcoded values for the sale)
    uint public constant TOKEN_PRICE = 5e18; 
    uint public constant HARD_CAP = 500 ether;
    uint public constant MAX_TOKENS_PER_WALLET = 10000;
    
    // State Variables
    uint public totalRaised;
    mapping (address => uint) public purchasedTokens;

    // Events
    event TokenPurchased(address indexed  buyer , uint amount , uint ethPaid);
    event FundsWithdrawn(uint amount , address indexed  to);

    // Constructor & Modifier
    constructor(bool _startSaleActive){
        tokenOwner = msg.sender;
        saleActive = _startSaleActive;
    }
    modifier onlyOwner(){
        require(msg.sender == tokenOwner);
        _;
    }

    /**
     * @dev Allows users to purchase tokens by sending Ether (ETH). 
     * Applies all token and cap restrictions.
     */
    function tokenBuyer() public payable {
        // Calculation must happen first to avoid redundant gas usage if checks fail
        uint tokensToBuy = msg.value / TOKEN_PRICE; 
        
        // --- Checks ---
        require(msg.value > 0);
        require(saleActive == true);
        require(purchasedTokens[msg.sender] + tokensToBuy <= MAX_TOKENS_PER_WALLET);
        require(totalRaised + msg.value <= HARD_CAP);
        
        // --- Effects ---
        purchasedTokens[msg.sender] += tokensToBuy;
        totalRaised += msg.value;
        
        // --- Event ---
        // Note: The parameters below are mapped directly to the event definition.
        emit TokenPurchased(msg.sender, msg.value , tokensToBuy);
    }
    
    /**
     * @dev Allows the token owner to securely withdraw all collected funds.
     */
    function withdrawFunds() public onlyOwner{
        (bool success, ) = payable(tokenOwner).call{value: address(this).balance}("");
        require(success);
    }
    
    /**
     * @dev Allows the owner to manually set the sale to inactive.
     */
    function saleactive() public onlyOwner{
        require(saleActive != false);
        saleActive= false;
    }
}
