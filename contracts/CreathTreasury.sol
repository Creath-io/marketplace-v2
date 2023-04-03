//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// A Smart-contract that holds the Creath Marketplace funds
contract CreathTreasury is AccessControl{
    using SafeERC20 for IERC20;

    //marketplace address
    address public marketplace;
    
    //admin address. 
    address private ADMIN;


    // Event triggered once an address withdraws from the contract
    event Withdraw(address indexed user, uint amount);

    // Emitted when marketplace address is set
    event MarketplaceSet( address _address);

    // Restricted to authorised accounts.
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), 
        "Treasury:Restricted to only authorized accounts.");
        _;
    }


    constructor(address _admin){
        _setupRole("admin", _admin); 
        ADMIN = _admin;
    }


    /**
     * @notice check if address is authorized 
     * @param account the address of account to be checked
     * @return bool return true if account is authorized and false otherwise
     */
    function isAuthorized(address account)
        public view returns (bool)
    {
        if(hasRole("admin",account)) return true;

        else if(hasRole("marketplace", account)) return true;

        return false;
    }



    //this function is used to add admin of the treasury.  OnlyOwner can add addresses.
    function updateAdmin(address admin) 
        onlyRole("admin")
        external {
        _grantRole("admin", admin);
        _revokeRole("admin", ADMIN);
        ADMIN = admin;
    }

    function updateMarketplace(address _marketplace) external onlyRole("admin"){
        _setupRole("marketplace", _marketplace);
        marketplace = _marketplace;
    }


    /**
     * @notice withdraw other token
     * @param _token the token address
     * @param _to the spender address
     * @param _amount the deposited amount
     */
    function withdrawToken(address _token, address _to, uint _amount) 
        public 
        onlyAuthorized{
        IERC20(_token).safeTransfer(_to, _amount);
        emit Withdraw(_to, _amount);
    }

    /**
     * @notice withdraw eth
     * @param _amount the withdrawal amount
     */
    function withdraw(uint _amount, address _to) public onlyAuthorized{
        payable(_to).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    receive () external payable{
        
    }
    
}