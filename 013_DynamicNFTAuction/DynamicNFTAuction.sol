// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

interface IERC721  {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}


contract DynamicNFTAuction{
    address public auctioneer;
    address public immutable ERC721_ADDRESS;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;
    uint public tokenId;
    bool public auctionEnded;
    mapping (address => uint) public bids;
    uint public constant MIN_BID_INCREMENT = 1e16; // 0.01 ETH 

    event AuctionFinalized(address indexed winner, uint amount, uint tokenID);
    event BidPlaced(address indexed bidder, uint amount);

    constructor(address _nftAddress, uint _tokenId, uint _durationInSeconds){
        auctioneer = msg.sender;
        ERC721_ADDRESS = _nftAddress;
        tokenId = _tokenId;
        auctionEndTime = block.timestamp + _durationInSeconds;
        highestBidder = address(0);
    }


    function bid() public payable {
        // 1. Checks
        require(block.timestamp < auctionEndTime, "Auction has ended.");
        require(msg.value > highestBid + MIN_BID_INCREMENT, "Bid must exceed current highest bid plus minimum increment.");
        
        // 2. Effects (Refund Logic)
        if(highestBidder != address(0)){
            // Add previous highest bid to the refund pool of the previous bidder
            bids[highestBidder] += highestBid; 
        }

        // Update state to the new highest bid
        highestBid = msg.value;
        highestBidder = msg.sender;
        
        // 3. Interaction / Event
        emit BidPlaced(msg.sender, msg.value);
    }

    function withdrawBid() public {
        // 1. Checks
        uint amount = bids[msg.sender];
        require(amount > 0, "No funds available for withdrawal.");
        
        // 2. Effects (CEI Pattern: Reset balance BEFORE transfer)
        bids[msg.sender] = 0;
        
        // 3. Interaction
        (bool success, ) = payable(msg.sender).call{value:amount}("");
        require(success, "ETH transfer failed.");
    }

    function auctionEnd() public {
        // 1. Checks
        require(block.timestamp >= auctionEndTime, "Auction has not ended yet.");
        require(auctionEnded == false, "Auction has already been finalized.");
        require(highestBidder != address(0), "No bids were placed.");

        // 2. Effects (CEI Pattern: Set flag BEFORE interaction)
        auctionEnded = true;

        // --- Handle Transfers ---

        // A. Interaction: Transfer NFT to winner
        IERC721 nftContract = IERC721(ERC721_ADDRESS);
        nftContract.safeTransferFrom(address(this), highestBidder, tokenId);


        // B. Interaction: Transfer ETH to auctioneer
        // Use payable(auctioneer).call to securely send funds
        (bool success, ) = payable(auctioneer).call{value: highestBid}("");
        require(success, "ETH transfer to auctioneer failed.");
        
        // 3. Event
        emit AuctionFinalized(highestBidder, highestBid, tokenId);
    }
}
