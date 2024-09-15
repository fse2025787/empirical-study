// SPDX-License-Identifier: GPL-3.0-or-later


// 
pragma solidity 0.8.6;

/**
 * @title CrowdfundStorage
 * @author MirrorXYZ
 */
contract CrowdfundStorage {
    /**
     * @notice The two states that this contract can exist in.
     * "FUNDING" allows contributors to add funds.
     */
    enum Status {
        FUNDING,
        TRADING
    }

    // ============ Constants ============

    
    uint16 internal constant TOKEN_SCALE = 1000;

    // ============ Reentrancy ============

    
    uint256 internal constant REENTRANCY_NOT_ENTERED = 1;
    uint256 internal constant REENTRANCY_ENTERED = 2;

    
    uint256 internal reentrancy_status;

    
    address payable public operator;

    
    address payable public fundingRecipient;

    
    address public treasuryConfig;

    
    uint256 public fundingCap;

    
    uint256 public feePercentage;

    
    uint256 public operatorPercent;

    // ============ Mutable Storage ============

    
    Status public status;
}

// 
pragma solidity 0.8.6;

/**
 * @title ERC20Storage
 * @author MirrorXYZ
 */
contract ERC20Storage {
    
    string public name;

    
    string public symbol;

    
    uint256 public totalSupply;

    
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        totalSupply = 0;
    }
}

interface IERC20Events {
    
    event Mint(address indexed to, uint256 amount);

    
    event Approval(
        address indexed from,
        address indexed spender,
        uint256 value
    );

    
    event Transfer(address indexed from, address indexed to, uint256 value);
}
// 
pragma solidity 0.8.6;





interface ICrowdfundFactory {
    function mediaAddress() external returns (address);

    function logic() external returns (address);

    // ERC20 data.
    function parameters()
        external
        returns (
            address payable fundingRecipient,
            uint256 fundingCap,
            uint256 operatorPercent,
            uint256 feePercentage
        );
}

/**
 * @title CrowdfundProxy
 * @author MirrorXYZ
 */
contract CrowdfundProxy is CrowdfundStorage, ERC20Storage, IERC20Events {
    event Upgraded(address indexed implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(
        address treasuryConfig_,
        address payable operator_,
        string memory name_,
        string memory symbol_
    ) ERC20Storage(name_, symbol_) {
        address logic = ICrowdfundFactory(msg.sender).logic();

        assembly {
            sstore(_IMPLEMENTATION_SLOT, logic)
        }

        emit Upgraded(logic);

        // Crowdfund-specific data.
        (
            fundingRecipient,
            fundingCap,
            operatorPercent,
            feePercentage
        ) = ICrowdfundFactory(msg.sender).parameters();

        operator = operator_;
        treasuryConfig = treasuryConfig_;
        // Initialize mutable storage.
        status = Status.FUNDING;
    }

    
    function logic() external view returns (address logic_) {
        assembly {
            logic_ := sload(_IMPLEMENTATION_SLOT)
        }
    }

    fallback() external payable {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(
                gas(),
                sload(_IMPLEMENTATION_SLOT),
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    receive() external payable {}
}

// 
pragma solidity 0.8.6;

interface IERC20 {
    
    function name() external returns (string calldata);

    
    function symbol() external returns (string calldata);

    
    function decimals() external returns (uint8);

    
    function totalSupply() external returns (uint256);

    
    function balanceOf(address account) external returns (uint256);

    
    function allowance(address owner, address spender)
        external
        returns (uint256);

    
    function approve(address spender, uint256 value) external returns (bool);

    
    function transfer(address to, uint256 value) external returns (bool);

    
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
