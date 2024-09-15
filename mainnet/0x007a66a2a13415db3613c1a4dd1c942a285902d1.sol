// SPDX-License-Identifier: AGPL-3.0-only

// 
pragma solidity >=0.8.0;




abstract contract Auth {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

// 
pragma solidity >=0.8.0;





interface IBondAggregator {
    
    
    
    
    function registerAuctioneer(IBondAuctioneer auctioneer_) external;

    
    
    
    
    
    function registerMarket(ERC20 payoutToken_, ERC20 quoteToken_)
        external
        returns (uint256 marketId);

    
    
    function getAuctioneer(uint256 id_) external view returns (IBondAuctioneer);

    
    
    
    
    //
    // if price is below minimum price, minimum price is returned
    // this is enforced on deposits by manipulating total debt (see _decay())
    function marketPrice(uint256 id_) external view returns (uint256);

    
    
    
    function marketScale(uint256 id_) external view returns (uint256);

    
    
    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    
    function payoutFor(
        uint256 amount_,
        uint256 id_,
        address referrer_
    ) external view returns (uint256);

    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    function maxAmountAccepted(uint256 id_, address referrer_) external view returns (uint256);

    
    
    function isInstantSwap(uint256 id_) external view returns (bool);

    
    
    function isLive(uint256 id_) external view returns (bool);

    
    
    function liveMarketsBetween(uint256 firstIndex_, uint256 lastIndex_)
        external
        view
        returns (uint256[] memory);

    
    
    
    function liveMarketsFor(address token_, bool isPayout_)
        external
        view
        returns (uint256[] memory);

    
    
    
    
    function liveMarketsBy(
        address owner_,
        uint256 firstIndex_,
        uint256 lastIndex_
    ) external view returns (uint256[] memory);

    
    
    
    function marketsFor(address payout_, address quote_) external view returns (uint256[] memory);

    
    
    
    
    
    
    ///                         Inputting the zero address will take into account just the protocol fee.
    function findMarketFor(
        address payout_,
        address quote_,
        uint256 amountIn_,
        uint256 minAmountOut_,
        uint256 maxExpiry_
    ) external view returns (uint256 id);

    
    function getTeller(uint256 id_) external view returns (IBondTeller);

    
    function currentCapacity(uint256 id_) external view returns (uint256);
}




interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}

// 
pragma solidity >=0.8.0;





