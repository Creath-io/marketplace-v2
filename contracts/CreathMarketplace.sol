// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


interface ITreasury {
    // withdraw other token
    function withdrawToken(address _token, address _to, uint _amount)external;
}



contract CreathMarketplace is 
Initializable,
UUPSUpgradeable,
OwnableUpgradeable, 
ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address payable;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable private paymentToken;

    /// @notice Events for the contract
    event ItemListed(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        uint256 price
    );
    event ItemSold(
        address indexed seller,
        address indexed buyer,
        address indexed nft,
        uint256 tokenId,
        uint256 price
    );
    event ItemUpdated(
        address indexed owner,
        address indexed nft,
        uint256 tokenId,
        uint256 newPrice
    );
    event ItemCanceled(
        address indexed owner,
        address indexed nft,
        uint256 tokenId
    );

    event UpdatePlatformFee(uint16 platformFee);
    event UpdatePlatformFeeRecipient(address payable platformFeeRecipient);


    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    /// @notice NftAddress -> Token ID -> Artist
    mapping(address => mapping(uint256 => address)) public artists;


    /// @notice NftAddress -> Token ID -> Listing item
    mapping(address => mapping(uint256 => uint256))
        public listings;

    /// @notice Platform fee
    uint16 public platformFee;

    /// @notice Platform fee receipient
    address payable public feeReceipient;

    struct Item{
        uint256 tokenId;
        address nft_address;
    }

    mapping(address => Item[]) private bought_items;


    modifier isListed(
        address _nftAddress,
        uint256 _tokenId
    ) {
        uint listing = listings[_nftAddress][_tokenId];
        require(listing >  0, "Creath Marketplace:not listed item");
        _;
    }

    modifier notListed(
        address _nftAddress,
        uint256 _tokenId
    ) {
        uint listing = listings[_nftAddress][_tokenId];
        require(listing <= 0, "Creath Marketplace:already listed");
        _;
    }



    /// @notice Contract initializer
    function initialize(
        address payable _feeRecipient, 
        address _token,
        uint16 _platformFee)
        public
        initializer
    {
        __Ownable_init();

        platformFee = _platformFee;
        feeReceipient = _feeRecipient;
        paymentToken = IERC20Upgradeable(_token);

    }


    /**
     * @notice Authorizes upgrade allowed to only proxy 
     * @param newImplementation the address of the new implementation contract 
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner{}

    function updatePaymentToken(address newPaymentToken) external onlyOwner{
        paymentToken = IERC20Upgradeable(newPaymentToken);
    }

    /// @notice Method for listing NFT
    /// @param _nftAddress Address of NFT contract
    /// @param _tokenId Token ID of NFT
    /// @param _price sale price for iteam
    function listItem(
        address _nftAddress,
        address _artist,
        uint256 _tokenId,
        uint256 _price
    ) external onlyOwner notListed(_nftAddress, _tokenId) {
        if (IERC165Upgradeable(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721Upgradeable nft = IERC721Upgradeable(_nftAddress);
            require(
                nft.isApprovedForAll(owner(), address(this)),
                "item not approved"
            );
        } else {
            revert("Creath Marketplace:invalid nft address");
        }

        listings[_nftAddress][_tokenId] = _price;

        artists[_nftAddress][_tokenId] = _artist;

        emit ItemListed(
            _artist,
            _nftAddress,
            _tokenId,
            _price
        );
    }

    /// @notice Method for canceling listed NFT
    function cancelListing(address _nftAddress, address _artist, uint256 _tokenId)
        external
        onlyOwner
        nonReentrant
        isListed(_nftAddress, _tokenId)
    {
        _cancelListing(_nftAddress,_artist, _tokenId);
    }

    /// @notice Method for updating listed NFT
    /// @param _nftAddress Address of NFT contract
    /// @param _tokenId Token ID of NFT
    /// @param _newPrice New sale price for each iteam
    function updateListing(
        address _nftAddress,
        address _artist,
        uint256 _tokenId,
        uint256 _newPrice
    ) external onlyOwner nonReentrant isListed(_nftAddress, _tokenId) {
        uint listedItem = listings[_nftAddress][_tokenId];

        listedItem = _newPrice;
        emit ItemUpdated(
            _artist,
            _nftAddress,
            _tokenId,
            _newPrice
        );
    }

    /// @notice Method for buying listed NFT
    /// @param _nftAddress NFT contract address
    /// @param _tokenId TokenId
    function buyItem(
        address _nftAddress,
        uint256 _tokenId
    )
        external
        nonReentrant
        isListed(_nftAddress, _tokenId)
    {
        _buyItem(_nftAddress, _tokenId, msg.sender);
    }

    function _buyItem(
        address _nftAddress,
        uint256 _tokenId,
        address buyer
    ) private {
        uint listedItem = listings[_nftAddress][_tokenId];

        uint256 feeAmount = (listedItem.mul(platformFee)).div(100);

        IERC20Upgradeable(paymentToken).safeTransferFrom(
            _msgSender(),
            feeReceipient,
            listedItem
        );

        address artist = artists[_nftAddress][_tokenId];
        bought_items[buyer].push(Item(_tokenId, _nftAddress));

        ITreasury(feeReceipient).withdrawToken(address(paymentToken), artist, listedItem.sub(feeAmount));
        

        // Transfer NFT to buyer
        if (IERC165Upgradeable(_nftAddress).supportsInterface(INTERFACE_ID_ERC721)) {
            IERC721Upgradeable(_nftAddress).transferFrom(owner(), buyer, _tokenId);      
        } 

        emit ItemSold(
            artist,
            buyer,
            _nftAddress,
            _tokenId,
            listedItem
        );
        delete (listings[_nftAddress][_tokenId]);
    }

   

    /**
     @notice Method for updating platform fee
     @dev Only admin
     @param _platformFee uint16 the platform fee to set
     */
    function updatePlatformFee(uint16 _platformFee) external onlyOwner {
        platformFee = _platformFee;
        emit UpdatePlatformFee(_platformFee);
    }

    /**
     @notice Method for updating platform fee address
     @dev Only admin
     @param _platformFeeRecipient payable address the address to sends the funds to
     */
    function updatePlatformFeeRecipient(address payable _platformFeeRecipient)
        external
        onlyOwner
    {
        feeReceipient = _platformFeeRecipient;
        emit UpdatePlatformFeeRecipient(_platformFeeRecipient);
    }

    function getCollectorData(address _user)external view returns(Item[] memory){
        return bought_items[_user];
    }


    function _cancelListing(
        address _nftAddress,
        address _artist,
        uint256 _tokenId
    ) private {

        delete (listings[_nftAddress][_tokenId]);
        delete (artists[_nftAddress][_tokenId]);
        emit ItemCanceled(_artist, _nftAddress, _tokenId);
    }
}