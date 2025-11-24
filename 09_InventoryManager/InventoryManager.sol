// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title InventoryManager
 * @dev A simple system to manage product inventory, allowing an admin to add products
 * and users to purchase them by sending the exact required Ether.
 */
contract InventoryManager{
    // ------------------- State Variables and Events -------------------
    
    // The contract administrator, set upon deployment.
    address public immutable admin;
    
    /**
     * @dev Structure defining a product's details.
     */
    struct Product{
        string name;
        uint price;  // Price in Wei
        uint stock;  // Quantity available
        bool isActive; // Flag if the product slot is in use
    }
    
    // Mapping: uint (Product ID) => Product (Product Details).
    mapping (uint => Product) public inventory;
    
    // Events for logging key actions.
    event StockUpdated(uint indexed ID, uint newStock);
    event ProductPurchased(address indexed buyer, uint indexed id, uint pricePaid);
    
    // ------------------- Constructor and Modifiers -------------------

    constructor(){
        admin = msg.sender;
    }

    /**
     * @dev Restricts function access to the contract administrator.
     */
    modifier onlyAdmin(){
        require(msg.sender == admin, "Admin only function.");
        _;
    }

    // ------------------- Core Functions -------------------

    /**
     * @dev Allows the admin to add a new product to the inventory.
     * @param _name The name of the product.
     * @param _initialStock The starting quantity of the product.
     * @param _productID The unique identifier for the product.
     * @param _price The selling price in Wei.
     */
    function addProduct(string memory _name, uint _initialStock, uint _productID, uint _price) public onlyAdmin{
        require(inventory[_productID].isActive == false, "Product ID already exists.");
        
        // Use storage reference to modify the mapping directly.
        Product storage newProduct = inventory[_productID];
        newProduct.name = _name;
        newProduct.price = _price;
        newProduct.stock = _initialStock;
        newProduct.isActive = true;
        
        emit StockUpdated(_productID, _initialStock);
    }

    /**
     * @dev Allows a user to purchase a product by sending the required Ether.
     * Implements the Checks-Effects-Interactions pattern for security.
     * @param _productID The ID of the product to purchase.
     */
    function purchaseProduct(uint _productID) public payable {
        // --- Checks ---
        require(inventory[_productID].isActive == true, "Product is not available.");
        require(inventory[_productID].stock > 0, "Product is out of stock."); // Ensures stock is positive
        require(msg.value == inventory[_productID].price, "Incorrect ETH amount sent.");
        
        // --- Effects (State Change) ---
        Product storage currentProduct = inventory[_productID];
        
        // Decrease stock BEFORE the external call to prevent Reentrancy attacks.
        currentProduct.stock--; 

        // --- Interactions (External Call) ---
        // Send payment to the contract admin.
        (bool success, ) = payable(admin).call{value: msg.value}("");
        require(success, "Payment transfer failed.");
        
        emit ProductPurchased(msg.sender, _productID, msg.value);
        emit StockUpdated(_productID, currentProduct.stock);
    }

    /**
     * @dev Allows the admin to withdraw any funds remaining in the contract.
     */
    function withdrawRemainingFunds() public onlyOwner{
        uint balance = address(this).balance;
        require(balance > 0, "No funds remaining to withdraw.");
        
        // Send all remaining funds to the admin using a low-level call.
        (bool success,) = payable(admin).call{value: balance}("");
        require(success, "ETH transfer failed.");
    }
}
