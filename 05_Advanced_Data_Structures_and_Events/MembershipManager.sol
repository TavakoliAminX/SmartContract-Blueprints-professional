// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Membership and Price-Tiers Manager
 * @dev A contract that manages user memberships based on Ether sent,
 * demonstrating advanced data structures (Enums, Nested Mappings), Events, 
 * and secure withdrawal using the low-level 'call' method. (All Oracle logic removed)
 */
contract MembershipManager{ // Renamed from membershipPurchase
    address public owner;
    address[] public buyer; // Array to store addresses of buyers/donors
    event LogDeposit(address sender , uint value); // Logs raw deposits (Renamed from Log1)
    event LogPurchase(address indexed  sender , string name , uint value); // Logs membership purchase
    
    // Enum: Custom type for membership tiers. (Fixed spelling 'silvaer' to 'silver')
    enum Price{
        gold,
        silver, 
        basic
    }
    
    // Nested Mapping: Maps Address -> Membership Name -> Price Tier.
    mapping (address => mapping (string => Price)) public userMembership;
    // Mapping to store simple donation amounts. (Renamed from mappOfDonats)
    mapping (address => uint) public donationMap; 
    
    constructor(){
        owner = msg.sender; // Sets the deployer as the owner
    }
    
    // Modifier: Restricts function execution to the contract owner. (Fixed spelling 'onlyOnwe')
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this.");
        _;
    }

    // Function to handle membership purchase based on sent Ether (msg.value).
    function purchase(string memory _name ) public payable {
        Price fee;
        
        // Conditional logic to assign membership tier based on payment amount.
        if(msg.value == 1e18){ // 1 Ether = Basic
           fee = Price.basic; 
        }else if(msg.value == 2e18){ // 2 Ether = Silver
            fee = Price.silver;
        }else{ // Other amounts (e.g., 3e18 or more) = Gold
            fee = Price.gold;
        }
        
        // Update the nested mapping with the new membership tier.
        userMembership[msg.sender][_name] = fee;
        
        // Emit an event to log the transaction for off-chain services.
        emit LogPurchase(msg.sender, _name, msg.value);
    }

    // Getter function to retrieve a user's membership tier.
    function getMembershipTier(address _adr , string memory _name) public view returns(Price ) { // Renamed from getAdr
        return userMembership[_adr][_name]; 
    }
    
    // Function to securely withdraw all funds from the contract to the owner.
    function withdraw() public onlyOwner{ 
        uint balance = address(this).balance;
        // Uses the low-level 'call' for secure withdrawal.
        (bool success,) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed.");
    }
    
    // Fallback/Receive function: Executed when Ether is sent to the contract without data.
    receive() external payable {
        emit LogDeposit(msg.sender, msg.value); // Logs the deposit.
        buyer.push(msg.sender); // Tracks the sender.
        
        // Stores the raw Ether donation amount.
        donationMap[msg.sender] = msg.value;
    }
}
