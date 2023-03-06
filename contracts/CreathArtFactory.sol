// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CreathArtTradable.sol";

contract CreathArtFactory is Ownable {
    /// @dev Events of the contract
    event ContractCreated(address creator, address nft);
    event ContractDisabled(address caller, address nft);

    /// @notice Creath marketplace contract address;
    address public marketplace;

    /// @notice Creath auction contract address;
    address public auction;

    /// @notice NFT Address => Bool
    mapping(address => bool) public exists;

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    /// @notice Contract constructor
    constructor(
        address _marketplace,
        address _auction
    ) public {
        marketplace = _marketplace;
        auction = _auction;
    }

     /**
    @notice Update auction contract
    @dev Only admin
    @param _auction address the auction contract address to set
    */
    function updateAuction(address _auction) external onlyOwner {
        auction = _auction;
    }

    /**
    @notice Update marketplace contract
    @dev Only admin
    @param _marketplace address the marketplace contract address to set
    */
    function updateMarketplace(address _marketplace) external onlyOwner {
        marketplace = _marketplace;
    }


    /// @notice Method for deploy new CreathArtTradable contract
    /// @param _name Name of NFT contract
    /// @param _symbol Symbol of NFT contract
    function createNFTContract(string memory _name, string memory _symbol)
        external
        onlyOwner
        returns (address)
    {
        CreathArtTradable nft = new CreathArtTradable(
            _name,
            _symbol,
            marketplace,
            auction
        );
        exists[address(nft)] = true;
        nft.transferOwnership(marketplace);
        emit ContractCreated(_msgSender(), address(nft));
        return address(nft);
    }

    /// @notice Method for registering existing CreathArtTradable contract
    /// @param  tokenContractAddress Address of NFT contract
    function registerTokenContract(address tokenContractAddress)
        external
        onlyOwner
    {
        require(!exists[tokenContractAddress], "Art contract already registered");
        require(IERC165(tokenContractAddress).supportsInterface(INTERFACE_ID_ERC721), "Not an ERC721 contract");
        exists[tokenContractAddress] = true;
        emit ContractCreated(_msgSender(), tokenContractAddress);
    }

    /// @notice Method for disabling existing CreathArtTradable contract
    /// @param  tokenContractAddress Address of NFT contract
    function disableTokenContract(address tokenContractAddress)
        external
        onlyOwner
    {
        require(exists[tokenContractAddress], "Art contract is not registered");
        exists[tokenContractAddress] = false;
        emit ContractDisabled(_msgSender(), tokenContractAddress);
    }
}