// SPDX-License-Identifier: BSD

// 
pragma solidity ^0.8.4;




contract Clone {
    
    
    
    function _getArgAddress(uint256 argOffset)
        internal
        pure
        returns (address arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    
    
    
    function _getArgUint256(uint256 argOffset)
        internal
        pure
        returns (uint256 arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    
    
    
    function _getArgUint64(uint256 argOffset)
        internal
        pure
        returns (uint64 arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := shr(0xc0, calldataload(add(offset, argOffset)))
        }
    }

    
    
    
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }

    
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            offset := sub(
                calldatasize(),
                add(shr(240, calldataload(sub(calldatasize(), 2))), 2)
            )
        }
    }
}

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




abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
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
pragma solidity 0.8.15;
















///      for any token pair. The markets do not require maintenance and will manage
///      bond prices based on activity. Bond issuers create BondMarkets that pay out
///      a Payout Token in exchange for deposited Quote Tokens. Users can purchase
///      future-dated Payout Tokens with Quote Tokens at the current market price and
///      receive Bond Tokens to represent their position while their bond vests.
///      Once the Bond Tokens vest, they can redeem it for the Quote Tokens.
///

///      issued to represent bond positions. Users purchase bonds by depositing Quote Tokens
///      and receive a Bond Token (token type is implementation-specific) that represents
///      their payout and the designated expiry. Once a bond vests, Investors can redeem their
///      Bond Tokens for the underlying Payout Token. A Teller requires one or more Auctioneer
///      contracts to be deployed to provide markets for users to purchase bonds from.
///

