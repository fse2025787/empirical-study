// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-07-29
*/

// Sources flattened with hardhat v2.3.0 https://hardhat.org

// File contracts/interfaces/ICoFiXMapping.sol

// 

pragma solidity ^0.8.6;


interface ICoFiXMapping {

    
    
    
    
    
    
    
    function setBuiltinAddress(
        address cofiToken,
        address cofiNode,
        address cofixDAO,
        address cofixRouter,
        address cofixController,
        address cofixVaultForStaking
    ) external;

    
    
    
    
    
    
    function getBuiltinAddress() external view returns (
        address cofiToken,
        address cofiNode,
        address cofixDAO,
        address cofixRouter,
        address cofixController,
        address cofixVaultForStaking
    );

    
    
    function getCoFiTokenAddress() external view returns (address);

    
    
    function getCoFiNodeAddress() external view returns (address);

    
    
    function getCoFiXDAOAddress() external view returns (address);

    
    
    function getCoFiXRouterAddress() external view returns (address);

    
    
    function getCoFiXControllerAddress() external view returns (address);

    
    
    function getCoFiXVaultForStakingAddress() external view returns (address);

    
    
    
    function registerAddress(string calldata key, address addr) external;

    
    
    
    function checkAddress(string calldata key) external view returns (address);
}


// File contracts/interfaces/ICoFiXGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

interface ICoFiXGovernance is ICoFiXMapping {

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    
    
    
    /// to pass the check
    
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

// MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


// File contracts/libs/TransferHelper.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/interfaces/ICoFiXDAO.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;


interface ICoFiXDAO {

    
    
    
    event ApplicationChanged(address addr, uint flag);
    
    
    struct Config {
        // Redeem status, 1 means normal
        uint8 status;

        // The number of CoFi redeem per block. 100
        uint16 cofiPerBlock;

        // The maximum number of CoFi in a single redeem. 30000
        uint32 cofiLimit;

        // Price deviation limit, beyond this upper limit stop redeem (10000 based). 1000
        uint16 priceDeviationLimit;
    }

    
    
    function setConfig(Config calldata config) external;

    
    
    function getConfig() external view returns (Config memory);

    
    
    
    function setApplication(address addr, uint flag) external;

    
    
    
    function checkApplication(address addr) external view returns (uint);

    
    /// For example, set USDC to anchor usdt, because USDC is 18 decimal places and usdt is 6 decimal places. 
    /// so exchange = 1e6 * 1 ether / 1e18 = 1e6
    
    
    
    function setTokenExchange(address token, address target, uint exchange) external;

    
    /// For example, set USDC to anchor usdt, because USDC is 18 decimal places and usdt is 6 decimal places. 
    /// so exchange = 1e6 * 1 ether / 1e18 = 1e6
    
    
    
    function getTokenExchange(address token) external view returns (address target, uint exchange);

    
    
    function addETHReward(address pool) external payable;

    
    
    function totalETHRewards(address pool) external view returns (uint);

    
    
    
    
    
    function settle(address pool, address tokenAddress, address to, uint value) external payable;

    
    
    
    
