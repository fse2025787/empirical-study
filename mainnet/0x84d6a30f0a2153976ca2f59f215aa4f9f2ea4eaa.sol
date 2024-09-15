// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

// File: iface/IParassetGovernance.sol

// 

pragma solidity ^0.8.4;


interface IParassetGovernance {
    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    
    
    
    
    function checkGovernance(address addr, uint flag) external view returns (bool);
}
// File: ParassetBase.sol

pragma solidity ^0.8.4;

contract ParassetBase {

    // Lock flag
    uint256 _locked;

	
    
    function initialize(address governance) public virtual {
        require(_governance == address(0), "Log:ParassetBase!initialize");
        _governance = governance;
        _locked = 0;
    }

    
    address public _governance;

    
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || IParassetGovernance(governance).checkGovernance(msg.sender, 0), "Log:ParassetBase:!gov");
        _governance = newGovernance;
    }

    
    
    
    
    
    function getDecimalConversion(
        address inputToken, 
        uint256 inputTokenAmount, 
        address outputToken
    ) public view returns(uint256) {
    	uint256 inputTokenDec = 18;
    	uint256 outputTokenDec = 18;
    	if (inputToken != address(0x0)) {
    		inputTokenDec = IERC20(inputToken).decimals();
    	}
    	if (outputToken != address(0x0)) {
    		outputTokenDec = IERC20(outputToken).decimals();
    	}
    	return inputTokenAmount * (10**outputTokenDec) / (10**inputTokenDec);
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(IParassetGovernance(_governance).checkGovernance(msg.sender, 0), "Log:ParassetBase:!gov");
        _;
    }

    modifier nonReentrant() {
        require(_locked == 0, "Log:ParassetBase:!_locked");
        _locked = 1;
        _;
        _locked = 0;
    }
}
// File: iface/IERC20.sol

pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: iface/ILPStakingMiningPool.sol

pragma solidity ^0.8.4;

interface ILPStakingMiningPool {
	function getBlock(uint256 endBlock) external view returns(uint256);
	function getBalance(address stakingToken, address account) external view returns(uint256);
	function getChannelInfo(address stakingToken) external view returns(uint256 lastUpdateBlock, uint256 endBlock, uint256 rewardRate, uint256 rewardPerTokenStored, uint256 totalSupply);
	function getAccountReward(address stakingToken, address account) external view returns(uint256);
	function stake(uint256 amount, address stakingToken) external;
	function withdraw(uint256 amount, address stakingToken) external;
	function getReward(address stakingToken) external;
}
// File: lib/TransferHelper.sol

pragma solidity ^0.8.4;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
// File: LPStakingMiningPool.sol

pragma solidity ^0.8.4;

