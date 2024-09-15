// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// 
pragma solidity >=0.8.0;




interface INFTEDA {
    
    
    struct Auction {
        // the nft owner
        address nftOwner;
        // the nft token id
        uint256 auctionAssetID;
        // the nft contract address
        ERC721 auctionAssetContract;
        // How much the auction price will decay in each period
        // expressed as percent scaled by 1e18, i.e. 1e18 = 100%
        uint256 perPeriodDecayPercentWad;
        // the number of seconds in the period over which perPeriodDecay occurs
        uint256 secondsInPeriod;
        // the auction start price
        uint256 startPrice;
        // the payment asset and quote asset for startPrice
        ERC20 paymentAsset;
    }

    
    
    
    
    
    
    
    
    
    event StartAuction(
        uint256 indexed auctionID,
        uint256 indexed auctionAssetID,
        ERC721 indexed auctionAssetContract,
        address nftOwner,
        uint256 perPeriodDecayPercentWad,
        uint256 secondsInPeriod,
        uint256 startPrice,
        ERC20 paymentAsset
    );

    
    
    event EndAuction(uint256 indexed auctionID, uint256 price);

    
    
    
    function auctionCurrentPrice(Auction calldata auction) external view returns (uint256);

    
    
    
    
    function auctionID(Auction memory auction) external pure returns (uint256);

    
    
    function auctionStartTime(uint256 id) external view returns (uint256);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// 
pragma solidity >=0.8.0;








abstract contract NFTEDA is INFTEDA {
    using SafeTransferLib for ERC20;

    error AuctionExists();
    error InvalidAuction();
    
    
    error InsufficientPayment(uint256 received, uint256 expected);
    
    
    error MaxPriceTooLow(uint256 currentPrice, uint256 maxPrice);

    
    function auctionCurrentPrice(INFTEDA.Auction calldata auction) public view virtual returns (uint256) {
        uint256 id = auctionID(auction);
        uint256 startTime = auctionStartTime(id);
        if (startTime == 0) {
            revert InvalidAuction();
        }

        return _auctionCurrentPrice(id, startTime, auction);
    }

    
    function auctionID(INFTEDA.Auction memory auction) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(auction)));
    }

    
    function auctionStartTime(uint256 id) public view virtual returns (uint256);

    
    
    
    
    
    
    function _startAuction(INFTEDA.Auction memory auction) internal virtual returns (uint256 id) {
        id = auctionID(auction);

        if (auctionStartTime(id) != 0) {
            revert AuctionExists();
        }

        _setAuctionStartTime(id);

        emit StartAuction(
            id,
            auction.auctionAssetID,
            auction.auctionAssetContract,
            auction.nftOwner,
            auction.perPeriodDecayPercentWad,
            auction.secondsInPeriod,
            auction.startPrice,
            auction.paymentAsset
            );
    }

    
    
    
    function _purchaseNFT(INFTEDA.Auction memory auction, uint256 maxPrice, address sendTo)
        internal
        virtual
        returns (uint256 startTime, uint256 price)
    {
        uint256 id;
        (id, startTime, price) = _checkAuctionAndReturnDetails(auction);

        if (price > maxPrice) {
            revert MaxPriceTooLow(price, maxPrice);
        }

        _clearAuctionState(id);

        auction.auctionAssetContract.safeTransferFrom(address(this), sendTo, auction.auctionAssetID);

        auction.paymentAsset.safeTransferFrom(msg.sender, address(this), price);

        emit EndAuction(id, price);
    }

    function _checkAuctionAndReturnDetails(INFTEDA.Auction memory auction)
        internal
        view
        returns (uint256 id, uint256 startTime, uint256 price)
    {
        id = auctionID(auction);
        startTime = auctionStartTime(id);

        if (startTime == 0) {
            revert InvalidAuction();
        }
        price = _auctionCurrentPrice(id, startTime, auction);
    }

    
    
    
    function _setAuctionStartTime(uint256 id) internal virtual;

    
    
    
    function _clearAuctionState(uint256 id) internal virtual;

    
    
    
    
    
    
    
    function _auctionCurrentPrice(uint256 id, uint256 startTime, INFTEDA.Auction memory auction)
        internal
        view
        virtual
        returns (uint256)
    {
        return EDAPrice.currentPrice(
            auction.startPrice, block.timestamp - startTime, auction.secondsInPeriod, auction.perPeriodDecayPercentWad
        );
    }
}

// 
pragma solidity >=0.8.0;



interface IFundingRateController {
    
    
    event UpdateTarget(uint256 newTarget);

    event SetFundingPeriod(uint256 fundingPeriod);

    error AlreadyInitialized();
    error FundingPeriodTooShort();
    error FundingPeriodTooLong();

    
    
    
    function updateTarget() external returns (uint256);

    
    
    function lastUpdated() external view returns (uint256);

    
    
    /// value, then funding rates are 0 and newTarget() will equal target().
    
    /// Example: if papr has 18 decimals and underlying 6 decimals, then
    ///  target = 1e6 means 1e18 papr is worth 1e6 underlying, according to target
    function target() external view returns (uint256);

    
    
    
    
    function newTarget() external view returns (uint256);

    
    
    function mark() external view returns (uint256);

    
    /// reflect in-kind funding payments via target() changing in value
    
    function papr() external view returns (ERC20);

    
    
    function underlying() external view returns (ERC20);

    
    
    /// on funding => target, longer period means the inverse
    
    function fundingPeriod() external view returns (uint256);
}

// 
pragma solidity >=0.8.0;



interface IUniswapOracleFundingRateController is IFundingRateController {
    
    
    event SetPool(address indexed pool);

    
    /// that's tokens do not match pool()
    error PoolTokensDoNotMatch();
    error InvalidUniswapV3Pool();

    
    
    function pool() external returns (address);
}

// 
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}

// 
pragma solidity ^0.8.4;





/// Multicallable is NOT SAFE for use in contracts with checks / requires on `msg.value`
/// (e.g. in NFT minting / auction contracts) without a suitable nonce mechanism.
/// It WILL open up your contract to double-spend vulnerabilities / exploits.
/// See: (https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong/)
abstract contract Multicallable {
    
    /// and store the `abi.encode` formatted results of each `DELEGATECALL` into `results`.
    /// If any of the `DELEGATECALL`s reverts, the entire transaction is reverted,
    /// and the error is bubbled up.
    function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
        assembly {
            if data.length {
                results := mload(0x40) // Point `results` to start of free memory.
                mstore(results, data.length) // Store `data.length` into `results`.
                results := add(results, 0x20)

                // `shl` 5 is equivalent to multiplying by 0x20.
                let end := shl(5, data.length)
                // Copy the offsets from calldata into memory.
                calldatacopy(results, data.offset, end)
                // Pointer to the top of the memory (i.e. start of the free memory).
                let memPtr := add(results, end)
                end := add(results, end)

                for {} 1 {} {
                    // The offset of the current bytes in the calldata.
                    let o := add(data.offset, mload(results))
                    // Copy the current bytes from calldata to the memory.
                    calldatacopy(
                        memPtr,
                        add(o, 0x20), // The offset of the current bytes' bytes.
                        calldataload(o) // The length of the current bytes.
                    )
                    if iszero(delegatecall(gas(), address(), memPtr, calldataload(o), 0x00, 0x00)) {
                        // Bubble up the revert if the delegatecall reverts.
                        returndatacopy(0x00, 0x00, returndatasize())
                        revert(0x00, returndatasize())
                    }
                    // Append the current `memPtr` into `results`.
                    mstore(results, memPtr)
                    results := add(results, 0x20)
                    // Append the `returndatasize()`, and the return data.
                    mstore(memPtr, returndatasize())
                    returndatacopy(add(memPtr, 0x20), 0x00, returndatasize())
                    // Advance the `memPtr` by `returndatasize() + 0x20`,
                    // rounded up to the next multiple of 32.
                    memPtr := and(add(add(memPtr, returndatasize()), 0x3f), 0xffffffffffffffe0)
                    if iszero(lt(results, end)) { break }
                }
                // Restore `results` and allocate memory for it.
                results := mload(0x40)
                mstore(0x40, memPtr)
            }
        }
    }
}

