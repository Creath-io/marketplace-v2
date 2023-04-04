// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Creath is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address marketplace;


    /// @dev Events of the contract
    event Minted(
        uint256 tokenId,
        address beneficiary,
        string tokenUri,
        address minter
    );


    /// @notice Contract constructor
    constructor(address _marketplace) ERC721("Creath Marketplace", "CREATH") {
        _tokenIds.increment();
        marketplace = _marketplace;
    }

    /**
     @notice Mints a NFT AND when minting to a contract checks if the beneficiary is a 721 compatible
     @param _beneficiary Recipient of the NFT
     @param _tokenUri URI for the token being minted
     @return uint256 The token ID of the token that was minted
     */
    function mint(address _beneficiary, string calldata _tokenUri) external onlyOwner returns (uint256) {

        uint256 newTokenId = _tokenIds.current();

        // Mint token and set token URI
        _safeMint(_beneficiary, newTokenId);
        _setTokenURI(newTokenId, _tokenUri);

        _tokenIds.increment();
        
        emit Minted(newTokenId, _beneficiary, _tokenUri, _msgSender());

        return newTokenId;
    }

    /**
     @notice Burns a NFT
     @dev Only the owner or an approved sender can call this method
     @param _tokenId the token ID to burn
     */
    function burn(uint256 _tokenId) external onlyOwner{
        _burn(_tokenId);
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
     * Override isApprovedForAll to whitelist Creath contracts to enable gas-less listings.
     */
    function isApprovedForAll(address _owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist creath auction, marketplace, contracts for easy trading.
        if (
            marketplace == operator
        ) {
            return true;
        }

        return super.isApprovedForAll(_owner, operator);
    }

    /**
     * Override _isApprovedOrOwner to whitelist creath contracts to enable gas-less listings.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) override internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address _owner = ERC721.ownerOf(tokenId);
        if (isApprovedForAll(_owner, spender)) return true;
        return super._isApprovedOrOwner(spender, tokenId);
    }
}