abstract contract ERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*///////////////////////////////////////////////////////////////
                             EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*///////////////////////////////////////////////////////////////
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

    /*///////////////////////////////////////////////////////////////
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

    /*///////////////////////////////////////////////////////////////
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
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

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

    /*///////////////////////////////////////////////////////////////
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

// 
pragma solidity 0.8.15;













///      for any token pair. The markets do not require maintenance and will manage
///      bond prices based on activity. Bond issuers create BondMarkets that pay out
///      a Payout Token in exchange for deposited Quote Tokens. Users can purchase
///      future-dated Payout Tokens with Quote Tokens at the current market price and
///      receive Bond Tokens to represent their position while their bond vests.
///      Once the Bond Tokens vest, they can redeem it for the Quote Tokens.
///

///      Tellers and Auctioneers. Additionally, it aggregates market data from
///      multiple Auctioneers in convenient view functions for front-end interfaces.
///      The Aggregator contract should be deployed first since Tellers, Auctioneers, and
///      Callbacks all require it in their constructors.
///

contract BondAggregator is IBondAggregator, Auth {
    using FullMath for uint256;

    /* ========== ERRORS ========== */
    error Aggregator_OnlyAuctioneer();
    error Aggregator_AlreadyRegistered(address auctioneer_);
    error Aggregator_InvalidParams();

    /* ========== STATE VARIABLES ========== */

    
    uint256 public marketCounter;

    
    IBondAuctioneer[] public auctioneers;
    mapping(address => bool) internal _whitelist;

    
    mapping(uint256 => IBondAuctioneer) public marketsToAuctioneers;

    
    mapping(address => uint256[]) public marketsForPayout;

    
    mapping(address => uint256[]) public marketsForQuote;

    // A 'vesting' param longer than 50 years is considered a timestamp for fixed expiry.
    uint48 private constant MAX_FIXED_TERM = 52 weeks * 50;

    constructor(address guardian_, Authority authority_) Auth(guardian_, authority_) {}

    
    function registerAuctioneer(IBondAuctioneer auctioneer_) external requiresAuth {
        // Restricted to authorized addresses

        // Check that the auctioneer is not already registered
        if (_whitelist[address(auctioneer_)])
            revert Aggregator_AlreadyRegistered(address(auctioneer_));

        // Add the auctioneer to the whitelist
        auctioneers.push(auctioneer_);
        _whitelist[address(auctioneer_)] = true;
    }

    
    function registerMarket(ERC20 payoutToken_, ERC20 quoteToken_)
        external
        override
        returns (uint256 marketId)
    {
        if (!_whitelist[msg.sender]) revert Aggregator_OnlyAuctioneer();
        if (address(payoutToken_) == address(0) || address(quoteToken_) == address(0))
            revert Aggregator_InvalidParams();
        marketId = marketCounter;
        marketsToAuctioneers[marketId] = IBondAuctioneer(msg.sender);
        marketsForPayout[address(payoutToken_)].push(marketId);
        marketsForQuote[address(quoteToken_)].push(marketId);
        ++marketCounter;
    }

    /* ========== VIEW FUNCTIONS ========== */

    
    function getAuctioneer(uint256 id_) external view returns (IBondAuctioneer) {
        return marketsToAuctioneers[id_];
    }

    
    function marketPrice(uint256 id_) public view override returns (uint256) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.marketPrice(id_);
    }

    
    function marketScale(uint256 id_) external view override returns (uint256) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.marketScale(id_);
    }

    
    function payoutFor(
        uint256 amount_,
        uint256 id_,
        address referrer_
    ) public view override returns (uint256) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.payoutFor(amount_, id_, referrer_);
    }

    
    function maxAmountAccepted(uint256 id_, address referrer_) external view returns (uint256) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.maxAmountAccepted(id_, referrer_);
    }

    
    function isInstantSwap(uint256 id_) external view returns (bool) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.isInstantSwap(id_);
    }

    
    function isLive(uint256 id_) public view override returns (bool) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.isLive(id_);
    }

    
    function liveMarketsBetween(uint256 firstIndex_, uint256 lastIndex_)
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256 count;
        for (uint256 i = firstIndex_; i < lastIndex_; ++i) {
            if (isLive(i)) ++count;
        }

        uint256[] memory ids = new uint256[](count);
        count = 0;
        for (uint256 i = firstIndex_; i < lastIndex_; ++i) {
            if (isLive(i)) {
                ids[count] = i;
                ++count;
            }
        }
        return ids;
    }

    
    function liveMarketsFor(address token_, bool isPayout_)
        public
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory mkts;

        mkts = isPayout_ ? marketsForPayout[token_] : marketsForQuote[token_];

        uint256 count;
        uint256 len = mkts.length;

        for (uint256 i; i < len; ++i) {
            if (isLive(mkts[i])) ++count;
        }

        uint256[] memory ids = new uint256[](count);
        count = 0;

        for (uint256 i; i < len; ++i) {
            if (isLive(mkts[i])) {
                ids[count] = mkts[i];
                ++count;
            }
        }

        return ids;
    }

    
    function marketsFor(address payout_, address quote_) public view returns (uint256[] memory) {
        uint256[] memory forPayout = liveMarketsFor(payout_, true);
        uint256 count;

        ERC20 quoteToken;
        IBondAuctioneer auctioneer;
        uint256 len = forPayout.length;
        for (uint256 i; i < len; ++i) {
            auctioneer = marketsToAuctioneers[forPayout[i]];
            (, , , quoteToken, , ) = auctioneer.getMarketInfoForPurchase(forPayout[i]);
            if (isLive(forPayout[i]) && address(quoteToken) == quote_) ++count;
        }

        uint256[] memory ids = new uint256[](count);
        count = 0;

        for (uint256 i; i < len; ++i) {
            auctioneer = marketsToAuctioneers[forPayout[i]];
            (, , , quoteToken, , ) = auctioneer.getMarketInfoForPurchase(forPayout[i]);
            if (isLive(forPayout[i]) && address(quoteToken) == quote_) {
                ids[count] = forPayout[i];
                ++count;
            }
        }

        return ids;
    }

    
    function findMarketFor(
        address payout_,
        address quote_,
        uint256 amountIn_,
        uint256 minAmountOut_,
        uint256 maxExpiry_
    ) external view returns (uint256) {
        uint256[] memory ids = marketsFor(payout_, quote_);
        uint256 len = ids.length;
        // uint256[] memory payouts = new uint256[](len);

        uint256 highestOut;
        uint256 id = type(uint256).max; // set to max so an empty set doesn't return 0, the first index
        uint48 vesting;
        uint256 maxPayout;
        IBondAuctioneer auctioneer;
        for (uint256 i; i < len; ++i) {
            auctioneer = marketsToAuctioneers[ids[i]];
            (, , , , vesting, maxPayout) = auctioneer.getMarketInfoForPurchase(ids[i]);

            uint256 expiry = (vesting <= MAX_FIXED_TERM) ? block.timestamp + vesting : vesting;

            if (expiry <= maxExpiry_) {
                if (minAmountOut_ <= maxPayout) {
                    try auctioneer.payoutFor(amountIn_, ids[i], address(0)) returns (
                        uint256 payout
                    ) {
                        if (payout > highestOut && payout >= minAmountOut_) {
                            highestOut = payout;
                            id = ids[i];
                        }
                    } catch {
                        // fail silently and try the next market
                    }
                }
            }
        }

        return id;
    }

    
    function liveMarketsBy(
        address owner_,
        uint256 firstIndex_,
        uint256 lastIndex_
    ) external view returns (uint256[] memory) {
        uint256 count;
        IBondAuctioneer auctioneer;
        for (uint256 i = firstIndex_; i < lastIndex_; ++i) {
            auctioneer = marketsToAuctioneers[i];
            if (auctioneer.isLive(i) && auctioneer.ownerOf(i) == owner_) {
                ++count;
            }
        }

        uint256[] memory ids = new uint256[](count);
        count = 0;
        for (uint256 j = firstIndex_; j < lastIndex_; ++j) {
            auctioneer = marketsToAuctioneers[j];
            if (auctioneer.isLive(j) && auctioneer.ownerOf(j) == owner_) {
                ids[count] = j;
                ++count;
            }
        }

        return ids;
    }

    
    function getTeller(uint256 id_) external view returns (IBondTeller) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.getTeller();
    }

    
    function currentCapacity(uint256 id_) external view returns (uint256) {
        IBondAuctioneer auctioneer = marketsToAuctioneers[id_];
        return auctioneer.currentCapacity(id_);
    }
}