// 
pragma solidity >=0.8.0;





abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}



abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolActions {
    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



/// per transaction
interface IUniswapV3PoolState {
    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.8.0;






contract NFTEDAStarterIncentive is NFTEDA {
    struct AuctionState {
        
        uint96 startTime;
        
        address starter;
    }

    
    
    /// expressed as a percent scaled by 1e18
    /// i.e. 1e18 = 100%
    event SetAuctionCreatorDiscount(uint256 discount);

    
    /// receive, compared to the current price
    /// 1e18 = 100%
    uint256 public auctionCreatorDiscountPercentWad;
    uint256 internal _pricePercentAfterDiscount;

    
    
    mapping(uint256 => AuctionState) public auctionState;

    constructor(uint256 _auctionCreatorDiscountPercentWad) {
        _setCreatorDiscount(_auctionCreatorDiscountPercentWad);
    }

    
    function auctionStartTime(uint256 id) public view virtual override returns (uint256) {
        return auctionState[id].startTime;
    }

    
    function _setAuctionStartTime(uint256 id) internal virtual override {
        auctionState[id] = AuctionState({startTime: uint96(block.timestamp), starter: msg.sender});
    }

    
    function _clearAuctionState(uint256 id) internal virtual override {
        delete auctionState[id];
    }

    
    function _auctionCurrentPrice(uint256 id, uint256 startTime, INFTEDA.Auction memory auction)
        internal
        view
        virtual
        override
        returns (uint256)
    {
        uint256 price = super._auctionCurrentPrice(id, startTime, auction);

        if (msg.sender == auctionState[id].starter) {
            price = FixedPointMathLib.mulWadUp(price, _pricePercentAfterDiscount);
        }

        return price;
    }

    
    
    /// scaled by 1e18, i.e. 1e18 = 1 = 100%
    function _setCreatorDiscount(uint256 _auctionCreatorDiscountPercentWad) internal virtual {
        auctionCreatorDiscountPercentWad = _auctionCreatorDiscountPercentWad;
        _pricePercentAfterDiscount = FixedPointMathLib.WAD - _auctionCreatorDiscountPercentWad;

        emit SetAuctionCreatorDiscount(_auctionCreatorDiscountPercentWad);
    }
}

// 
pragma solidity >=0.8.0;





contract ReservoirOracleUnderwriter {
    
    
    
    
    
    
    enum PriceKind {
        SPOT,
        TWAP,
        LOWER,
        UPPER
    }

    
    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    
    struct OracleInfo {
        ReservoirOracle.Message message;
        Sig sig;
    }

    
    
    struct CachedPrice {
        // the timestamp the price was cached
        uint40 timestamp;
        // the oracle price of the NFT collection
        uint216 price;
    }

    error IncorrectOracleSigner();
    error WrongIdentifierFromOracleMessage();
    error WrongCurrencyFromOracleMessage();
    error OracleMessageTimestampInvalid();

    
    uint256 constant TWAP_SECONDS = 7 days;

    
    uint256 constant VALID_FOR = 20 minutes;

    
    bytes32 constant MESSAGE_SIG_HASH = keccak256("Message(bytes32 id,bytes payload,uint256 timestamp)");
    bytes32 constant TOP_BID_SIG_HASH =
        keccak256("ContractWideCollectionTopBidPrice(uint8 kind,uint256 twapSeconds,address contract)");

    
    
    uint256 public constant MAX_PER_SECOND_PRICE_GROWTH = 0.5e18 / uint256(1 days);

    
    address public immutable oracleSigner;

    
    address public immutable quoteCurrency;

    
    mapping(ERC721 => CachedPrice) public cachedPriceForAsset;

    constructor(address _oracleSigner, address _quoteCurrency) {
        oracleSigner = _oracleSigner;
        quoteCurrency = _quoteCurrency;
    }

    
    
    
    
    
    
    
    
    
    ///         MAX_PER_SECOND_PRICE_GROWTH if guard = true and oracleInfo price > max
    function underwritePriceForCollateral(ERC721 asset, PriceKind priceKind, OracleInfo memory oracleInfo, bool guard)
        public
        returns (uint256)
    {
        address signerAddress = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    // EIP-712 structured-data hash
                    keccak256(
                        abi.encode(
                            MESSAGE_SIG_HASH,
                            oracleInfo.message.id,
                            keccak256(oracleInfo.message.payload),
                            oracleInfo.message.timestamp
                        )
                    )
                )
            ),
            oracleInfo.sig.v,
            oracleInfo.sig.r,
            oracleInfo.sig.s
        );

        if (signerAddress != oracleSigner) {
            revert IncorrectOracleSigner();
        }

        bytes32 expectedId = keccak256(abi.encode(TOP_BID_SIG_HASH, priceKind, TWAP_SECONDS, asset));

        if (oracleInfo.message.id != expectedId) {
            revert WrongIdentifierFromOracleMessage();
        }

        if (
            oracleInfo.message.timestamp > block.timestamp || oracleInfo.message.timestamp + VALID_FOR < block.timestamp
        ) {
            revert OracleMessageTimestampInvalid();
        }

        (address oracleQuoteCurrency, uint256 oraclePrice) = abi.decode(oracleInfo.message.payload, (address, uint256));
        if (oracleQuoteCurrency != quoteCurrency) {
            revert WrongCurrencyFromOracleMessage();
        }

        return guard ? _cacheAndReturnPriceOrMaxPrice(asset, oraclePrice) : oraclePrice;
    }

    
    
    
    ///      increase debt events for the same asset
    function _cacheAndReturnPriceOrMaxPrice(ERC721 asset, uint256 price) internal returns (uint256) {
        CachedPrice memory cached = cachedPriceForAsset[asset];
        if (cached.price != 0 && cached.price < price) {
            uint256 timeElapsed = block.timestamp - cached.timestamp;
            if (timeElapsed > 2 days) {
                timeElapsed = 2 days;
            }
            uint256 max = FixedPointMathLib.mulWadDown(
                cached.price, (MAX_PER_SECOND_PRICE_GROWTH * timeElapsed) + FixedPointMathLib.WAD
            );
            if (price > max) {
                price = max;
            }
        }

        // We are OK with not checking for price overflow when casting to uint216
        // as we do not consider values greater than this to be a practical possibility
        cachedPriceForAsset[asset] = CachedPrice({timestamp: uint40(block.timestamp), price: uint216(price)});

        return price;
    }
}

//
pragma solidity >=0.8.0;









