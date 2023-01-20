// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CreathAddressRegistry is Ownable {
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    /// @notice Creath contract
    address public creath;

    /// @notice CreathAuction contract
    address public auction;

    /// @notice CreathMarketplace contract
    address public marketplace;

    /// @notice CreathNFTFactory contract
    address public factory;

    /// @notice CreathTokenRegistry contract
    address public tokenRegistry;

     /// @notice FantomPriceFeed contract
    address public priceFeed;


    /**
     @notice Update Creath contract
     @dev Only admin
     */
    function updateCreath(address _creath) external onlyOwner {
        require(
            IERC165(_creath).supportsInterface(INTERFACE_ID_ERC721),
            "Not ERC721"
        );
        creath = _creath;
    }

    /**
     @notice Update CreathAuction contract
     @dev Only admin
     */
    function updateAuction(address _auction) external onlyOwner {
        auction = _auction;
    }

    /**
     @notice Update CreathMarketplace contract
     @dev Only admin
     */
    function updateMarketplace(address _marketplace) external onlyOwner {
        marketplace = _marketplace;
    }


    /**
     @notice Update CreathNFTFactory contract
     @dev Only admin
     */
    function updateNFTFactory(address _factory) external onlyOwner {
        factory = _factory;
    }


    /**
     @notice Update token registry contract
     @dev Only admin
     */
    function updateTokenRegistry(address _tokenRegistry) external onlyOwner {
        tokenRegistry = _tokenRegistry;
    }
}