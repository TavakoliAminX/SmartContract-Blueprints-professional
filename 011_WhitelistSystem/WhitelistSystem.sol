// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title WhitelistSystem
 * @dev Manages a secure list of authorized addresses (whitelist). 
 * Only the Admin can modify the list, and status check is fast and efficient.
 */
contract WhitelistSystem{
    address public immutable admin;
    mapping (address => bool) public isWhitelisted;
    uint public whitelistedCount;

    constructor(){
        admin = msg.sender;
    }
    modifier onlyAdmin(){
        require(msg.sender == admin, "Admin access required.");
        _;
    }
    
    // Events are named after the action that occurred (Added/Removed)
    event AddressAdded(address indexed target, address indexed adder);
    event AddressRemoved(address indexed target, address indexed remover);

    /**
     * @dev Adds a single address to the whitelist.
     * Renamed from _addAddress to addAddress for public clarity.
     */
    function addAddress(address _targetAddress) public onlyAdmin{
        require(isWhitelisted[_targetAddress] != true, "Address already whitelisted.");
        
        isWhitelisted[_targetAddress] = true;
        whitelistedCount++;
        
        emit AddressAdded(_targetAddress, msg.sender);
    }

    /**
     * @dev Removes a single address from the whitelist.
     */
    function removeAddress(address _targetAddress) public onlyAdmin{
        require(isWhitelisted[_targetAddress] != false, "Address not found in whitelist.");
        
        isWhitelisted[_targetAddress] = false;
        whitelistedCount--;
        
        // Emitting the corrected event name
        emit AddressRemoved(_targetAddress, msg.sender);
    }
    
    /**
     * @dev Adds multiple addresses in a single transaction by calling the main 'addAddress' function in a loop.
     */
    function addAddressesInBulk(address [] memory _targetAddress) public onlyAdmin {
        require(_targetAddress.length > 0, "Array cannot be empty.");
        
        for(uint i = 0; i < _targetAddress.length; i++){
            // Calling the main function to ensure all checks/events are applied.
            addAddress(_targetAddress[i]);
        }
    }
    
    /**
     * @dev Fast lookup function to check if an address is currently whitelisted.
     * Note: Solidity's public mapping getter (isWhitelisted) provides the same functionality.
     */
    function fastLookUp(address _adr) public view returns(bool){
        return isWhitelisted[_adr];
    }
}