contract UniswapOracleFundingRateController is IUniswapOracleFundingRateController {
    
    ERC20 public immutable underlying;
    
    ERC20 public immutable papr;
    
    uint256 public fundingPeriod;
    
    address public pool;
    
    uint256 public immutable targetMarkRatioMax;
    
    uint256 public immutable targetMarkRatioMin;
    // single slot, write together
    uint128 internal _target;
    int56 internal _lastCumulativeTick;
    uint48 internal _lastUpdated;
    int24 internal _lastTwapTick;

    constructor(ERC20 _underlying, ERC20 _papr, uint256 _targetMarkRatioMax, uint256 _targetMarkRatioMin) {
        underlying = _underlying;
        papr = _papr;

        targetMarkRatioMax = _targetMarkRatioMax;
        targetMarkRatioMin = _targetMarkRatioMin;

        _setFundingPeriod(90 days);
    }

    
    function updateTarget() public override returns (uint256 nTarget) {
        if (_lastUpdated == block.timestamp) {
            return _target;
        }

        (int56 latestCumulativeTick, int24 latestTwapTick) = _latestTwapTickAndTickCumulative();
        nTarget = _newTarget(latestTwapTick, _target);

        _target = SafeCastLib.safeCastTo128(nTarget);
        // will not overflow for 8000 years
        _lastUpdated = uint48(block.timestamp);
        _lastCumulativeTick = latestCumulativeTick;
        _lastTwapTick = latestTwapTick;

        emit UpdateTarget(nTarget);
    }

    
    function newTarget() public view override returns (uint256) {
        if (_lastUpdated == block.timestamp) {
            return _target;
        }
        (, int24 latestTwapTick) = _latestTwapTickAndTickCumulative();
        return _newTarget(latestTwapTick, _target);
    }

    
    function mark() public view returns (uint256) {
        if (_lastUpdated == block.timestamp) {
            return _mark(_lastTwapTick);
        }
        (, int24 latestTwapTick) = _latestTwapTickAndTickCumulative();
        return _mark(latestTwapTick);
    }

    
    function lastUpdated() external view override returns (uint256) {
        return _lastUpdated;
    }

    
    function target() external view override returns (uint256) {
        return _target;
    }

    
    
    /// match papr and underlying
    
    
    function _init(uint256 _target_, address _pool) internal {
        if (_lastUpdated != 0) revert AlreadyInitialized();

        _setPool(_pool);

        _lastUpdated = uint48(block.timestamp);
        _target = SafeCastLib.safeCastTo128(_target_);
        _lastCumulativeTick = OracleLibrary.latestCumulativeTick(pool);
        _lastTwapTick = UniswapHelpers.poolCurrentTick(pool);

        emit UpdateTarget(_target_);
    }

    
    
    
    function _setPool(address _pool) internal {
        address currentPool = pool;
        if (currentPool != address(0) && !UniswapHelpers.poolsHaveSameTokens(currentPool, _pool)) {
            revert PoolTokensDoNotMatch();
        }
        if (!UniswapHelpers.isUniswapPool(_pool)) revert InvalidUniswapV3Pool();

        pool = _pool;

        emit SetPool(_pool);
    }

    
    
    function _setFundingPeriod(uint256 _fundingPeriod) internal {
        if (_fundingPeriod < 28 days) revert FundingPeriodTooShort();
        if (_fundingPeriod > 365 days) revert FundingPeriodTooLong();

        fundingPeriod = _fundingPeriod;

        emit SetFundingPeriod(_fundingPeriod);
    }

    
    function _newTarget(int24 latestTwapTick, uint256 cachedTarget) internal view returns (uint256) {
        return FixedPointMathLib.mulWadDown(cachedTarget, _multiplier(_mark(latestTwapTick), cachedTarget));
    }

    
    function _mark(int24 twapTick) internal view returns (uint256) {
        return OracleLibrary.getQuoteAtTick(twapTick, 1e18, address(papr), address(underlying));
    }

    
    function _latestTwapTickAndTickCumulative() internal view returns (int56 tickCumulative, int24 twapTick) {
        tickCumulative = OracleLibrary.latestCumulativeTick(pool);
        twapTick = OracleLibrary.timeWeightedAverageTick(
            _lastCumulativeTick, tickCumulative, int56(uint56(block.timestamp - _lastUpdated))
        );
    }

    
    
    /// 1 = 1e18, i.e.
    /// > 1e18 means positive funding rate
    /// < 1e18 means negative funding rate
    /// sub 1e18 to get percent change
    
    function _multiplier(uint256 _mark_, uint256 cachedTarget) internal view returns (uint256) {
        uint256 period = block.timestamp - _lastUpdated;
        uint256 periodRatio = FixedPointMathLib.divWadDown(period, fundingPeriod);
        uint256 targetMarkRatio;
        if (_mark_ == 0) {
            targetMarkRatio = targetMarkRatioMax;
        } else {
            targetMarkRatio = FixedPointMathLib.divWadDown(cachedTarget, _mark_);
            if (targetMarkRatio > targetMarkRatioMax) {
                targetMarkRatio = targetMarkRatioMax;
            } else if (targetMarkRatio < targetMarkRatioMin) {
                targetMarkRatio = targetMarkRatioMin;
            }
        }

        // safe to cast because targetMarkRatio > 0
        return uint256(FixedPointMathLib.powWad(int256(targetMarkRatio), int256(periodRatio)));
    }
}

// 
pragma solidity >=0.8.0;






interface IPaprController {
    
    struct Collateral {
        
        ERC721 addr;
        
        uint256 id;
    }

    
    struct VaultInfo {
        
        uint16 count;
        
        uint16 auctionCount;
        
        uint40 latestAuctionStartTime;
        
        uint184 debt;
    }

    
    
    
    struct SwapParams {
        
        uint256 amount;
        
        uint256 minOut;
        
        uint160 sqrtPriceLimitX96;
        
        address swapFeeTo;
        
        uint256 swapFeeBips;
        
        uint256 deadline;
    }

    
    struct OnERC721ReceivedArgs {
        
        address proceedsTo;
        
        uint256 debt;
        
        SwapParams swapParams;
        
        ReservoirOracleUnderwriter.OracleInfo oracleInfo;
    }

    
    struct CollateralAllowedConfig {
        ERC721 collateral;
        bool allowed;
    }

    
    
    
    
    
    event IncreaseDebt(address indexed account, ERC721 indexed collateralAddress, uint256 amount);

    
    
    
    
    event AddCollateral(address indexed account, ERC721 indexed collateralAddress, uint256 indexed tokenId);

    
    
    
    
    event RemoveCollateral(address indexed account, ERC721 indexed collateralAddress, uint256 indexed tokenId);

    
    
    
    
    event ReduceDebt(address indexed account, ERC721 indexed collateralAddress, uint256 amount);

    
    
    
    event AllowCollateral(ERC721 indexed collateral, bool isAllowed);

    
    
    event UpdateFundingPeriod(uint256 newPeriod);

    
    
    event UpdatePool(address indexed newPool);

    
    
    event UpdateLiquidationsLocked(bool locked);

    
    
    error ExceedsMaxDebt(uint256 vaultDebt, uint256 maxDebt);

    error InvalidCollateral();

    error MinAuctionSpacing();

    error NotLiquidatable();

    error InvalidCollateralAccountPair();

    error AccountHasNoDebt();

    error OnlyCollateralOwner();

    error DebtAmountExceedsUint184();

    error CollateralAddressesDoNotMatch();

    error LiquidationsLocked();

    
    
    
    function addCollateral(IPaprController.Collateral[] calldata collateral) external;

    
    
    
    
    
    
