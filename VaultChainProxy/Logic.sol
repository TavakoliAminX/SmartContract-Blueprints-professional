// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the Chainlink Aggregator interface
import "./interface.sol";

/**
 * @title Logic
 * @dev A simple vault contract that allows deposits, owner-only emergency destruction,
 *      and fetching the latest ETH/USD price from Chainlink.
 *      This contract is written to be compatible with upgradeable proxy patterns.
 */
contract Logic {
    // The owner of the contract (can withdraw or destroy)
    address public owner;

    // Chainlink price feed address (ETH/USD)
    address public priceFeed;

    /**
     * @dev Initialize the contract.
     *      This is used instead of a constructor for upgradeable proxy compatibility.
     *      Can only be called once.
     * @param _owner The owner of the contract
     * @param _PriceFeed The address of the Chainlink price feed contract
     */
    function initialize(address _owner, address _PriceFeed) public {
        require(owner == address(0), "Already initialized"); // Prevent re-initialization
        owner = _owner;
        priceFeed = _PriceFeed;
    }

    /**
     * @dev Allow anyone to deposit ETH into the contract
     */
    function deposite() public payable {}

    /**
     * @dev Get the current ETH balance of the contract
     * @return uint The balance in wei
     */
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /**
     * @dev Fetch the latest ETH/USD price from Chainlink
     * @return int The latest price with 8 decimals
     *
     * Note: For production, consider using the `priceFeed` variable instead
     *       of hardcoding the address, so it can be flexible.
     */
    function getEthPriceInUsd() public view returns (int) {
        // Create an instance of the Chainlink Aggregator
        AggregatorV3Interface newPrice = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e // Goerli testnet ETH/USD feed
        );

        // Call latestRoundData() to get the price
        (, int answer, , , ) = newPrice.latestRoundData();

        return answer; // Price with 8 decimals
    }

    /**
     * @dev Modifier to restrict access to only the contract owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /**
     * @dev Emergency function to destroy the contract and send all funds to a recipient
     * @param _recipient The address to receive all ETH upon destruction
     *
     * Warning: selfdestruct permanently removes the contract from the blockchain
     */
    function emergencyDestroy(address payable _recipient) public onlyOwner {
        selfdestruct(_recipient);
    }
}