    /// and the excess fees will be returned through this address
    function redeem(uint amount, address payback) external payable;

    
    
    
    
    
    /// and the excess fees will be returned through this address
    function redeemToken(address token, uint amount, address payback) external payable;

    
    function quotaOf() external view returns (uint);
}


// File contracts/CoFiXBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
// Router contract to interact with each CoFiXPair, no owner or governance

contract CoFiXBase {

    // Address of CoFiToken contract
    address constant COFI_TOKEN_ADDRESS = 0x1a23a6BfBAdB59fa563008c0fB7cf96dfCF34Ea1;

    // Address of CoFiNode contract
    address constant CNODE_TOKEN_ADDRESS = 0x558201DC4741efc11031Cdc3BC1bC728C23bF512;

    // Genesis block number of CoFi
    // CoFiToken contract is created at block height 11040156. However, because the mining algorithm of CoFiX1.0
    // is different from that at present, a new mining algorithm is adopted from CoFiX2.1. The new algorithm
    // includes the attenuation logic according to the block. Therefore, it is necessary to trace the block
    // where the CoFi begins to decay. According to the circulation when CoFi2.0 is online, the new mining
    // algorithm is used to deduce and convert the CoFi, and the new algorithm is used to mine the CoFiX2.1
    // on-line flow, the actual block is 11040688
    uint constant COFI_GENESIS_BLOCK = 11040688;

    
    address public _governance;

    
    
    function initialize(address governance) virtual public {
        require(_governance == address(0), "CoFiX:!initialize");
        _governance = governance;
    }

    
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || ICoFiXGovernance(governance).checkGovernance(msg.sender, 0), "CoFiX:!gov");
        _governance = newGovernance;
    }

    
    
    
    function migrate(address tokenAddress, uint value) external onlyGovernance {

        address to = ICoFiXGovernance(_governance).getCoFiXDAOAddress();
        if (tokenAddress == address(0)) {
            ICoFiXDAO(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(ICoFiXGovernance(_governance).checkGovernance(msg.sender, 0), "CoFiX:!gov");
        _;
    }

    modifier noContract() {
        require(msg.sender == tx.origin, "CoFiX:!contract");
        _;
    }
}


// File contracts/CoFiXMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

abstract contract CoFiXMapping is CoFiXBase, ICoFiXMapping {

    
    address _cofiToken;

    
    address _cofiNode;

    
    address _cofixDAO;

    
    address _cofixRouter;

    
    address _cofixController;

    
    address _cofixVaultForStaking;

    
    mapping(string=>address) _registeredAddress;

    
    
    
    
    
    
    
    function setBuiltinAddress(
        address cofiToken,
        address cofiNode,
        address cofixDAO,
        address cofixRouter,
        address cofixController,
        address cofixVaultForStaking
    ) external override onlyGovernance {

        if (cofiToken != address(0)) {
            _cofiToken = cofiToken;
        }
        if (cofiNode != address(0)) {
            _cofiNode = cofiNode;
        }
        if (cofixDAO != address(0)) {
            _cofixDAO = cofixDAO;
        }
        if (cofixRouter != address(0)) {
            _cofixRouter = cofixRouter;
        }
        if (cofixController != address(0)) {
            _cofixController = cofixController;
        }
        if (cofixVaultForStaking != address(0)) {
            _cofixVaultForStaking = cofixVaultForStaking;
        }
    }

    
    
    
    
    
    
    function getBuiltinAddress() external view override returns (
        address cofiToken,
        address cofiNode,
        address cofixDAO,
        address cofixRouter,
        address cofixController,
        address cofixVaultForStaking
    ) {
        return (
            _cofiToken,
            _cofiNode,
            _cofixDAO,
            _cofixRouter,
            _cofixController,
            _cofixVaultForStaking
        );
    }

    
    
    function getCoFiTokenAddress() external view override returns (address) { return _cofiToken; }

    
    
    function getCoFiNodeAddress() external view override returns (address) { return _cofiNode; }

    
    
    function getCoFiXDAOAddress() external view override returns (address) { return _cofixDAO; }

    
    
    function getCoFiXRouterAddress() external view override returns (address) { return _cofixRouter; }

    
    
    function getCoFiXControllerAddress() external view override returns (address) { return _cofixController; }

    
    
    function getCoFiXVaultForStakingAddress() external view override returns (address) { return _cofixVaultForStaking; }

    
    
    
    function registerAddress(string calldata key, address addr) external override onlyGovernance {
        _registeredAddress[key] = addr;
    }

    
    
    
    function checkAddress(string calldata key) external view override returns (address) {
        return _registeredAddress[key];
    }
}


// File contracts/CoFiXGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

contract CoFiXGovernance is CoFiXMapping, ICoFiXGovernance {

    
    
    function initialize(address governance) public override {

        // While initialize CoFiXGovernance, newGovernance is address(this),
        // So must let newGovernance to 0
        require(governance == address(0), "CoFiXGovernance:!address");

        // newGovernance is address(this)
        super.initialize(address(this));

        // Add msg.sender to governance
        _governanceMapping[msg.sender] = GovernanceInfo(msg.sender, uint96(0xFFFFFFFFFFFFFFFFFFFFFFFF));
    }

    
    struct GovernanceInfo {
        address addr;
        uint96 flag;
    }

    
    mapping(address=>GovernanceInfo) _governanceMapping;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external override onlyGovernance {
        
        if (flag > 0) {
            _governanceMapping[addr] = GovernanceInfo(addr, uint96(flag));
        } else {
            _governanceMapping[addr] = GovernanceInfo(address(0), uint96(0));
        }
    }

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view override returns (uint) {
        return _governanceMapping[addr].flag;
    }

    
    
    
    /// weight to pass the check
    
    function checkGovernance(address addr, uint flag) public view override returns (bool) {
        return _governanceMapping[addr].flag > flag;
    }
}