abstract contract BondBaseTeller is IBondTeller, Auth, ReentrancyGuard {
    using TransferHelper for ERC20;
    using FullMath for uint256;

    /* ========== ERRORS ========== */

    error Teller_InvalidCallback();
    error Teller_TokenNotMatured(uint48 maturesOn);
    error Teller_NotAuthorized();
    error Teller_TokenDoesNotExist(ERC20 underlying, uint48 expiry);
    error Teller_UnsupportedToken();
    error Teller_InvalidParams();

    /* ========== EVENTS ========== */
    event Bonded(uint256 indexed id, address indexed referrer, uint256 amount, uint256 payout);

    /* ========== STATE VARIABLES ========== */

    
    
    ///      is < 1e5 wei (can happen with big price differences on small decimal tokens). This is purely
    ///      a theoretical edge case, as the bond amount would not be practical.
    mapping(address => uint48) public referrerFees;

    
    uint48 public protocolFee;

    
    uint48 public createFeeDiscount;

    uint48 public constant FEE_DECIMALS = 1e5; // one percent equals 1000.

    
    mapping(address => mapping(ERC20 => uint256)) public rewards;

    // Address the protocol receives fees at
    address internal immutable _protocol;

    // BondAggregator contract with utility functions
    IBondAggregator internal immutable _aggregator;

    constructor(
        address protocol_,
        IBondAggregator aggregator_,
        address guardian_,
        Authority authority_
    ) Auth(guardian_, authority_) {
        _protocol = protocol_;
        _aggregator = aggregator_;

        // Explicitly setting these values to zero to document
        protocolFee = 0;
        createFeeDiscount = 0;
    }

    
    function setReferrerFee(uint48 fee_) external override nonReentrant {
        if (fee_ > 5e3) revert Teller_InvalidParams();
        referrerFees[msg.sender] = fee_;
    }

    
    function setProtocolFee(uint48 fee_) external override requiresAuth {
        if (fee_ > 5e3) revert Teller_InvalidParams();
        protocolFee = fee_;
    }

    
    function setCreateFeeDiscount(uint48 discount_) external override requiresAuth {
        if (discount_ > protocolFee) revert Teller_InvalidParams();
        createFeeDiscount = discount_;
    }

    
    function claimFees(ERC20[] memory tokens_, address to_) external override nonReentrant {
        uint256 len = tokens_.length;
        for (uint256 i; i < len; ++i) {
            ERC20 token = tokens_[i];
            uint256 send = rewards[msg.sender][token];

            if (send != 0) {
                rewards[msg.sender][token] = 0;
                token.safeTransfer(to_, send);
            }
        }
    }

    
    function getFee(address referrer_) external view returns (uint48) {
        return protocolFee + referrerFees[referrer_];
    }

    /* ========== USER FUNCTIONS ========== */

    
    function purchase(
        address recipient_,
        address referrer_,
        uint256 id_,
        uint256 amount_,
        uint256 minAmountOut_
    ) external virtual nonReentrant returns (uint256, uint48) {
        ERC20 payoutToken;
        ERC20 quoteToken;
        uint48 vesting;
        uint256 payout;

        // Calculate fees for purchase
        // 1. Calculate referrer fee
        // 2. Calculate protocol fee as the total expected fee amount minus the referrer fee
        //    to avoid issues with rounding from separate fee calculations
        uint256 toReferrer = amount_.mulDiv(referrerFees[referrer_], FEE_DECIMALS);
        uint256 toProtocol = amount_.mulDiv(protocolFee + referrerFees[referrer_], FEE_DECIMALS) -
            toReferrer;

        {
            IBondAuctioneer auctioneer = _aggregator.getAuctioneer(id_);
            address owner;
            (owner, , payoutToken, quoteToken, vesting, ) = auctioneer.getMarketInfoForPurchase(
                id_
            );

            // Auctioneer handles bond pricing, capacity, and duration
            uint256 amountLessFee = amount_ - toReferrer - toProtocol;
            payout = auctioneer.purchaseBond(id_, amountLessFee, minAmountOut_);
        }

        // Allocate fees to protocol and referrer
        rewards[referrer_][quoteToken] += toReferrer;
        rewards[_protocol][quoteToken] += toProtocol;

        // Transfer quote tokens from sender and ensure enough payout tokens are available
        _handleTransfers(id_, amount_, payout, toReferrer + toProtocol);

        // Handle payout to user (either transfer tokens if instant swap or issue bond token)
        uint48 expiry = _handlePayout(recipient_, payout, payoutToken, vesting);

        emit Bonded(id_, referrer_, amount_, payout);

        return (payout, expiry);
    }

    
    function _handleTransfers(
        uint256 id_,
        uint256 amount_,
        uint256 payout_,
        uint256 feePaid_
    ) internal {
        // Get info from auctioneer
        (address owner, address callbackAddr, ERC20 payoutToken, ERC20 quoteToken, , ) = _aggregator
            .getAuctioneer(id_)
            .getMarketInfoForPurchase(id_);

        // Calculate amount net of fees
        uint256 amountLessFee = amount_ - feePaid_;

        // Have to transfer to teller first since fee is in quote token
        // Check balance before and after to ensure full amount received, revert if not
        // Handles edge cases like fee-on-transfer tokens (which are not supported)
        uint256 quoteBalance = quoteToken.balanceOf(address(this));
        quoteToken.safeTransferFrom(msg.sender, address(this), amount_);
        if (quoteToken.balanceOf(address(this)) < quoteBalance + amount_)
            revert Teller_UnsupportedToken();

        // If callback address supplied, transfer tokens from teller to callback, then execute callback function,
        // and ensure proper amount of tokens transferred in.
        if (callbackAddr != address(0)) {
            // Send quote token to callback (transferred in first to allow use during callback)
            quoteToken.safeTransfer(callbackAddr, amountLessFee);

            // Call the callback function to receive payout tokens for payout
            uint256 payoutBalance = payoutToken.balanceOf(address(this));
            IBondCallback(callbackAddr).callback(id_, amountLessFee, payout_);

            // Check to ensure that the callback sent the requested amount of payout tokens back to the teller
            if (payoutToken.balanceOf(address(this)) < (payoutBalance + payout_))
                revert Teller_InvalidCallback();
        } else {
            // If no callback is provided, transfer tokens from market owner to this contract
            // for payout.
            // Check balance before and after to ensure full amount received, revert if not
            // Handles edge cases like fee-on-transfer tokens (which are not supported)
            uint256 payoutBalance = payoutToken.balanceOf(address(this));
            payoutToken.safeTransferFrom(owner, address(this), payout_);
            if (payoutToken.balanceOf(address(this)) < (payoutBalance + payout_))
                revert Teller_UnsupportedToken();

            quoteToken.safeTransfer(owner, amountLessFee);
        }
    }

    
    
    ///                     extend this base since it is called by purchase.
    
    
    
    
    ///                     timestamp or duration depending on the implementation
    
    function _handlePayout(
        address recipient_,
        uint256 payout_,
        ERC20 underlying_,
        uint48 vesting_
    ) internal virtual returns (uint48 expiry);

    
    
    
    
    
    function _getNameAndSymbol(ERC20 underlying_, uint256 expiry_)
        internal
        view
        returns (string memory name, string memory symbol)
    {
        // Convert a number of days into a human-readable date, courtesy of BokkyPooBah.
        // Source: https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol

        uint256 year;
        uint256 month;
        uint256 day;
        {
            int256 __days = int256(expiry_ / 1 days);

            int256 num1 = __days + 68569 + 2440588; // 2440588 = OFFSET19700101
            int256 num2 = (4 * num1) / 146097;
            num1 = num1 - (146097 * num2 + 3) / 4;
            int256 _year = (4000 * (num1 + 1)) / 1461001;
            num1 = num1 - (1461 * _year) / 4 + 31;
            int256 _month = (80 * num1) / 2447;
            int256 _day = num1 - (2447 * _month) / 80;
            num1 = _month / 11;
            _month = _month + 2 - 12 * num1;
            _year = 100 * (num2 - 49) + _year + num1;

            year = uint256(_year);
            month = uint256(_month);
            day = uint256(_day);
        }

        string memory yearStr = _uint2str(year % 10000);
        string memory monthStr = month < 10
            ? string(abi.encodePacked("0", _uint2str(month)))
            : _uint2str(month);
        string memory dayStr = day < 10
            ? string(abi.encodePacked("0", _uint2str(day)))
            : _uint2str(day);

        // Construct name/symbol strings.
        name = string(
            abi.encodePacked(underlying_.name(), " ", yearStr, "-", monthStr, "-", dayStr)
        );
        symbol = string(abi.encodePacked(underlying_.symbol(), "-", yearStr, monthStr, dayStr));
    }

    // Some fancy math to convert a uint into a string, courtesy of Provable Things.
    // Updated to work with solc 0.8.0.
    // https://github.com/provable-things/ethereum-api/blob/master/provableAPI_0.6.sol
    function _uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

// 
pragma solidity >=0.8.0;




interface IBondFixedExpiryTeller {
    
    
    
    function redeem(ERC20BondToken token_, uint256 amount_) external;

    
    
    
    
    
    
    function create(
        ERC20 underlying_,
        uint48 expiry_,
        uint256 amount_
    ) external returns (ERC20BondToken, uint256);

    
    
    
    
    
    
    function deploy(ERC20 underlying_, uint48 expiry_) external returns (ERC20BondToken);

    
    
    
    function getBondTokenForMarket(uint256 id_) external view returns (ERC20BondToken);

    
    
    
    
    function getBondToken(ERC20 underlying_, uint48 expiry_) external view returns (ERC20BondToken);
}

// 
pragma solidity >=0.8.0;







abstract contract CloneERC20 is Clone {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*///////////////////////////////////////////////////////////////
                               METADATA
    //////////////////////////////////////////////////////////////*/

    function name() external pure returns (string memory) {
        return string(abi.encodePacked(_getArgUint256(0)));
    }

    function symbol() external pure returns (string memory) {
        return string(abi.encodePacked(_getArgUint256(0x20)));
    }

    function decimals() external pure returns (uint8) {
        return _getArgUint8(0x40);
    }

    /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] += amount;

        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);

        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] -= amount;

        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);

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
                       INTERNAL LOGIC
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

    function _getImmutableVariablesOffset() internal pure returns (uint256 offset) {
        assembly {
            offset := sub(calldatasize(), add(shr(240, calldataload(sub(calldatasize(), 2))), 2))
        }
    }
}