// 
pragma solidity >=0.8.0;





interface IBondAuctioneer {
    
    
    
    
    function createMarket(bytes memory params_) external returns (uint256);

    
    
    
    function closeMarket(uint256 id_) external;

    
    
    
    
    
    
    function purchaseBond(
        uint256 id_,
        uint256 amount_,
        uint256 minAmountOut_
    ) external returns (uint256 payout);

    
    
    
    ///                                 tuneInterval should be greater than tuneAdjustmentDelay
    
    
    ///                                 1. Tune interval - Frequency of tuning
    ///                                 2. Tune adjustment delay - Time to implement downward tuning adjustments
    ///                                 3. Debt decay interval - Interval over which debt should decay completely
    function setIntervals(uint256 id_, uint32[3] calldata intervals_) external;

    
    
    
    
    
    function pushOwnership(uint256 id_, address newOwner_) external;

    
    
    
    
    function pullOwnership(uint256 id_) external;

    
    
    
    ///                     1. Tune interval - amount of time between tuning adjustments
    ///                     2. Tune adjustment delay - amount of time to apply downward tuning adjustments
    ///                     3. Minimum debt decay interval - minimum amount of time to let debt decay to zero
    ///                     4. Minimum deposit interval - minimum amount of time to wait between deposits
    ///                     5. Minimum market duration - minimum amount of time a market can be created for
    ///                     6. Minimum debt buffer - the minimum amount of debt over the initial debt to trigger a market shutdown
    
    
    function setDefaults(uint32[6] memory defaults_) external;

    
    
    
    function setAllowNewMarkets(bool status_) external;

    
    
    
    
    
    function setCallbackAuthStatus(address creator_, bool status_) external;

    /* ========== VIEW FUNCTIONS ========== */

    
    
    
    
    
    
    
    
    function getMarketInfoForPurchase(uint256 id_)
        external
        view
        returns (
            address owner,
            address callbackAddr,
            ERC20 payoutToken,
            ERC20 quoteToken,
            uint48 vesting,
            uint256 maxPayout
        );

    
    
    
    //
    // if price is below minimum price, minimum price is returned
    function marketPrice(uint256 id_) external view returns (uint256);

    
    
    
    function marketScale(uint256 id_) external view returns (uint256);

    
    
    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    
    function payoutFor(
        uint256 amount_,
        uint256 id_,
        address referrer_
    ) external view returns (uint256);

    
    
    
    ///                     Inputting the zero address will take into account just the protocol fee.
    function maxAmountAccepted(uint256 id_, address referrer_) external view returns (uint256);

    
    
    function isInstantSwap(uint256 id_) external view returns (bool);

    
    
    function isLive(uint256 id_) external view returns (bool);

    
    
    function ownerOf(uint256 id_) external view returns (address);

    
    function getTeller() external view returns (IBondTeller);

    
    function getAggregator() external view returns (IBondAggregator);

    
    function currentCapacity(uint256 id_) external view returns (uint256);
}

// 
pragma solidity >=0.8.0;



interface IBondTeller {
    
    
    
    ///                         Direct calls can use the zero address for no referrer fee.
    
    
    
    
    
    function purchase(
        address recipient_,
        address referrer_,
        uint256 id_,
        uint256 amount_,
        uint256 minAmountOut_
    ) external returns (uint256, uint48);

    
    
    
    function getFee(address referrer_) external view returns (uint48);

    
    
    
    function setProtocolFee(uint48 fee_) external;

    
    
    ///                  when using create() to mint bond tokens without using an Auctioneer
    
    function setCreateFeeDiscount(uint48 discount_) external;

    
    
    
    function setReferrerFee(uint48 fee_) external;

    
    
    
    function claimFees(ERC20[] memory tokens_, address to_) external;
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

    
    
    
    
    
    function mulDivUp(
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