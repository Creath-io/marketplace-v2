// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Creath is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _nftMinted;

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
    event UpdatePlatformFeeRecipient(
        address payable platformFeeRecipient
    );


    /// @dev TokenID -> Creator address
    mapping(uint256 => address) public creators;

    /// @notice Platform fee
    uint256 public platformFee;

    /// @notice Platform fee recipient
    address payable public feeRecipient;

    /// @notice Contract constructor
    constructor(
        address payable _feeRecipient,
        uint256 _platformFee
    ) ERC721("Creath Marketplace", "CMP") {
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;

        _tokenIds.increment();
    }

    /**
     @notice Mints a NFT AND when minting to a contract checks if the beneficiary is a 721 compatible
     @param _beneficiary Recipient of the NFT
     @param _tokenUri URI for the token being minted
     @return uint256 The token ID of the token that was minted
     */
    function mint(address _beneficiary, string calldata _tokenUri) external payable returns (uint256) {

        uint256 newNftMinted = _nftMinted.current();

        require(newNftMinted < 1000, 'CreathCollection: Allow to Only Mint limited NFTs');
        require(msg.value >= platformFee, "CreathCollection: Insufficient funds to mint.");

        // Valid args
        _assertMintingParamsValid(_tokenUri, _msgSender());

        uint256 newTokenId = _tokenIds.current();

        // Mint token and set token URI
        _safeMint(_beneficiary, newTokenId);
        _setTokenURI(newTokenId, _tokenUri);
        
        // Send ETH to fee recipient
        feeRecipient.transfer(msg.value);

        creators[newTokenId] = _msgSender();

        _tokenIds.increment();
        
        emit Minted(newTokenId, _beneficiary, _tokenUri, _msgSender());

        return newTokenId;
    }


    function _extractIncomingTokenId() internal pure returns (uint256) {
        // Extract out the embedded token ID from the sender
        uint256 _receiverTokenId;
        uint256 _index = msg.data.length - 32;
        assembly {_receiverTokenId := calldataload(_index)}
        return _receiverTokenId;
    }

    

    /**
     @notice View method for checking whether a token has been minted
     @param _tokenId ID of the token being checked
     */
    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }


    /**
     * @dev checks the given token ID is approved either for all or the single token ID
     */
    function isApproved(uint256 _tokenId, address _operator) public view returns (bool) {
        return isApprovedForAll(ownerOf(_tokenId), _operator) || getApproved(_tokenId) == _operator;
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
     @param _platformFeeRecipient payable address the address to sends the funds to
     */
    function updatePlatformFeeRecipient(address payable _platformFeeRecipient) external onlyOwner {
        feeRecipient = _platformFeeRecipient;
        emit UpdatePlatformFeeRecipient(_platformFeeRecipient);
    }

    

    /**
     @notice Checks that the URI is not empty and the designer is a real address
     @param _tokenUri URI supplied on minting
     @param _designer Address supplied on minting
     */
    function _assertMintingParamsValid(string calldata _tokenUri, address _designer) pure internal {
        require(bytes(_tokenUri).length > 0, "_assertMintingParamsValid: Token URI is empty");
        require(_designer != address(0), "_assertMintingParamsValid: Designer is zero address");
    }
}