// 

pragma solidity ^0.8.4;




library ClonesWithImmutableArgs {
    error CreateFail();

    
    
    
    
    
    function clone(address implementation, bytes memory data)
        internal
        returns (address instance)
    {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            uint256 creationSize = 0x43 + extraLength;
            uint256 runSize = creationSize - 11;
            uint256 dataPtr;
            uint256 ptr;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                ptr := mload(0x40)

                // -------------------------------------------------------------------------------------------------------------
                // CREATION (11 bytes)
                // -------------------------------------------------------------------------------------------------------------

                // 3d          | RETURNDATASIZE        | 0                       | –
                // 61 runtime  | PUSH2 runtime (r)     | r 0                     | –
                mstore(
                    ptr,
                    0x3d61000000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x02), shl(240, runSize)) // size of the contract running bytecode (16 bits)

                // creation size = 0b
                // 80          | DUP1                  | r r 0                   | –
                // 60 creation | PUSH1 creation (c)    | c r r 0                 | –
                // 3d          | RETURNDATASIZE        | 0 c r r 0               | –
                // 39          | CODECOPY              | r 0                     | [0-2d]: runtime code
                // 81          | DUP2                  | 0 c  0                  | [0-2d]: runtime code
                // f3          | RETURN                | 0                       | [0-2d]: runtime code
                mstore(
                    add(ptr, 0x04),
                    0x80600b3d3981f300000000000000000000000000000000000000000000000000
                )

                // -------------------------------------------------------------------------------------------------------------
                // RUNTIME
                // -------------------------------------------------------------------------------------------------------------

                // 36          | CALLDATASIZE          | cds                     | –
                // 3d          | RETURNDATASIZE        | 0 cds                   | –
                // 3d          | RETURNDATASIZE        | 0 0 cds                 | –
                // 37          | CALLDATACOPY          | –                       | [0, cds] = calldata
                // 61          | PUSH2 extra           | extra                   | [0, cds] = calldata
                mstore(
                    add(ptr, 0x0b),
                    0x363d3d3761000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x10), shl(240, extraLength))

                // 60 0x38     | PUSH1 0x38            | 0x38 extra              | [0, cds] = calldata // 0x38 (56) is runtime size - data
                // 36          | CALLDATASIZE          | cds 0x38 extra          | [0, cds] = calldata
                // 39          | CODECOPY              | _                       | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0                       | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 0                     | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 0 0                   | [0, cds] = calldata
                // 36          | CALLDATASIZE          | cds 0 0 0               | [0, cds] = calldata
                // 61 extra    | PUSH2 extra           | extra cds 0 0 0         | [0, cds] = calldata
                mstore(
                    add(ptr, 0x12),
                    0x603836393d3d3d36610000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x1b), shl(240, extraLength))

                // 01          | ADD                   | cds+extra 0 0 0         | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 cds 0 0 0             | [0, cds] = calldata
                // 73 addr     | PUSH20 0x123…         | addr 0 cds 0 0 0        | [0, cds] = calldata
                mstore(
                    add(ptr, 0x1d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x20), shl(0x60, implementation))

                // 5a          | GAS                   | gas addr 0 cds 0 0 0    | [0, cds] = calldata
                // f4          | DELEGATECALL          | success 0               | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | rds success 0           | [0, cds] = calldata
                // 82          | DUP3                  | 0 rds success 0         | [0, cds] = calldata
                // 80          | DUP1                  | 0 0 rds success 0       | [0, cds] = calldata
                // 3e          | RETURNDATACOPY        | success 0               | [0, rds] = return data (there might be some irrelevant leftovers in memory [rds, cds] when rds < cds)
                // 90          | SWAP1                 | 0 success               | [0, rds] = return data
                // 3d          | RETURNDATASIZE        | rds 0 success           | [0, rds] = return data
                // 91          | SWAP2                 | success 0 rds           | [0, rds] = return data
                // 60 0x36     | PUSH1 0x36            | 0x36 sucess 0 rds       | [0, rds] = return data
                // 57          | JUMPI                 | 0 rds                   | [0, rds] = return data
                // fd          | REVERT                | –                       | [0, rds] = return data
                // 5b          | JUMPDEST              | 0 rds                   | [0, rds] = return data
                // f3          | RETURN                | –                       | [0, rds] = return data

                mstore(
                    add(ptr, 0x34),
                    0x5af43d82803e903d91603657fd5bf30000000000000000000000000000000000
                )
            }

            // -------------------------------------------------------------------------------------------------------------
            // APPENDED DATA (Accessible from extcodecopy)
            // (but also send as appended data to the delegatecall)
            // -------------------------------------------------------------------------------------------------------------

            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x43;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                dataPtr := add(data, 32)
            }
            for (; counter >= 32; counter -= 32) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    mstore(copyPtr, mload(dataPtr))
                }

                copyPtr += 32;
                dataPtr += 32;
            }
            uint256 mask = ~(256**(32 - counter) - 1);
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }
            // solhint-disable-next-line no-inline-assembly
            assembly {
                instance := create(0, ptr, creationSize)
            }
            if (instance == address(0)) {
                revert CreateFail();
            }
        }
    }
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

