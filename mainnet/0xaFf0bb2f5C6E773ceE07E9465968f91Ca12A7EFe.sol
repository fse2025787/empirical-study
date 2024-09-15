// SPDX-License-Identifier: Unlicense


// 
pragma solidity >=0.8.4;




/// account (an owner) that can be granted exclusive access to specific functions.
///
/// By default, the owner account will be the one that deploys the contract. This can later be
/// changed with {transfer}.
///
/// This module is used through inheritance. It will make available the modifier `onlyOwner`,
/// which can be applied to your functions to restrict their use to the owner.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol
interface IOwnable {
    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function _renounceOwnership() external;

    
    /// called by the current owner.
    
    function _transferOwnership(address newOwner) external;

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);
}

// 
pragma solidity >=0.8.4;




error Ownable__NotOwner(address owner, address caller);


error Ownable__OwnerZeroAddress();



contract Ownable is IOwnable {
    /// PUBLIC STORAGE ///

    
    address public override owner;

    /// MODIFIERS ///

    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Ownable__NotOwner(owner, msg.sender);
        }
        _;
    }

    /// CONSTRUCTOR ///

    
    constructor() {
        address msgSender = msg.sender;
        owner = msgSender;
        emit TransferOwnership(address(0), msgSender);
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function _renounceOwnership() public virtual override onlyOwner {
        emit TransferOwnership(owner, address(0));
        owner = address(0);
    }

    
    function _transferOwnership(address newOwner) public virtual override onlyOwner {
        if (newOwner == address(0)) {
            revert Ownable__OwnerZeroAddress();
        }
        emit TransferOwnership(owner, newOwner);
        owner = newOwner;
    }
}

// 
pragma solidity >=0.8.4;









interface IChainlinkOperator {
    /// CUSTOM ERRORS ///

    
    error ChainlinkOperator__DecimalsMismatch(string symbol, uint256 decimals);

    
    error ChainlinkOperator__FeedNotSet(string symbol);

    
    error ChainlinkOperator__PriceLessThanOrEqualToZero(string symbol);

    
    error ChainlinkOperator__PriceStale(string symbol);

    /// EVENTS ///

    
    
    
    event DeleteFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    
    
    
    event SetFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    
    
    
    event SetPriceStalenessThreshold(uint256 oldPriceStalenessThreshold, uint256 newPriceStalenessThreshold);

    /// STRUCTS ///

    struct Feed {
        IErc20 asset;
        IAggregatorV3 id;
        bool isSet;
    }

    /// CONSTANT FUNCTIONS ///

    
    
    
    function getFeed(string memory symbol)
        external
        view
        returns (
            IErc20,
            IAggregatorV3,
            bool
        );

    
    /// format used by Chainlink, which has 8 decimals.
    ///
    
    /// - The normalized price cannot overflow.
    ///
    
    
    function getNormalizedPrice(string memory symbol) external view returns (uint256);

    
    /// has 8 decimals.
    ///
    
    ///
    /// - The feed must be set.
    /// - The price returned by the oracle cannot be zero.
    ///
    
    
    function getPrice(string memory symbol) external view returns (uint256);

    
    function pricePrecision() external view returns (uint256);

    
    function pricePrecisionScalar() external view returns (uint256);

    
    function priceStalenessThreshold() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The feed must be set already.
    ///
    
    function deleteFeed(string memory symbol) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The number of decimals of the feed must be 8.
    ///
    
    
    function setFeed(IErc20 asset, IAggregatorV3 feed) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    ///
    
    function setPriceStalenessThreshold(uint256 newPriceStalenessThreshold) external;
}
// 
pragma solidity ^0.8.4;