contract LPStakingMiningPool is ParassetBase, ILPStakingMiningPool {

	// ASET
    address public _rewardsToken;
    
    // token => channel info
    mapping(address => Channel) _tokenChannel;
    struct Channel {
        // recently operated block
        // limit4294967295
        uint32 lastUpdateBlock;
        // end block
        // limit4294967295
        uint32 endBlock;
        // revenue efficiency
        uint192 rewardRate;
        // profit per share
        uint256 rewardPerTokenStored;
        // total locked position
        uint256 totalSupply;
        // user address => Account info
        mapping(address => Account) accounts;
    }

    struct Account {
        // locked position
        uint256 balance;
        // latest profit per share
        uint256 userRewardPerTokenPaid;
    }

    //---------view---------

    
    
    
    function getBlock(uint256 endBlock) public view override returns(uint256) {
        uint256 nowBlock = block.number;
        if (nowBlock > endBlock) {
            return endBlock;
        }
        return nowBlock;
    }
    
    
    
    
    
    function getBalance(
        address stakingToken, 
        address account
    ) external view override returns(uint256) {
        return _tokenChannel[stakingToken].accounts[account].balance;
    }

    
    
    
    
    
    
    
    function getChannelInfo(
        address stakingToken
    ) external view override returns (
        uint256 lastUpdateBlock, 
        uint256 endBlock, 
        uint256 rewardRate, 
        uint256 rewardPerTokenStored, 
        uint256 totalSupply
    ) {
        Channel storage channelInfo = _tokenChannel[stakingToken];
        return (channelInfo.lastUpdateBlock, 
                channelInfo.endBlock, 
                channelInfo.rewardRate, 
                channelInfo.rewardPerTokenStored, 
                channelInfo.totalSupply);
    }

    
    
    
    
    function getAccountReward(
        address stakingToken, 
        address account
    ) external view override returns(uint256) {
        Channel storage channelInfo = _tokenChannel[stakingToken];
        (,,uint256 userReward) = _calcReward(channelInfo, account);
        return userReward;
    }

    
    
    
    
    
    function getAccountInfo(
        address stakingToken, 
        address account
    ) external view returns(
        uint256 balance, 
        uint256 userRewardPerTokenPaid
    ) {
        Account memory accountInfo = _tokenChannel[stakingToken].accounts[account];
        return (accountInfo.balance, accountInfo.userRewardPerTokenPaid);
    }

    function _calcReward(
        Channel storage channelInfo,
        address account
    ) private view returns(
        uint32 _nowBlock, 
        uint256 _rewardPerTokenStored, 
        uint256 _userReward
    ) {
        uint256 nowBlock = getBlock(channelInfo.endBlock);
        uint256 totalSupply = channelInfo.totalSupply;
        uint256 rewardPerTokenStored = channelInfo.rewardPerTokenStored;
        uint256 lastUpdateBlock = channelInfo.lastUpdateBlock;
        uint256 accrued = (lastUpdateBlock == 0 ? 0 : (nowBlock - lastUpdateBlock) * channelInfo.rewardRate);

        _nowBlock = uint32(nowBlock);
        _rewardPerTokenStored = (totalSupply == 0 ? 
                                rewardPerTokenStored : 
                                (rewardPerTokenStored + accrued * 1e18 / totalSupply));
        _userReward = channelInfo.accounts[account].balance
                      * (_rewardPerTokenStored 
                      - channelInfo.accounts[account].userRewardPerTokenPaid)
                      / 1e18;
    }

    //---------governance----------

    
    function setRewardsToken(address add) external onlyGovernance {
        _rewardsToken = add;
    }

    
    
    
    
    
    function addToken(
        uint256 tokenAmount, 
        address from, 
        uint96 rewardRate, 
        address stakingToken
    ) external onlyGovernance {
    	TransferHelper.safeTransferFrom(_rewardsToken, from, address(this), tokenAmount);
        Channel storage channelInfo = _tokenChannel[stakingToken];
    	channelInfo.lastUpdateBlock = uint32(block.number);
        channelInfo.rewardRate = rewardRate;
    	channelInfo.endBlock = uint32(tokenAmount / rewardRate + block.number);
    }

    
    
    
    
    
    function setChannelInfo(
        uint32 lastUpdateBlock, 
        uint32 endBlock, 
        uint96 rewardRate,
        address stakingToken
    ) external onlyGovernance {
        Channel storage channelInfo = _tokenChannel[stakingToken];
        // settlement
        (, uint256 rewardPerTokenStored,) = _calcReward(channelInfo, address(this));
        channelInfo.rewardPerTokenStored = rewardPerTokenStored;
        // update
        channelInfo.lastUpdateBlock = lastUpdateBlock;
        channelInfo.endBlock = endBlock;
        channelInfo.rewardRate = rewardRate;
    }

    //---------transaction---------

    
    
    
    function stake(uint256 amount, address stakingToken) external override nonReentrant {
        require(amount > 0, "Log:LPStakingMiningPool:!0");

        Channel storage channelInfo = _tokenChannel[stakingToken];
        _getReward(channelInfo, msg.sender);

        TransferHelper.safeTransferFrom(stakingToken, msg.sender, address(this), amount);

    	channelInfo.totalSupply = channelInfo.totalSupply + amount;
        channelInfo.accounts[msg.sender].balance = channelInfo.accounts[msg.sender].balance + amount;
    }

    
    
    
    function withdraw(uint256 amount, address stakingToken) external override nonReentrant {
        require(amount > 0, "Log:LPStakingMiningPool:!0");

        Channel storage channelInfo = _tokenChannel[stakingToken];
        _getReward(channelInfo, msg.sender);

        channelInfo.totalSupply = channelInfo.totalSupply - amount;
        channelInfo.accounts[msg.sender].balance = channelInfo.accounts[msg.sender].balance - amount;

    	TransferHelper.safeTransfer(stakingToken, msg.sender, amount);
    }

    
    
    function getReward(address stakingToken) external override nonReentrant {
        Channel storage channelInfo = _tokenChannel[stakingToken];
        _getReward(channelInfo, msg.sender);
    }

    function _getReward(Channel storage channelInfo, address to) private {
        (uint32 lastUpdateBlock, uint256 rewardPerTokenStored, uint256 userReward) = _calcReward(channelInfo, to);

        channelInfo.rewardPerTokenStored = rewardPerTokenStored;
        channelInfo.lastUpdateBlock = lastUpdateBlock;

        if (to != address(0)) {
            if (userReward > 0) {
                // transfer ASET
                _safeAsetTransfer(to, userReward);
            }
            channelInfo.accounts[to].userRewardPerTokenPaid = rewardPerTokenStored;
        }
    }

    function _safeAsetTransfer(address to, uint256 amount) private returns (uint256) {
        uint256 asetBal = IERC20(_rewardsToken).balanceOf(address(this));
        if (amount > asetBal) {
            amount = asetBal;
        }
        // allow zero amount
        TransferHelper.safeTransfer(_rewardsToken, to, amount);
        return amount;
    }
}