    function removeCollateral(
        address sendTo,
        IPaprController.Collateral[] calldata collateralArr,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external;

    
    
    
    
    
    
    function increaseDebt(
        address mintTo,
        ERC721 asset,
        uint256 amount,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external;

    
    
    
    
    function reduceDebt(address account, ERC721 asset, uint256 amount) external;

    
    
    
    
    
    
    
    function increaseDebtAndSell(
        address proceedsTo,
        ERC721 collateralAsset,
        IPaprController.SwapParams calldata params,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external returns (uint256);

    
    
    
    
    
    function buyAndReduceDebt(address account, ERC721 collateralAsset, IPaprController.SwapParams calldata params)
        external
        returns (uint256);

    
    
    
    
    
    function purchaseLiquidationAuctionNFT(
        INFTEDA.Auction calldata auction,
        uint256 maxPrice,
        address sendTo,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external;

    
    
    
    
    
    
    function startLiquidationAuction(
        address account,
        IPaprController.Collateral calldata collateral,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external returns (INFTEDA.Auction memory auction);

    
    
    
    function setPool(address _pool) external;

    
    
    function setFundingPeriod(uint256 _fundingPeriod) external;

    
    
    
    function setLiquidationsLocked(bool locked) external;

    
    
    
    function setAllowedCollateral(IPaprController.CollateralAllowedConfig[] calldata collateralConfigs) external;

    
    
    
    function collateralOwner(ERC721 collateral, uint256 tokenId) external view returns (address);

    
    
    function isAllowed(ERC721 collateral) external view returns (bool);

    
    
    
    function liquidationsLocked() external view returns (bool);

    
    function token0IsUnderlying() external view returns (bool);

    
    function maxLTV() external view returns (uint256);

    
    function liquidationAuctionMinSpacing() external view returns (uint256);

    
    function liquidationPenaltyBips() external view returns (uint256);

    
    
    
    function maxDebt(uint256 totalCollateraValue) external view returns (uint256);

    
    
    
    
    function vaultInfo(address account, ERC721 asset) external view returns (IPaprController.VaultInfo memory);
}
// 
pragma solidity >=0.8.0;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (type(uint256).max - denominator + 1) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        unchecked {
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}

// 
pragma solidity >=0.8.0;



/// prices between 2**-128 and 2**128
library TickMath {
    
    int24 internal constant MIN_TICK = -887272;
    
    int24 internal constant MAX_TICK = -MIN_TICK;

    
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            require(absTick <= uint256(int256(MAX_TICK)), "T");

            uint256 ratio = absTick & 0x1 != 0
                ? 0xfffcb933bd6fad37aa2d162d1a594001
                : 0x100000000000000000000000000000000;
            if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
            if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
            if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

            if (tick > 0) ratio = type(uint256).max / ratio;

            // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
            // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
            // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
            sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
        }
    }

    
    
    /// ever return.
    
    
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        unchecked {
            // second inequality must be < because the price can never reach the price at the max tick
            require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
            uint256 ratio = uint256(sqrtPriceX96) << 32;

            uint256 r = ratio;
            uint256 msb = 0;

            assembly {
                let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(5, gt(r, 0xFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(4, gt(r, 0xFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(3, gt(r, 0xFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(2, gt(r, 0xF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(1, gt(r, 0x3))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := gt(r, 0x1)
                msb := or(msb, f)
            }

            if (msb >= 128) r = ratio >> (msb - 127);
            else r = ratio << (127 - msb);

            int256 log_2 = (int256(msb) - 128) << 64;

            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(63, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(62, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(61, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(60, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(59, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(58, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(57, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(56, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(55, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(54, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(53, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(52, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(51, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(50, f))
            }

            int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

            int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
            int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

            tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
        }
    }

    function getTicks(int24 tickSpacing) internal pure returns (int24 minTick, int24 maxTick) {
        minTick = (MIN_TICK / tickSpacing) * tickSpacing;
        maxTick = (MAX_TICK / tickSpacing) * tickSpacing;
    }
}

// 
pragma solidity ^0.8.13;

// Inspired by https://github.com/ZeframLou/trustus
abstract contract ReservoirOracle {
    // --- Structs ---

    struct Message {
        bytes32 id;
        bytes payload;
        // The UNIX timestamp when the message was signed by the oracle
        uint256 timestamp;
        // ECDSA signature or EIP-2098 compact signature
        bytes signature;
    }

    // --- Errors ---

    error InvalidMessage();

    // --- Fields ---

    address immutable RESERVOIR_ORACLE_ADDRESS;

    // --- Constructor ---

    constructor(address reservoirOracleAddress) {
        RESERVOIR_ORACLE_ADDRESS = reservoirOracleAddress;
    }

    // --- Internal methods ---

    function _verifyMessage(
        bytes32 id,
        uint256 validFor,
        Message memory message
    ) internal view virtual returns (bool success) {
        // Ensure the message matches the requested id
        if (id != message.id) {
            return false;
        }

        // Ensure the message timestamp is valid
        if (
            message.timestamp > block.timestamp ||
            message.timestamp + validFor < block.timestamp
        ) {
            return false;
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        // Extract the individual signature fields from the signature
        bytes memory signature = message.signature;
        if (signature.length == 64) {
            // EIP-2098 compact signature
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
                s := and(
                    vs,
                    0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
                )
                v := add(shr(255, vs), 27)
            }
        } else if (signature.length == 65) {
            // ECDSA signature
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else {
            return false;
        }

        address signerAddress = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    // EIP-712 structured-data hash
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Message(bytes32 id,bytes payload,uint256 timestamp)"
                            ),
                            message.id,
                            keccak256(message.payload),
                            message.timestamp
                        )
                    )
                )
            ),
            v,
            r,
            s
        );

        // Ensure the signer matches the designated oracle address
        return signerAddress == RESERVOIR_ORACLE_ADDRESS;
    }
}

// 
pragma solidity >=0.8.0;



abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }
}

// 
pragma solidity >=0.8.0;



library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Equivalent to x to the power of y because x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)
        return expWad((lnWad(x) * y) / int256(WAD)); // Using ln(x) means x must be greater than 0.
    }

    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is < 0.5 we return zero. This happens when
            // x <= floor(log(0.5e18) * 1e18) ~ -42e18
            if (x <= -42139678854452767551) return 0;

            // When the result is > (2**255 - 1) / 1e18 we can not represent it as an
            // int. This happens when x >= floor(log((2**255 - 1) / 1e18) * 1e18) ~ 135.
            if (x >= 135305999368893231589) revert("EXP_OVERFLOW");

            // x is now in the range (-42, 136) * 1e18. Convert to (-42, 136) * 2**96
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5**18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2**95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // k is in the range [-61, 195].

            // Evaluate using a (6, 7)-term rational approximation.
            // p is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r should be in the range (0.09, 0.25) * 2**96.

            // We now need to multiply r by:
            // * the scale factor s = ~6.031367120.
            // * the 2**k factor from the range reduction.
            // * the 1e18 / 2**96 factor for base conversion.
            // We do this all at once, with an intermediate result in 2**213
            // basis, so the final right shift is always by a positive amount.
            r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));
        }
    }

    function lnWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            require(x > 0, "UNDEFINED");

            // We want to convert x from 10**18 fixed point to 2**96 fixed point.
            // We do this by multiplying by 2**96 / 10**18. But since
            // ln(x * C) = ln(x) + ln(C), we can simply do nothing here
            // and add ln(2**96 / 10**18) at the end.

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            int256 k = int256(log2(uint256(x))) - 96;
            x <<= uint256(159 - k);
            x = int256(uint256(x) >> 159);

            // Evaluate using a (8, 8)-term rational approximation.
            // p is made monic, we will multiply by a scale factor later.
            int256 p = x + 3273285459638523848632254066296;
            p = ((p * x) >> 96) + 24828157081833163892658089445524;
            p = ((p * x) >> 96) + 43456485725739037958740375743393;
            p = ((p * x) >> 96) - 11111509109440967052023855526967;
            p = ((p * x) >> 96) - 45023709667254063763336534515857;
            p = ((p * x) >> 96) - 14706773417378608786704636184526;
            p = p * x - (795164235651350426258249787498 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            // q is monic by convention.
            int256 q = x + 5573035233440673466300451813936;
            q = ((q * x) >> 96) + 71694874799317883764090561454958;
            q = ((q * x) >> 96) + 283447036172924575727196451306956;
            q = ((q * x) >> 96) + 401686690394027663651624208769553;
            q = ((q * x) >> 96) + 204048457590392012362485061816622;
            q = ((q * x) >> 96) + 31853899698501571402653359427138;
            q = ((q * x) >> 96) + 909429971244387300277376558375;
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial is known not to have zeros in the domain.
                // No scaling required because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r is in the range (0, 0.125) * 2**96

            // Finalization, we need to:
            // * multiply by the scale factor s = 5.549…
            // * add ln(2**96 / 10**18)
            // * add k * ln(2)
            // * multiply by 10**18 / 2**96 = 5**18 >> 78

            // mul s * 5e18 * 2**96, base is now 5**18 * 2**192
            r *= 1677202110996718588342820967067443963516166;
            // add ln(2) * k * 5e18 * 2**192
            r += 16597577552685614221487285958193947469193820559219878177908093499208371 * k;
            // add ln(2**96 / 10**18) * 5e18 * 2**192
            r += 600920179829731861736702779321621459595472258049074101567377883020018308;
            // base conversion: mul 2**18 / 2**192
            r >>= 174;
        }
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // Divide z by the denominator.
            z := div(z, denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Store x * y in z for now.
            z := mul(x, y)

            // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }

            // First, divide z - 1 by the denominator and add 1.
            // We allow z - 1 to underflow if z is 0, because we multiply the
            // end result by 0 if z is zero, ensuring we return 0 if z is zero.
            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function log2(uint256 x) internal pure returns (uint256 r) {
        require(x > 0, "UNDEFINED");

        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := or(r, shl(1, lt(0x3, shr(r, x))))
            r := or(r, lt(0x1, shr(r, x)))
        }
    }

    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // z will equal 0 if y is 0, unlike in Solidity where it will revert.
            z := mod(x, y)
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // z will equal 0 if y is 0, unlike in Solidity where it will revert.
            z := div(x, y)
        }
    }

    
    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            // Add 1 to x * y if x % y > 0.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}

// 
pragma solidity >=0.8.0;



library SafeCastLib {
    function safeCastTo248(uint256 x) internal pure returns (uint248 y) {
        require(x < 1 << 248);

        y = uint248(x);
    }

    function safeCastTo224(uint256 x) internal pure returns (uint224 y) {
        require(x < 1 << 224);

        y = uint224(x);
    }

    function safeCastTo192(uint256 x) internal pure returns (uint192 y) {
        require(x < 1 << 192);

        y = uint192(x);
    }

    function safeCastTo160(uint256 x) internal pure returns (uint160 y) {
        require(x < 1 << 160);

        y = uint160(x);
    }

    function safeCastTo128(uint256 x) internal pure returns (uint128 y) {
        require(x < 1 << 128);

        y = uint128(x);
    }

    function safeCastTo96(uint256 x) internal pure returns (uint96 y) {
        require(x < 1 << 96);

        y = uint96(x);
    }

    function safeCastTo64(uint256 x) internal pure returns (uint64 y) {
        require(x < 1 << 64);

        y = uint64(x);
    }

    function safeCastTo32(uint256 x) internal pure returns (uint32 y) {
        require(x < 1 << 32);

        y = uint32(x);
    }

    function safeCastTo8(uint256 x) internal pure returns (uint8 y) {
        require(x < 1 << 8);

        y = uint8(x);
    }
}

// 
pragma solidity >=0.8.0;






library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(0, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(4, from) // Append the "from" argument.
            mstore(36, to) // Append the "to" argument.
            mstore(68, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because that's the total length of our calldata (4 + 32 * 3)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 100, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(0, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(4, to) // Append the "to" argument.
            mstore(36, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because that's the total length of our calldata (4 + 32 * 2)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 68, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // We'll write our calldata to this slot below, but restore it later.
            let memPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(0, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(4, to) // Append the "to" argument.
            mstore(36, amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because that's the total length of our calldata (4 + 32 * 2)
                // Counterintuitively, this call() must be positioned after the or() in the
                // surrounding and() because and() evaluates its arguments from right to left.
                call(gas(), token, 0, 0, 68, 0, 32)
            )

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, memPointer) // Restore the memPointer.
        }

        require(success, "APPROVE_FAILED");
    }
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

// 
pragma solidity >=0.5.0;










/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// 
pragma solidity >=0.5.0;



library SafeCast {
    
    
    
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    
    
    
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    
    
    
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}

// 
pragma solidity >=0.8.0;



library EDAPrice {
    
    
    
    
    
    
    
    
    
    
    function currentPrice(
        uint256 startPrice,
        uint256 secondsElapsed,
        uint256 secondsInPeriod,
        uint256 perPeriodDecayPercentWad
    ) internal pure returns (uint256) {
        uint256 ratio = FixedPointMathLib.divWadDown(secondsElapsed, secondsInPeriod);
        uint256 percentWadRemainingPerPeriod = FixedPointMathLib.WAD - perPeriodDecayPercentWad;
        // percentWadRemainingPerPeriod can be safely cast because < 1e18
        // ratio can be safely cast because will not overflow unless ratio > int256.max,
        // which would require secondsElapsed > int256.max, i.e. > 5.78e76 or 1.8e69 years
        int256 multiplier = FixedPointMathLib.powWad(int256(percentWadRemainingPerPeriod), int256(ratio));
        // casting to uint256 is safe because percentWadRemainingPerPeriod is non negative
        uint256 price = startPrice * uint256(multiplier);
        return (price / FixedPointMathLib.WAD);
    }
}

//
pragma solidity =0.8.17;















contract PaprController is
    IPaprController,
    UniswapOracleFundingRateController,
    ERC721TokenReceiver,
    Multicallable,
    Ownable2Step,
    ReservoirOracleUnderwriter,
    NFTEDAStarterIncentive
{
    using SafeTransferLib for ERC20;

    
    uint256 public constant BIPS_ONE = 1e4;

    bool public override liquidationsLocked;

    
    bool public immutable override token0IsUnderlying;

    
    uint256 public immutable override maxLTV;

    
    uint256 public immutable override liquidationAuctionMinSpacing = 2 days;

    uint256 private immutable perPeriodAuctionDecayWAD = 0.7e18;

    uint256 private immutable auctionDecayPeriod = 1 days;

    uint256 private immutable auctionStartPriceMultiplier = 3;

    
    
    uint256 public immutable override liquidationPenaltyBips = 1000;

    
    mapping(ERC721 => mapping(uint256 => address)) public override collateralOwner;

    
    mapping(ERC721 => bool) public override isAllowed;

    
    mapping(address => mapping(ERC721 => IPaprController.VaultInfo)) private _vaultInfo;

    
    /// e.g. does not check whether underlying or oracleSigner are address(0)
    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxLTV,
        uint256 indexMarkRatioMax,
        uint256 indexMarkRatioMin,
        ERC20 underlying,
        address oracleSigner
    )
        NFTEDAStarterIncentive(1e17)
        UniswapOracleFundingRateController(underlying, new PaprToken(name, symbol), indexMarkRatioMax, indexMarkRatioMin)
        ReservoirOracleUnderwriter(oracleSigner, address(underlying))
    {
        maxLTV = _maxLTV;
        token0IsUnderlying = address(underlying) < address(papr);
        uint256 underlyingONE = 10 ** underlying.decimals();
        uint160 initSqrtRatio;

        // initialize the pool at 1:1
        if (token0IsUnderlying) {
            initSqrtRatio = UniswapHelpers.oneToOneSqrtRatio(underlyingONE, 1e18);
        } else {
            initSqrtRatio = UniswapHelpers.oneToOneSqrtRatio(1e18, underlyingONE);
        }

        address _pool = UniswapHelpers.deployAndInitPool(address(underlying), address(papr), 10000, initSqrtRatio);

        _init(underlyingONE, _pool);
    }

    
    function addCollateral(IPaprController.Collateral[] calldata collateralArr) external override {
        for (uint256 i = 0; i < collateralArr.length;) {
            _addCollateralToVault(msg.sender, collateralArr[i]);
            collateralArr[i].addr.transferFrom(msg.sender, address(this), collateralArr[i].id);
            unchecked {
                ++i;
            }
        }
    }

    
    function removeCollateral(
        address sendTo,
        IPaprController.Collateral[] calldata collateralArr,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external override {
        uint256 cachedTarget = updateTarget();
        uint256 oraclePrice;
        ERC721 collateralAddr;

        for (uint256 i = 0; i < collateralArr.length;) {
            if (i == 0) {
                collateralAddr = collateralArr[i].addr;
                oraclePrice = underwritePriceForCollateral(
                    collateralAddr, ReservoirOracleUnderwriter.PriceKind.LOWER, oracleInfo, true
                );
            } else {
                if (collateralAddr != collateralArr[i].addr) {
                    revert CollateralAddressesDoNotMatch();
                }
            }

            _removeCollateral(sendTo, collateralArr[i], oraclePrice, cachedTarget);

            unchecked {
                ++i;
            }
        }
    }

    
    function increaseDebt(
        address mintTo,
        ERC721 asset,
        uint256 amount,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external override {
        _increaseDebt({account: msg.sender, asset: asset, mintTo: mintTo, amount: amount, oracleInfo: oracleInfo});
    }

    
    function reduceDebt(address account, ERC721 asset, uint256 amount) external override {
        uint256 debt = _vaultInfo[account][asset].debt;
        _reduceDebt({
            account: account,
            asset: asset,
            burnFrom: msg.sender,
            accountDebt: debt,
            amountToReduce: amount > debt ? debt : amount
        });
    }

    
    
    /// to avoid approval call and save gas
    
    
    
    
    function onERC721Received(address, address from, uint256 _id, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        IPaprController.OnERC721ReceivedArgs memory request = abi.decode(data, (IPaprController.OnERC721ReceivedArgs));

        IPaprController.Collateral memory collateral = IPaprController.Collateral(ERC721(msg.sender), _id);

        _addCollateralToVault(from, collateral);

        if (request.swapParams.minOut > 0) {
            _increaseDebtAndSell(from, request.proceedsTo, ERC721(msg.sender), request.swapParams, request.oracleInfo);
        } else if (request.debt > 0) {
            _increaseDebt(from, collateral.addr, request.proceedsTo, request.debt, request.oracleInfo);
        }

        return ERC721TokenReceiver.onERC721Received.selector;
    }

    /// CONVENIENCE SWAP FUNCTIONS ///

    
    function increaseDebtAndSell(
        address proceedsTo,
        ERC721 collateralAsset,
        IPaprController.SwapParams calldata params,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external override returns (uint256 amountOut) {
        bool hasFee = params.swapFeeBips != 0;

        (amountOut,) = UniswapHelpers.swap(
            pool,
            hasFee ? address(this) : proceedsTo,
            !token0IsUnderlying,
            params.amount,
            params.minOut,
            params.sqrtPriceLimitX96,
            params.deadline,
            abi.encode(msg.sender, collateralAsset, oracleInfo)
        );

        if (hasFee) {
            uint256 fee = amountOut * params.swapFeeBips / BIPS_ONE;
            underlying.safeTransfer(params.swapFeeTo, fee);
            underlying.safeTransfer(proceedsTo, amountOut - fee);
        }
    }

    
    function buyAndReduceDebt(address account, ERC721 collateralAsset, IPaprController.SwapParams calldata params)
        external
        override
        returns (uint256)
    {
        bool hasFee = params.swapFeeBips != 0;

        (uint256 amountOut, uint256 amountIn) = UniswapHelpers.swap(
            pool,
            msg.sender,
            token0IsUnderlying,
            params.amount,
            params.minOut,
            params.sqrtPriceLimitX96,
            params.deadline,
            abi.encode(msg.sender)
        );

        if (hasFee) {
            underlying.safeTransferFrom(msg.sender, params.swapFeeTo, amountIn * params.swapFeeBips / BIPS_ONE);
        }

        uint256 debt = _vaultInfo[account][collateralAsset].debt;
        _reduceDebt({
            account: account,
            asset: collateralAsset,
            burnFrom: msg.sender,
            accountDebt: debt,
            amountToReduce: amountOut > debt ? debt : amountOut
        });

        return amountOut;
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
        if (msg.sender != address(pool)) {
            revert("wrong caller");
        }

        bool isUnderlyingIn;
        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
            isUnderlyingIn = token0IsUnderlying;
        } else {
            require(amount1Delta > 0); // swaps entirely within 0-liquidity regions are not supported

            amountToPay = uint256(amount1Delta);
            isUnderlyingIn = !(token0IsUnderlying);
        }

        if (isUnderlyingIn) {
            address payer = abi.decode(_data, (address));
            underlying.safeTransferFrom(payer, msg.sender, amountToPay);
        } else {
            (address account, ERC721 asset, ReservoirOracleUnderwriter.OracleInfo memory oracleInfo) =
                abi.decode(_data, (address, ERC721, ReservoirOracleUnderwriter.OracleInfo));
            _increaseDebt(account, asset, msg.sender, amountToPay, oracleInfo);
        }
    }

    /// LIQUIDATION AUCTION FUNCTIONS ///

    
    function purchaseLiquidationAuctionNFT(
        Auction calldata auction,
        uint256 maxPrice,
        address sendTo,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external override {
        // This function is almost the same as NFTEDA._purchaseNFT
        // however we inline so we can receive payment first
        // and execute logic before sending NFT
        uint256 id;
        uint256 startTime;
        uint256 price;
        (id, startTime, price) = _checkAuctionAndReturnDetails(auction);

        if (price > maxPrice) {
            revert MaxPriceTooLow(price, maxPrice);
        }

        _clearAuctionState(id);

        if (startTime == _vaultInfo[auction.nftOwner][auction.auctionAssetContract].latestAuctionStartTime) {
            _vaultInfo[auction.nftOwner][auction.auctionAssetContract].latestAuctionStartTime = 0;
        }

        auction.paymentAsset.safeTransferFrom(msg.sender, address(this), price);

        _auctionPurchaseUpdateVault(price, auction.nftOwner, auction.auctionAssetContract, oracleInfo);

        auction.auctionAssetContract.safeTransferFrom(address(this), sendTo, auction.auctionAssetID);

        emit EndAuction(id, price);
    }

    
    function startLiquidationAuction(
        address account,
        IPaprController.Collateral calldata collateral,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) external override returns (INFTEDA.Auction memory auction) {
        if (liquidationsLocked) {
            revert LiquidationsLocked();
        }

        uint256 cachedTarget = updateTarget();

        IPaprController.VaultInfo storage info = _vaultInfo[account][collateral.addr];

        // check collateral belongs to account
        if (collateralOwner[collateral.addr][collateral.id] != account) {
            revert IPaprController.InvalidCollateralAccountPair();
        }

        uint256 oraclePrice =
            underwritePriceForCollateral(collateral.addr, ReservoirOracleUnderwriter.PriceKind.TWAP, oracleInfo, false);
        if (!(info.debt > _maxDebt(oraclePrice * info.count, cachedTarget))) {
            revert IPaprController.NotLiquidatable();
        }

        if (block.timestamp - info.latestAuctionStartTime < liquidationAuctionMinSpacing) {
            revert IPaprController.MinAuctionSpacing();
        }

        info.latestAuctionStartTime = uint40(block.timestamp);
        --info.count;
        ++info.auctionCount;

        emit RemoveCollateral(account, collateral.addr, collateral.id);

        delete collateralOwner[collateral.addr][collateral.id];

        _startAuction(
            auction = Auction({
                nftOwner: account,
                auctionAssetID: collateral.id,
                auctionAssetContract: collateral.addr,
                perPeriodDecayPercentWad: perPeriodAuctionDecayWAD,
                secondsInPeriod: auctionDecayPeriod,
                // start price is frozen price * auctionStartPriceMultiplier,
                // converted to papr value at the current contract price
                startPrice: (oraclePrice * auctionStartPriceMultiplier) * FixedPointMathLib.WAD / cachedTarget,
                paymentAsset: papr
            })
        );
    }

    /// OWNER FUNCTIONS ///

    
    function setPool(address _pool) external override onlyOwner {
        _setPool(_pool);
        emit UpdatePool(_pool);
    }

    
    function setFundingPeriod(uint256 _fundingPeriod) external override onlyOwner {
        _setFundingPeriod(_fundingPeriod);
        emit UpdateFundingPeriod(_fundingPeriod);
    }

    
    function setLiquidationsLocked(bool locked) external override onlyOwner {
        liquidationsLocked = locked;
        emit UpdateLiquidationsLocked(locked);
    }

    
    function setAllowedCollateral(IPaprController.CollateralAllowedConfig[] calldata collateralConfigs)
        external
        override
        onlyOwner
    {
        for (uint256 i = 0; i < collateralConfigs.length;) {
            if (address(collateralConfigs[i].collateral) == address(0)) revert IPaprController.InvalidCollateral();

            isAllowed[collateralConfigs[i].collateral] = collateralConfigs[i].allowed;
            emit AllowCollateral(collateralConfigs[i].collateral, collateralConfigs[i].allowed);
            unchecked {
                ++i;
            }
        }
    }

    /// VIEW FUNCTIONS ///

    
    function maxDebt(uint256 totalCollateraValue) external view override returns (uint256) {
        if (_lastUpdated == block.timestamp) {
            return _maxDebt(totalCollateraValue, _target);
        }

        return _maxDebt(totalCollateraValue, newTarget());
    }

    
    function vaultInfo(address account, ERC721 asset)
        external
        view
        override
        returns (IPaprController.VaultInfo memory)
    {
        return _vaultInfo[account][asset];
    }

    /// INTERNAL NON-VIEW ///

    function _addCollateralToVault(address account, IPaprController.Collateral memory collateral) internal {
        if (!isAllowed[collateral.addr]) {
            revert IPaprController.InvalidCollateral();
        }

        collateralOwner[collateral.addr][collateral.id] = account;
        ++_vaultInfo[account][collateral.addr].count;

        emit AddCollateral(account, collateral.addr, collateral.id);
    }

    function _removeCollateral(
        address sendTo,
        IPaprController.Collateral calldata collateral,
        uint256 oraclePrice,
        uint256 cachedTarget
    ) internal {
        if (collateralOwner[collateral.addr][collateral.id] != msg.sender) {
            revert IPaprController.OnlyCollateralOwner();
        }

        delete collateralOwner[collateral.addr][collateral.id];

        uint16 newCount;
        unchecked {
            newCount = _vaultInfo[msg.sender][collateral.addr].count - 1;
            _vaultInfo[msg.sender][collateral.addr].count = newCount;
        }

        uint256 debt = _vaultInfo[msg.sender][collateral.addr].debt;
        uint256 max = _maxDebt(oraclePrice * newCount, cachedTarget);

        if (debt != 0 && !(debt < max)) {
            revert IPaprController.ExceedsMaxDebt(debt, max);
        }

        collateral.addr.safeTransferFrom(address(this), sendTo, collateral.id);

        emit RemoveCollateral(msg.sender, collateral.addr, collateral.id);
    }

    function _increaseDebt(
        address account,
        ERC721 asset,
        address mintTo,
        uint256 amount,
        ReservoirOracleUnderwriter.OracleInfo memory oracleInfo
    ) internal {
        if (!isAllowed[asset]) {
            revert IPaprController.InvalidCollateral();
        }

        uint256 cachedTarget = updateTarget();

        uint256 newDebt = _vaultInfo[account][asset].debt + amount;
        uint256 oraclePrice =
            underwritePriceForCollateral(asset, ReservoirOracleUnderwriter.PriceKind.LOWER, oracleInfo, true);

        uint256 max = _maxDebt(_vaultInfo[account][asset].count * oraclePrice, cachedTarget);

        if (!(newDebt < max)) revert IPaprController.ExceedsMaxDebt(newDebt, max);

        if (newDebt >= 1 << 184) revert IPaprController.DebtAmountExceedsUint184();

        _vaultInfo[account][asset].debt = uint184(newDebt);
        PaprToken(address(papr)).mint(mintTo, amount);

        emit IncreaseDebt(account, asset, amount);
    }

    function _reduceDebt(address account, ERC721 asset, address burnFrom, uint256 accountDebt, uint256 amountToReduce)
        internal
    {
        _reduceDebtWithoutBurn(account, asset, accountDebt, amountToReduce);
        PaprToken(address(papr)).burn(burnFrom, amountToReduce);
    }

    function _reduceDebtWithoutBurn(address account, ERC721 asset, uint256 accountDebt, uint256 amountToReduce)
        internal
    {
        _vaultInfo[account][asset].debt = uint184(accountDebt - amountToReduce);
        emit ReduceDebt(account, asset, amountToReduce);
    }

    /// same as increaseDebtAndSell but takes args in memory
    /// to work with onERC721Received
    function _increaseDebtAndSell(
        address account,
        address proceedsTo,
        ERC721 collateralAsset,
        IPaprController.SwapParams memory params,
        ReservoirOracleUnderwriter.OracleInfo memory oracleInfo
    ) internal {
        bool hasFee = params.swapFeeBips != 0;

        (uint256 amountOut,) = UniswapHelpers.swap(
            pool,
            hasFee ? address(this) : proceedsTo,
            !token0IsUnderlying,
            params.amount,
            params.minOut,
            params.sqrtPriceLimitX96,
            params.deadline,
            abi.encode(account, collateralAsset, oracleInfo)
        );

        if (hasFee) {
            uint256 fee = amountOut * params.swapFeeBips / BIPS_ONE;
            underlying.safeTransfer(params.swapFeeTo, fee);
            underlying.safeTransfer(proceedsTo, amountOut - fee);
        }
    }

    function _auctionPurchaseUpdateVault(
        uint256 price,
        address account,
        ERC721 asset,
        ReservoirOracleUnderwriter.OracleInfo calldata oracleInfo
    ) internal {
        --_vaultInfo[account][asset].auctionCount;

        uint256 count = _vaultInfo[account][asset].count;
        uint256 collateralValueCached;
        uint256 maxDebtCached;

        if (count != 0) {
            collateralValueCached = underwritePriceForCollateral(
                asset, ReservoirOracleUnderwriter.PriceKind.TWAP, oracleInfo, false
            ) * count;
            maxDebtCached = _maxDebt(collateralValueCached, updateTarget());
        }

        uint256 debtCached = _vaultInfo[account][asset].debt;
        /// anything above what is needed to bring this vault under maxDebt is considered excess
        uint256 neededToSaveVault;
        uint256 excess;
        unchecked {
            neededToSaveVault = maxDebtCached > debtCached ? 0 : debtCached - maxDebtCached;
            excess = price > neededToSaveVault ? price - neededToSaveVault : 0;
        }
        uint256 remaining;

        if (excess > 0) {
            remaining = _handleExcess(excess, neededToSaveVault, debtCached, account, asset);
        } else {
            _reduceDebt(account, asset, address(this), debtCached, price);
            // no excess, so price <= neededToSaveVault, meaning debtCached >= price
            unchecked {
                remaining = debtCached - price;
            }
        }

        if (count == 0 && remaining != 0 && _vaultInfo[account][asset].auctionCount == 0) {
            /// there will be debt left with no NFTs, set it to 0
            _reduceDebtWithoutBurn(account, asset, remaining, remaining);
        }
    }

    function _handleExcess(uint256 excess, uint256 neededToSaveVault, uint256 debtCached, address account, ERC721 asset)
        internal
        returns (uint256 remaining)
    {
        uint256 fee = excess * liquidationPenaltyBips / BIPS_ONE;
        uint256 credit;
        // excess is a % of fee and so is <= fee
        unchecked {
            credit = excess - fee;
        }
        uint256 totalOwed = credit + neededToSaveVault;

        PaprToken(address(papr)).burn(address(this), fee);

        if (totalOwed > debtCached) {
            // we owe them more papr than they have in debt
            // so we pay down debt and send them the rest
            _reduceDebt(account, asset, address(this), debtCached, debtCached);
            // totalOwed > debtCached
            unchecked {
                papr.transfer(account, totalOwed - debtCached);
            }
        } else {
            // reduce vault debt
            _reduceDebt(account, asset, address(this), debtCached, totalOwed);
            // debtCached >= totalOwed
            unchecked {
                remaining = debtCached - totalOwed;
            }
        }
    }

    /// INTERNAL VIEW ///

    function _maxDebt(uint256 totalCollateraValue, uint256 cachedTarget) internal view returns (uint256) {
        uint256 maxLoanUnderlying = totalCollateraValue * maxLTV;
        return maxLoanUnderlying / cachedTarget;
    }
}

// 
pragma solidity >=0.8.17;



contract PaprToken is ERC20 {
    error ControllerOnly();

    address immutable controller;

    modifier onlyController() {
        if (msg.sender != controller) {
            revert ControllerOnly();
        }
        _;
    }

    constructor(string memory name, string memory symbol)
        ERC20(string.concat("papr ", name), string.concat("papr", symbol), 18)
    {
        controller = msg.sender;
    }

    function mint(address to, uint256 amount) external onlyController {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) external onlyController {
        _burn(account, amount);
    }
}

// 
pragma solidity >=0.8.0;





library OracleLibrary {
    /// from https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/OracleLibrary.sol#L49
    function getQuoteAtTick(int24 tick, uint128 baseAmount, address baseToken, address quoteToken)
        internal
        pure
        returns (uint256 quoteAmount)
    {
        unchecked {
            uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

            // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
            if (sqrtRatioX96 <= type(uint128).max) {
                uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
                quoteAmount = baseToken < quoteToken
                    ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                    : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
            } else {
                uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
                quoteAmount = baseToken < quoteToken
                    ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                    : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
            }
        }
    }

    // adapted from https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/OracleLibrary.sol#L30-L40
    function timeWeightedAverageTick(int56 startTick, int56 endTick, int56 twapDuration)
        internal
        pure
        returns (int24 twat)
    {
        require(twapDuration != 0, "BP");

        unchecked {
            int56 delta = endTick - startTick;

            twat = int24(delta / twapDuration);

            // Always round to negative infinity
            if (delta < 0 && (delta % (twapDuration) != 0)) {
                twat--;
            }

            twat;
        }
    }

    // adapted from https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/OracleLibrary.sol#L21-L28
    function latestCumulativeTick(address pool) internal view returns (int56) {
        uint32[] memory secondAgos = new uint32[](1);
        secondAgos[0] = 0;
        (int56[] memory tickCumulatives,) = IUniswapV3Pool(pool).observe(secondAgos);
        return tickCumulatives[0];
    }
}

// 
// from https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol
// with updates for solc 8
pragma solidity >=0.8.0;


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(address tokenA, address tokenB, uint24 fee) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}

// 
pragma solidity >=0.8.0;









library UniswapHelpers {
    using SafeCast for uint256;

    
    
    error TooLittleOut(uint256 minOut, uint256 actualOut);

    
    
    error PassedDeadline(uint256 deadline, uint256 currentTimestamp);

    IUniswapV3Factory constant FACTORY = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

    
    
    
    
    
    
    
    
    
    
    
    function swap(
        address pool,
        address recipient,
        bool zeroForOne,
        uint256 amountSpecified,
        uint256 minOut,
        uint160 sqrtPriceLimitX96,
        uint256 deadline,
        bytes memory data
    ) internal returns (uint256 amountOut, uint256 amountIn) {
        if (block.timestamp > deadline) revert PassedDeadline(deadline, block.timestamp);

        (int256 amount0, int256 amount1) = IUniswapV3Pool(pool).swap(
            recipient,
            zeroForOne,
            amountSpecified.toInt256(),
            sqrtPriceLimitX96 == 0
                ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                : sqrtPriceLimitX96,
            data
        );

        if (zeroForOne) {
            amountOut = uint256(-amount1);
            amountIn = uint256(amount0);
        } else {
            amountOut = uint256(-amount0);
            amountIn = uint256(amount1);
        }

        if (amountOut < minOut) {
            revert TooLittleOut(amountOut, minOut);
        }
    }

    
    
    
    
    
    
    function deployAndInitPool(address tokenA, address tokenB, uint24 feeTier, uint160 sqrtRatio)
        internal
        returns (address)
    {
        IUniswapV3Pool pool = IUniswapV3Pool(FACTORY.createPool(tokenA, tokenB, feeTier));
        pool.initialize(sqrtRatio);

        return address(pool);
    }

    
    
    
    function poolCurrentTick(address pool) internal returns (int24) {
        (, int24 tick,,,,,) = IUniswapV3Pool(pool).slot0();

        return tick;
    }

    
    
    
    
    function poolsHaveSameTokens(address pool1, address pool2) internal view returns (bool) {
        return IUniswapV3Pool(pool1).token0() == IUniswapV3Pool(pool2).token0()
            && IUniswapV3Pool(pool1).token1() == IUniswapV3Pool(pool2).token1();
    }

    
    
    
    function isUniswapPool(address pool) internal view returns (bool) {
        IUniswapV3Pool p = IUniswapV3Pool(pool);
        PoolAddress.PoolKey memory k = PoolAddress.getPoolKey(p.token0(), p.token1(), p.fee());
        return pool == PoolAddress.computeAddress(address(FACTORY), k);
    }

    
    
    
    
    function oneToOneSqrtRatio(uint256 token0ONE, uint256 token1ONE) internal pure returns (uint160) {
        return TickMath.getSqrtRatioAtTick(TickMath.getTickAtSqrtRatio(uint160((token1ONE << 96) / token0ONE)) / 2);
    }
}