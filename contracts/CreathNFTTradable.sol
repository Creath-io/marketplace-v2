// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SportrexNFTTradable
 * SportrexNFTTradable - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract SportrexNFTTradable is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /// @dev Events of the contract
    event Minted(
        uint256 tokenId,
        address beneficiary,
        string tokenUri,
        address minter
    );
    event UpdatePlatformFee(
        uint256 platformFee
    );
    event UpdateFeeRecipient(
        address payable feeRecipient
    );


    /// @notice Platform fee
    uint256 public platformFee;

    /// @notice Platform fee receipient
    address payable public feeReceipient;

    /// @notice Sportrex auction contract address;
    address public auction;

    /// @notice Sportrex marketplace contract address;
    address public marketplace;

    /// @dev TokenID -> Creator address
    mapping(uint256 => address) public creators;

    /// @notice Contract constructor
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _platformFee,
        address _auction,
        address _marketplace,
        address payable _feeReceipient
    ) ERC721(_name, _symbol) {
        platformFee = _platformFee;
        auction = _auction;
        marketplace = _marketplace;
        feeReceipient = _feeReceipient;

        _tokenIds.increment();
    }

    /**
     @notice Method for updating platform fee
     @dev Only admin
     @param _platformFee uint256 the platform fee to set
     */
    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
        emit UpdatePlatformFee(_platformFee);
    }

    /**
     @notice Method for updating platform fee address
     @dev Only admin
     @param _feeReceipient payable address the address to sends the funds to
     */
    function updateFeeRecipient(address payable _feeReceipient)
        external
        onlyOwner
    {
        feeReceipient = _feeReceipient;
        emit UpdateFeeRecipient(_feeReceipient);
    }

    /**
     * @dev Mints a token to an address with a tokenURI.
     * @param _to address of the future owner of the token
     */
    function mint(address _to, string calldata _tokenUri) external payable {
        require(msg.value >= platformFee, "Insufficient funds to mint.");

        uint256 newTokenId = _tokenIds.current();
        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenUri);

        // Send ETH to fee recipient
        (bool success,) = feeReceipient.call{value : msg.value}("");
        require(success, "Transfer failed");

        creators[newTokenId] = _msgSender();

        _tokenIds.increment();

        emit Minted(newTokenId, _to, _tokenUri, _msgSender());
    }


    /**
     * @dev checks the given token ID is approved either for all or the single token ID
     */
    function isApproved(uint256 _tokenId, address _operator) public view returns (bool) {
        return isApprovedForAll(ownerOf(_tokenId), _operator) || getApproved(_tokenId) == _operator;
    }

    /**
     * Override isApprovedForAll to whitelist Sportrex contracts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist Sportrex auction, marketplace contracts for easy trading.
        if (
            auction == operator ||
            marketplace == operator
        ) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * Override _isApprovedOrOwner to whitelist Sportrex contracts to enable gas-less listings.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) override internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        if (isApprovedForAll(owner, spender)) return true;
        return super._isApprovedOrOwner(spender, tokenId);
    }
}