contract ChainlinkOperator is
    IChainlinkOperator, // no dependency
    Ownable // one dependency
{
    /// PUBLIC STORAGE ///

    
    mapping(string => Feed) internal feeds;

    
    uint256 public constant override pricePrecision = 8;

    
    uint256 public constant override pricePrecisionScalar = 1.0e10;

    
    uint256 public override priceStalenessThreshold;

    constructor() Ownable() {
        priceStalenessThreshold = 1 days;
    }

    /// CONSTANT FUNCTIONS ///

    
    function getFeed(string memory symbol)
        external
        view
        override
        returns (
            IErc20,
            IAggregatorV3,
            bool
        )
    {
        return (feeds[symbol].asset, feeds[symbol].id, feeds[symbol].isSet);
    }

    
    function getNormalizedPrice(string memory symbol) external view override returns (uint256) {
        uint256 price = getPrice(symbol);
        uint256 normalizedPrice = price * pricePrecisionScalar;
        return normalizedPrice;
    }

    
    function getPrice(string memory symbol) public view override returns (uint256) {
        if (!feeds[symbol].isSet) {
            revert ChainlinkOperator__FeedNotSet(symbol);
        }
        (, int256 intPrice, , uint256 latestUpdateTimestamp, ) = IAggregatorV3(feeds[symbol].id).latestRoundData();
        if (block.timestamp - latestUpdateTimestamp > priceStalenessThreshold) {
            revert ChainlinkOperator__PriceStale(symbol);
        }
        if (intPrice <= 0) {
            revert ChainlinkOperator__PriceLessThanOrEqualToZero(symbol);
        }
        uint256 price = uint256(intPrice);
        return price;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function deleteFeed(string memory symbol) external override onlyOwner {
        // Checks
        if (!feeds[symbol].isSet) {
            revert ChainlinkOperator__FeedNotSet(symbol);
        }

        // Effects: delete the feed from storage.
        IAggregatorV3 feed = feeds[symbol].id;
        IErc20 asset = feeds[symbol].asset;
        delete feeds[symbol];

        emit DeleteFeed(asset, feed);
    }

    
    function setFeed(IErc20 asset, IAggregatorV3 feed) external override onlyOwner {
        string memory symbol = asset.symbol();

        // Checks: price precision.
        uint8 decimals = feed.decimals();
        if (decimals != pricePrecision) {
            revert ChainlinkOperator__DecimalsMismatch(symbol, decimals);
        }

        // Effects: put the feed into storage.
        feeds[symbol] = Feed({ asset: asset, id: feed, isSet: true });

        emit SetFeed(asset, feed);
    }

    
    function setPriceStalenessThreshold(uint256 newPriceStalenessThreshold) external override onlyOwner {
        // Effects: update storage.
        uint256 oldPriceStalenessThreshold = priceStalenessThreshold;
        priceStalenessThreshold = newPriceStalenessThreshold;

        emit SetPriceStalenessThreshold(oldPriceStalenessThreshold, newPriceStalenessThreshold);
    }
}

// 
pragma solidity >=0.8.4;




///
/// We have followed general OpenZeppelin guidelines: functions revert instead of returning
/// `false` on failure. This behavior is nonetheless conventional and does not conflict with
/// the with the expectations of Erc20 applications.
///
/// Additionally, an {Approval} event is emitted on calls to {transferFrom}. This allows
/// applications to reconstruct the allowance for all accounts just by listening to said
/// events. Other implementations of the Erc may not emit these events, as it isn't
/// required by the specification.
///
/// Finally, the non-standard {decreaseAllowance} and {increaseAllowance} functions have been
/// added to mitigate the well-known issues around setting allowances.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol
interface IErc20 {
    /// EVENTS ///

    
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// CONSTANT FUNCTIONS ///

    
    /// on behalf of `owner` through {transferFrom}. This is zero by default.
    ///
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);

    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function totalSupply() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// IMPORTANT: Beware that changing an allowance with this method brings the risk that someone may
    /// use both the old and the new allowance by unfortunate transaction ordering. One possible solution
    /// to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired
    /// value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    ///
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for problems described
    /// in {Erc20Interface-approve}.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    /// - `spender` must have allowance for the caller of at least `subtractedAmount`.
    function decreaseAllowance(address spender, uint256 subtractedAmount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for the problems described above.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    function increaseAllowance(address spender, uint256 addedAmount) external returns (bool);

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - `recipient` cannot be the zero address.
    /// - The caller must have a balance of at least `amount`.
    ///
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    /// `is then deducted from the caller's allowance.
    ///
    
    /// not required by the Erc. See the note at the beginning of {Erc20}.
    ///
    /// Requirements:
    ///
    /// - `sender` and `recipient` cannot be the zero address.
    /// - `sender` must have a balance of at least `amount`.
    /// - The caller must have approed `sender` to spent at least `amount` tokens.
    ///
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// 
pragma solidity >=0.8.4;




/// github.com/smartcontractkit/chainlink/blob/v1.2.0/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    /// getRoundData and latestRoundData should both raise "No data present" if they do not have
    /// data to report, instead of returning unset values which could be misinterpreted as
    /// actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}