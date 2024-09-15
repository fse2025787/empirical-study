// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-05-04
*/

// 

pragma solidity 0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Ownable {
    
    
    address public owner;
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    /**
     * @notice Transfer ownership to `newOwner`
     * @param newOwner The address to transfer the ownership to
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract TokenMigrator is Ownable {
    
    
    IERC20 public fromToken;
    
    
    IERC20 public toToken;
    
    
    address public constant BURN_ADDRESS = 0x0000000000000000000000000000000000000008;
    
    
    uint256 public constant endMigrationNoticePeriod = 2 weeks;

    
    bool public migrationEnabled = false;
    
    
    uint256 public endMigrationDate = type(uint256).max;
    
    
    event CloseMigrationNotice(uint256 epochTime);
    
    /**
     * @notice Construct a Migration contract
     * @param migrateFromToken The token to migrate from
     * @param migrateToToken The token to migrate into
     */
    constructor(address migrateFromToken, address migrateToToken) {
        fromToken = IERC20(migrateFromToken);
        toToken = IERC20(migrateToToken);
    }
    
    modifier whenMigrationEnabled() {
        require(migrationEnabled, "migration not enabled");
        _;
    }
    
    /**
     * @notice Start the migration. Can only be called if this contract has enough balance of toToken
     */
    function startMigration() public {
        uint256 requiredToTokenBalance = fromToken.totalSupply() - fromToken.balanceOf(BURN_ADDRESS);
        
        require(toToken.balanceOf(address(this)) >= requiredToTokenBalance, "not enough toToken balance");
        
        migrationEnabled = true;
    }
    
    /**
     * @notice Migrate `amount` of tokens
     * @param amount How many tokens to migrate
     */
    function migrate(uint256 amount) public whenMigrationEnabled returns (bool success) {
        require(fromToken.transferFrom(msg.sender, BURN_ADDRESS, amount), "burning fromToken failed");
        require(toToken.transfer(msg.sender, amount), "sending toToken failed");
        
        return true;
    }
    
    /**
     * @notice Announce the migration can be closed after `endMigrationNoticePeriod` 
     */
    function announceMigrationEnd() public onlyOwner whenMigrationEnabled {
        endMigrationDate = block.timestamp + endMigrationNoticePeriod;
        emit CloseMigrationNotice(endMigrationDate);
    }
    
    /**
     * @notice End the migration period. Can only be called after `endMigrationDate`
     *  This also transfers the remainingBalance of toToken back to the owner
     */
    function closeMigration() public onlyOwner whenMigrationEnabled {
        require(block.timestamp > endMigrationDate, "migration cannot be closed yet");
        migrationEnabled = false;
        uint256 remainingBalance = toToken.balanceOf(address(this));
        require(toToken.transfer(owner, remainingBalance), "recovering toToken failed");
    }
}