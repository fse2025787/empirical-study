// SPDX-License-Identifier: AGPL-3.0-only

// 
pragma solidity >=0.8.0;



abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// 
pragma solidity 0.8.10;




interface IExtractStrategy {
    function setLossValue(int256 _val) external;

    function strategyToken() external returns (address);

    function safeHarvest(
        uint256 maxBalanceInBentoBox,
        bool rebalance,
        uint256 maxChangeAmount,
        bool harvestRewards
    ) external;
}

contract AbraExtract is Owned {
    IBentoBoxMinimal bentoBox;
    IExtractStrategy strategy;
    address strategyToken;

    constructor(
        address _owner,
        address _bentoBox,
        address _strategy
    ) Owned(_owner) {
        bentoBox = IBentoBoxMinimal(_bentoBox);
        strategy = IExtractStrategy(_strategy);
        strategyToken = strategy.strategyToken();
    }

    function loopHarvest() external {
        for (uint256 i; i < 10; i++) {
            (, , uint256 balance) = bentoBox.strategyData(strategyToken);
            strategy.setLossValue(-int256(balance));
            uint256 elastic = bentoBox.totals(strategyToken).elastic;
            strategy.safeHarvest(elastic, true, 0, false);
        }
    }
}

// 
pragma solidity 0.8.10;



interface IBentoBoxMinimal {
    struct Rebase {
        uint128 elastic;
        uint128 base;
    }

    struct StrategyData {
        uint64 strategyStartDate;
        uint64 targetPercentage;
        uint128 balance; // the balance of the strategy that BentoBox thinks is in there
    }

    function balanceOf(address, address) external view returns (uint256);

    function batch(bytes[] calldata calls, bool revertOnFail)
        external
        payable
        returns (bool[] memory successes, bytes[] memory results);

    function claimOwnership() external;

    function deploy(
        address masterContract,
        bytes calldata data,
        bool useCreate2
    ) external payable;

    function deposit(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    function harvest(
        address token,
        bool balance,
        uint256 maxChangeAmount
    ) external;

    function masterContractApproved(address, address)
        external
        view
        returns (bool);

    function masterContractOf(address) external view returns (address);

    function nonces(address) external view returns (uint256);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function pendingStrategy(address) external view returns (IStrategy);

    function registerProtocol() external;

    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function setStrategy(address token, address newStrategy) external;

    function setStrategyTargetPercentage(
        address token,
        uint64 targetPercentage_
    ) external;

    function strategy(address) external view returns (IStrategy);

    function strategyData(address)
        external
        view
        returns (
            uint64 strategyStartDate,
            uint64 targetPercentage,
            uint128 balance
        );

    function toAmount(
        address token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);

    function toShare(
        address token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);

    function totals(address) external view returns (Rebase memory totals_);

    function transfer(
        address token,
        address from,
        address to,
        uint256 share
    ) external;

    function transferMultiple(
        address token,
        address from,
        address[] calldata tos,
        uint256[] calldata shares
    ) external;

    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) external;

    function whitelistMasterContract(address masterContract, bool approved)
        external;

    function whitelistedMasterContracts(address) external view returns (bool);

    function withdraw(
        address token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);
}

// 

pragma solidity 0.8.10;

interface IStrategy {
    
    
    function skim(uint256 amount) external;

    
    
    
    
    function harvest(uint256 balance, address sender)
        external
        returns (int256 amountAdded);

    
    
    /// The difference should NOT be used to report a loss. That's what harvest is for.
    
    
    function withdraw(uint256 amount) external returns (uint256 actualAmount);

    
    
    
    function exit(uint256 balance) external returns (int256 amountAdded);
}