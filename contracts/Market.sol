// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC721.sol";

contract Market {
    // public - anyone can call
    // private - only this contract
    // internal - only this contract and inheriting contracts
    // external - only external calls 
    enum ListingStatus { Active, Sold, Cancelled } 
    struct Listing {
        ListingStatus status;
        address seller;
        address buyer;
        address token;
        uint tokenId;
        uint price;
    }
    
    uint public listingId = 0;
    mapping(uint => Listing) private listings;

    event Listed(
        uint listingId,
        address seller,
        address token,
        uint tokenId,
        uint price
    );

    event Sale(
        uint listingId,
        address buyer,
        address token,
        uint tokenId,
        uint price
    );

    event Cancel(
        uint listingId,
        address seller
    );

    function listToken(address _token, uint _tokenId, uint _price) external {
        IERC721(_token).transferFrom(msg.sender, address(this), _tokenId);
        Listing memory list = Listing(
            ListingStatus.Active,
            msg.sender,
            address(0x00),
            _token,
            _tokenId,
            _price
        );
        listingId++;
        listings[listingId] = list;
        
        emit Listed(
            listingId,
            msg.sender,
            _token,
            _tokenId,
            _price
        );
    }

    function getListing(uint _listingId) public view returns (Listing memory) {
        return listings[_listingId];
    }

    function buyToken(uint _listingId) external payable {
        Listing storage list = listings[_listingId];
        
        require(msg.sender != list.seller, "Seller cannot be buyer.");
        require(list.status == ListingStatus.Active, "Listing is not active.");
        require(msg.value >= list.price, "Insufficient payment.");
        list.status = ListingStatus.Sold;
        list.buyer = msg.sender;

        IERC721(list.token).transferFrom(address(this), msg.sender, list.tokenId);
        payable(list.seller).transfer(list.price);

        emit Sale(
            _listingId, 
            msg.sender, 
            list.token, 
            list.tokenId,
            list.price
        );
    }

    function cancel(uint _listingId) public {
        Listing storage list = listings[_listingId];
        
        require(list.seller == msg.sender, "Only seller can cancel the listing.");
        require(list.status == ListingStatus.Active, "Listing is not active");
        list.status = ListingStatus.Cancelled;

        IERC721(list.token).transferFrom(address(this), msg.sender, list.tokenId);
      
        emit Cancel(
            _listingId, 
            list.seller
        );
    }
}