///      Bond Base Teller contract specific to handling user bond transactions
///      and tokenizing bond markets where all purchases vest at the same timestamp
///      as ERC20 tokens. Vesting timestamps are rounded to the nearest day to avoid
///      duplicate tokens with the same name/symbol.
///

contract BondFixedExpiryTeller is BondBaseTeller, IBondFixedExpiryTeller {
    using TransferHelper for ERC20;
    using FullMath for uint256;
    using ClonesWithImmutableArgs for address;

    /* ========== EVENTS ========== */
    event ERC20BondTokenCreated(
        ERC20BondToken bondToken,
        ERC20 indexed underlying,
        uint48 indexed expiry
    );

    /* ========== STATE VARIABLES ========== */
    
    mapping(ERC20 => mapping(uint48 => ERC20BondToken)) public bondTokens;

    
    ERC20BondToken public immutable bondTokenImplementation;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address protocol_,
        IBondAggregator aggregator_,
        address guardian_,
        Authority authority_
    ) BondBaseTeller(protocol_, aggregator_, guardian_, authority_) {
        bondTokenImplementation = new ERC20BondToken();
    }

    /* ========== PURCHASE ========== */

    
    
    
    
    
    
    function _handlePayout(
        address recipient_,
        uint256 payout_,
        ERC20 underlying_,
        uint48 vesting_
    ) internal override returns (uint48 expiry) {
        // If there is no vesting time, the deposit is treated as an instant swap.
        // otherwise, deposit info is stored and payout is available at a future timestamp.
        // instant swap is denoted by expiry == 0.
        //
        // bonds mature with a cliff at a set timestamp
        // prior to the expiry timestamp, no payout tokens are accessible to the user
        // after the expiry timestamp, the entire payout can be redeemed
        //
        // fixed-expiry bonds mature at a set timestamp
        // i.e. expiry = day 10. when alice deposits on day 1, her term
        // is 9 days. when bob deposits on day 2, his term is 8 days.
        if (vesting_ > uint48(block.timestamp)) {
            expiry = vesting_;
            // Fixed-expiry bonds mint ERC-20 tokens
            bondTokens[underlying_][expiry].mint(recipient_, payout_);
        } else {
            // If no expiry, then transfer payout directly to user
            underlying_.safeTransfer(recipient_, payout_);
        }
    }

    /* ========== DEPOSIT/MINT ========== */

    
    function create(
        ERC20 underlying_,
        uint48 expiry_,
        uint256 amount_
    ) external override nonReentrant returns (ERC20BondToken, uint256) {
        // Expiry is rounded to the nearest day at 0000 UTC (in seconds) since bond tokens
        // are only unique to a day, not a specific timestamp.
        uint48 expiry = uint48(expiry_ / 1 days) * 1 days;

        // Revert if expiry is in the past
        if (uint256(expiry) < block.timestamp) revert Teller_InvalidParams();

        ERC20BondToken bondToken = bondTokens[underlying_][expiry];

        // Revert if no token exists, must call deploy first
        if (bondToken == ERC20BondToken(address(0x00)))
            revert Teller_TokenDoesNotExist(underlying_, expiry);

        // Transfer in underlying
        // Check that amount received is not less than amount expected
        // Handles edge cases like fee-on-transfer tokens (which are not supported)
        uint256 oldBalance = underlying_.balanceOf(address(this));
        underlying_.safeTransferFrom(msg.sender, address(this), amount_);
        if (underlying_.balanceOf(address(this)) < oldBalance + amount_)
            revert Teller_UnsupportedToken();

        // If fee is greater than the create discount, then calculate the fee and store it
        // Otherwise, fee is zero.
        if (protocolFee > createFeeDiscount) {
            // Calculate fee amount
            uint256 feeAmount = amount_.mulDiv(protocolFee - createFeeDiscount, FEE_DECIMALS);
            rewards[_protocol][underlying_] += feeAmount;

            // Mint new bond tokens
            bondToken.mint(msg.sender, amount_ - feeAmount);

            return (bondToken, amount_ - feeAmount);
        } else {
            // Mint new bond tokens
            bondToken.mint(msg.sender, amount_);

            return (bondToken, amount_);
        }
    }

    /* ========== REDEEM ========== */

    
    function redeem(ERC20BondToken token_, uint256 amount_) external override nonReentrant {
        // Validate token is issued by this teller
        ERC20 underlying = token_.underlying();
        uint48 expiry = token_.expiry();

        if (token_ != bondTokens[underlying][expiry]) revert Teller_UnsupportedToken();

        // Validate token expiry has passed
        if (uint48(block.timestamp) < expiry) revert Teller_TokenNotMatured(expiry);

        // Burn bond token and transfer underlying
        token_.burn(msg.sender, amount_);
        underlying.safeTransfer(msg.sender, amount_);
    }

    /* ========== TOKENIZATION ========== */

    
    function deploy(ERC20 underlying_, uint48 expiry_)
        external
        override
        nonReentrant
        returns (ERC20BondToken)
    {
        // Expiry is rounded to the nearest day at 0000 UTC (in seconds) since bond tokens
        // are only unique to a day, not a specific timestamp.
        uint48 expiry = uint48(expiry_ / 1 days) * 1 days;

        // Revert if expiry is in the past
        if (uint256(expiry) < block.timestamp) revert Teller_InvalidParams();

        // Create bond token if one doesn't already exist
        ERC20BondToken bondToken = bondTokens[underlying_][expiry];
        if (bondToken == ERC20BondToken(address(0))) {
            (string memory name, string memory symbol) = _getNameAndSymbol(underlying_, expiry);
            bytes memory tokenData = abi.encodePacked(
                bytes32(bytes(name)),
                bytes32(bytes(symbol)),
                uint8(underlying_.decimals()),
                underlying_,
                uint256(expiry),
                address(this)
            );
            bondToken = ERC20BondToken(address(bondTokenImplementation).clone(tokenData));
            bondTokens[underlying_][expiry] = bondToken;
            emit ERC20BondTokenCreated(bondToken, underlying_, expiry);
        }
        return bondToken;
    }

    
    function getBondTokenForMarket(uint256 id_) external view override returns (ERC20BondToken) {
        // Check that the id is for a market served by this teller
        if (address(_aggregator.getTeller(id_)) != address(this)) revert Teller_InvalidParams();

        // Get the underlying and expiry for the market
        (, , ERC20 underlying, , uint48 expiry, ) = _aggregator
            .getAuctioneer(id_)
            .getMarketInfoForPurchase(id_);

        return bondTokens[underlying][expiry];
    }

    
    function getBondToken(ERC20 underlying_, uint48 expiry_)
        external
        view
        override
        returns (ERC20BondToken)
    {
        // Expiry is rounded to the nearest day at 0000 UTC (in seconds) since bond tokens
        // are only unique to a day, not a specific timestamp.
        uint48 expiry = uint48(expiry_ / 1 days) * 1 days;

        ERC20BondToken bondToken = bondTokens[underlying_][expiry];

        // Revert if token does not exist
        if (address(bondToken) == address(0)) revert Teller_TokenDoesNotExist(underlying_, expiry);

        return bondToken;
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

///      represent bond positions until they vest. Bond tokens can be redeemed for
//       the underlying token 1:1 at or after expiry.
///

///      to save gas on deployment and is based on VestedERC20 (https://github.com/ZeframLou/vested-erc20)
///

contract ERC20BondToken is CloneERC20 {
    /* ========== ERRORS ========== */
    error BondToken_OnlyTeller();

    /* ========== IMMUTABLE PARAMETERS ========== */

    
    
    function underlying() external pure returns (ERC20 _underlying) {
        return ERC20(_getArgAddress(0x41));
    }

    
    
    function expiry() external pure returns (uint48 _expiry) {
        return uint48(_getArgUint256(0x55));
    }

    
    function teller() public pure returns (address _teller) {
        return _getArgAddress(0x75);
    }

    /* ========== MINT/BURN ========== */

    function mint(address to, uint256 amount) external {
        if (msg.sender != teller()) revert BondToken_OnlyTeller();
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        if (msg.sender != teller()) revert BondToken_OnlyTeller();
        _burn(from, amount);
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



interface IBondCallback {
    
    
    
    
    
    
    
    function callback(
        uint256 id_,
        uint256 inputAmount_,
        uint256 outputAmount_
    ) external;

    
    
    
    
    function amountsForMarket(uint256 id_) external view returns (uint256 in_, uint256 out_);

    
    
    
    
    function whitelist(address teller_, uint256 id_) external;

    
    
    
    
    function blacklist(address teller_, uint256 id_) external;

    
    
    
    
    
    function withdraw(
        address to_,
        ERC20 token_,
        uint256 amount_
    ) external;

    
    
    
    
    function deposit(ERC20 token_, uint256 amount_) external;
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

// 
pragma solidity >=0.8.0;






library TransferHelper {
    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.transferFrom.selector, from, to, amount)
        );

        require(
            success &&
                (data.length == 0 || abi.decode(data, (bool))) &&
                address(token).code.length > 0,
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(ERC20.transfer.selector, to, amount)
        );

        require(
            success &&
                (data.length == 0 || abi.decode(data, (bool))) &&
                address(token).code.length > 0,
            "TRANSFER_FAILED"
        );
    }

    // function safeApprove(
    //     ERC20 token,
    //     address to,
    //     uint256 amount
    // ) internal {
    //     (bool success, bytes memory data) = address(token).call(
    //         abi.encodeWithSelector(ERC20.approve.selector, to, amount)
    //     );

    //     require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    // }

    // function safeTransferETH(address to, uint256 amount) internal {
    //     (bool success, ) = to.call{value: amount}(new bytes(0));

    //     require(success, "ETH_TRANSFER_FAILED");
    // }
}