// SPDX-License-Identifier: GNU AGPLv3

/**
 *Submitted for verification at Etherscan.io on 2022-02-23
*/

// Sources flattened with hardhat v2.8.4 https://hardhat.org

// File @rari-capital/solmate/src/auth/[email protected]
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




interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}


// File @rari-capital/solmate/src/tokens/[email protected]


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


// File @rari-capital/solmate/src/utils/[email protected]


pragma solidity >=0.8.0;





library SafeTransferLib {
    /*///////////////////////////////////////////////////////////////
                            ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                           ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 100 because the calldata length is 4 + 32 * 3.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {
        assembly {
            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the revert message into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the same message.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Set success to whether it returned true.
                success := iszero(iszero(mload(0)))
            }
            case 0 {
                // There was no return data.
                success := 1
            }
            default {
                // It returned some malformed input.
                success := 0
            }
        }
    }
}


// File @rari-capital/solmate/src/tokens/[email protected]


pragma solidity >=0.8.0;




contract WETH is ERC20("Wrapped Ether", "WETH", 18) {
    using SafeTransferLib for address;

    event Deposit(address indexed from, uint256 amount);

    event Withdrawal(address indexed to, uint256 amount);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        msg.sender.safeTransferETH(amount);
    }

    receive() external payable virtual {
        deposit();
    }
}


// File @rari-capital/solmate/src/utils/[email protected]


pragma solidity >=0.8.0;




library SafeCastLib {
    function safeCastTo248(uint256 x) internal pure returns (uint248 y) {
        require(x <= type(uint248).max);

        y = uint248(x);
    }

    function safeCastTo128(uint256 x) internal pure returns (uint128 y) {
        require(x <= type(uint128).max);

        y = uint128(x);
    }

    function safeCastTo96(uint256 x) internal pure returns (uint96 y) {
        require(x <= type(uint96).max);

        y = uint96(x);
    }

    function safeCastTo64(uint256 x) internal pure returns (uint64 y) {
        require(x <= type(uint64).max);

        y = uint64(x);
    }

    function safeCastTo32(uint256 x) internal pure returns (uint32 y) {
        require(x <= type(uint32).max);

        y = uint32(x);
    }
}


// File srcBuild/FixedPointMathLib.sol


pragma solidity >=0.8.0;




library FixedPointMathLib {
    /* ///////////////////////////////////////////////////////////////
    SIMPLIFIED FIXED POINT OPERATIONS
    ////////////////////////////////////////////////////////////// */

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD);
        // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD);
        // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y);
        // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y);
        // Equivalent to (x * WAD) / y rounded up.
    }

    /* ///////////////////////////////////////////////////////////////
    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/
    function fmul(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {
        assembly {
        // Store x * y in z for now.
            z := mul(x, y)

        // Equivalent to require(x == 0 || (x * y) / x == y)
            if iszero(or(iszero(x), eq(div(z, x), y))) {
                revert(0, 0)
            }

        // If baseUnit is zero this will return zero instead of reverting.
            z := div(z, baseUnit)
        }
    }

    function fdiv(
        uint256 x,
        uint256 y,
        uint256 baseUnit
    ) internal pure returns (uint256 z) {
        assembly {
        // Store x * baseUnit in z for now.
            z := mul(x, baseUnit)

        // Equivalent to require(y != 0 && (x == 0 || (x * baseUnit) / x == baseUnit))
            if iszero(and(iszero(iszero(y)), or(iszero(x), eq(div(z, x), baseUnit)))) {
                revert(0, 0)
            }

        // We ensure y is not zero above, so there is never division by zero here.
            z := div(z, y)
        }
    }

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
        // Then multiply it by 0 if z is zero, or 1 otherwise.
            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                // 0 ** 0 = 1
                    z := denominator
                }
                default {
                // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                // If n is even, store denominator in z for now.
                    z := denominator
                }
                default {
                // If n is odd, store x in z for now.
                    z := x
                }

            // Shifting right by 1 is like dividing by 2.
                let half := shr(1, denominator)

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
                    x := div(xxRound, denominator)

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
                        z := div(zxRound, denominator)
                    }
                }
            }
        }
    }

    /* ///////////////////////////////////////////////////////////////
    GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
        // Start off with z at 1.
            z := 1

        // Used below to help find a nearby power of 2.
            let y := x

        // Find the lowest power of 2 that is at least sqrt(x).
            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z)
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z)
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z)
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z)
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z)
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z)
            }
            if iszero(lt(y, 0x8)) {
            // Equivalent to 2 ** z.
                z := shl(1, z)
            }

        // Shifting right by 1 is like dividing by 2.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

        // Compute a rounded down version of z.
            let zRoundDown := div(x, z)

        // If zRoundDown is smaller, use it.
            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
}


// File srcBuild/interfaces/Strategy.sol


pragma solidity ^0.8.11;




abstract contract Strategy is ERC20 {
    
    
    
    function isCEther() external view virtual returns (bool);

    
    
    
    function redeemUnderlying(uint256 amount) external virtual returns (uint256);

    
    
    
    
    function balanceOfUnderlying(address user) external virtual returns (uint256);
}



abstract contract ERC20Strategy is Strategy {
    
    
    function underlying() external view virtual returns (ERC20);

    
    
    
    function mint(uint256 amount) external virtual returns (uint256);
}



abstract contract ETHStrategy is Strategy {
    
    
    function mint() external payable virtual;
}


// File srcBuild/Vault.sol


pragma solidity ^0.8.11;









/// aggregator for earning interest on any ERC20 token.

contract Vault is ERC20, Auth {
    using SafeCastLib for uint256;
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /* //////////////////////////////////////////////////////////////
                                 CONSTANTS
    ///////////////////////////////////////////////////////////// */

    
    
    uint256 internal constant MAX_WITHDRAWAL_STACK_SIZE = 32;

    /* //////////////////////////////////////////////////////////////
                                IMMUTABLES
    ///////////////////////////////////////////////////////////// */

    
    ERC20 public immutable UNDERLYING;

    
    
    uint256 internal immutable BASE_UNIT;

    
    
    constructor(ERC20 _UNDERLYING)
        ERC20(
            // ex:Aphra Vader Vault
            string(abi.encodePacked("Aphra ", _UNDERLYING.name(), " Vault")),
            // ex: avVader
            string(abi.encodePacked("av", _UNDERLYING.symbol())),
            // ex: 18
            _UNDERLYING.decimals()
        )
        Auth(Auth(msg.sender).owner(), Auth(msg.sender).authority())
    {
        UNDERLYING = _UNDERLYING;

        BASE_UNIT = 10**decimals;

        // Prevent minting of avTokens until
        // the initialize function is called.
        totalSupply = type(uint256).max;
    }

    /* //////////////////////////////////////////////////////////////
                           FEE CONFIGURATION
    ///////////////////////////////////////////////////////////// */

    
    
    uint256 public feePercent;

    
    
    
    event FeePercentUpdated(address indexed user, uint256 newFeePercent);

    
    
    function setFeePercent(uint256 newFeePercent) external requiresAuth {
        // A fee percentage over 100% doesn't make sense.
        require(newFeePercent <= 1e18, "FEE_TOO_HIGH");

        // Update the fee percentage.
        feePercent = newFeePercent;

        emit FeePercentUpdated(msg.sender, newFeePercent);
    }

    /* //////////////////////////////////////////////////////////////
                        HARVEST CONFIGURATION
    ///////////////////////////////////////////////////////////// */

    
    
    
    event HarvestWindowUpdated(address indexed user, uint128 newHarvestWindow);

    
    
    
    event HarvestDelayUpdated(address indexed user, uint64 newHarvestDelay);

    
    
    
    event HarvestDelayUpdateScheduled(address indexed user, uint64 newHarvestDelay);

    
    /// regardless if they are taking place before the harvest delay has elapsed.
    
    uint128 public harvestWindow;

    
    
    uint64 public harvestDelay;

    
    
    uint64 public nextHarvestDelay;

    
    
    
    function setHarvestWindow(uint128 newHarvestWindow) external requiresAuth {
        // A harvest window longer than the harvest delay doesn't make sense.
        require(newHarvestWindow <= harvestDelay, "WINDOW_TOO_LONG");

        // Update the harvest window.
        harvestWindow = newHarvestWindow;

        emit HarvestWindowUpdated(msg.sender, newHarvestWindow);
    }

    
    
    
    /// been set before, it will be updated immediately, otherwise
    /// it will be scheduled to take effect after the next harvest.
    function setHarvestDelay(uint64 newHarvestDelay) external requiresAuth {
        // A harvest delay of 0 makes harvests vulnerable to sandwich attacks.
        require(newHarvestDelay != 0, "DELAY_CANNOT_BE_ZERO");

        // A harvest delay longer than 1 year doesn't make sense.
        require(newHarvestDelay <= 365 days, "DELAY_TOO_LONG");

        // If the harvest delay is 0, meaning it has not been set before:
        if (harvestDelay == 0) {
            // We'll apply the update immediately.
            harvestDelay = newHarvestDelay;

            emit HarvestDelayUpdated(msg.sender, newHarvestDelay);
        } else {
            // We'll apply the update next harvest.
            nextHarvestDelay = newHarvestDelay;

            emit HarvestDelayUpdateScheduled(msg.sender, newHarvestDelay);
        }
    }

    /* //////////////////////////////////////////////////////////////
                       TARGET FLOAT CONFIGURATION
    ///////////////////////////////////////////////////////////// */

    
    
    uint256 public targetFloatPercent;

    
    
    
    event TargetFloatPercentUpdated(address indexed user, uint256 newTargetFloatPercent);

    
    
    function setTargetFloatPercent(uint256 newTargetFloatPercent) external requiresAuth {
        // A target float percentage over 100% doesn't make sense.
        require(newTargetFloatPercent <= 1e18, "TARGET_TOO_HIGH");

        // Update the target float percentage.
        targetFloatPercent = newTargetFloatPercent;

        emit TargetFloatPercentUpdated(msg.sender, newTargetFloatPercent);
    }

    /* //////////////////////////////////////////////////////////////
                   UNDERLYING IS WETH CONFIGURATION
    ///////////////////////////////////////////////////////////// */

    
    
    bool public underlyingIsWETH;

    
    
    
    event UnderlyingIsWETHUpdated(address indexed user, bool newUnderlyingIsWETH);

    
    
    
    function setUnderlyingIsWETH(bool newUnderlyingIsWETH) external requiresAuth {
        // Ensure the underlying token's decimals match ETH if is WETH being set to true.
        require(!newUnderlyingIsWETH || UNDERLYING.decimals() == 18, "WRONG_DECIMALS");

        // Update whether the Vault treats the underlying as WETH.
        underlyingIsWETH = newUnderlyingIsWETH;

        emit UnderlyingIsWETHUpdated(msg.sender, newUnderlyingIsWETH);
    }

    /* //////////////////////////////////////////////////////////////
                          STRATEGY STORAGE
    ///////////////////////////////////////////////////////////// */

    
    
    uint256 public totalStrategyHoldings;

    
    
    
    struct StrategyData {
        // Used to determine if the Vault will operate on a strategy.
        bool trusted;
        // Used to determine profit and loss during harvests of the strategy.
        uint248 balance;
    }

    
    mapping(Strategy => StrategyData) public getStrategyData;

    /* //////////////////////////////////////////////////////////////
                             HARVEST STORAGE
    ///////////////////////////////////////////////////////////// */

    
    
    uint64 public lastHarvestWindowStart;

    
    uint64 public lastHarvest;

    
    uint128 public maxLockedProfit;

    /* //////////////////////////////////////////////////////////////
                        WITHDRAWAL STACK STORAGE
    ///////////////////////////////////////////////////////////// */

    
    
    
    /// withdrawal time, not validated upfront, meaning the stack may not reflect the "true" set used for withdrawals.
    Strategy[] public withdrawalStack;

    
    
    
    /// but we need a way to allow external contracts and users to access the whole array.
    function getWithdrawalStack() external view returns (Strategy[] memory) {
        return withdrawalStack;
    }

    /* //////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    event Deposit(address indexed user, uint256 underlyingAmount);

    
    
    
    event Withdraw(address indexed user, uint256 underlyingAmount);

    
    
    function deposit(uint256 underlyingAmount) external {
        // Determine the equivalent amount of avTokens and mint them.
        _mint(msg.sender, underlyingAmount.fdiv(exchangeRate(), BASE_UNIT));

        emit Deposit(msg.sender, underlyingAmount);

        // Transfer in underlying tokens from the user.
        // This will revert if the user does not have the amount specified.
        UNDERLYING.safeTransferFrom(msg.sender, address(this), underlyingAmount);
    }

    
    
    function withdraw(uint256 underlyingAmount) external {
        // Determine the equivalent amount of avTokens and burn them.
        // This will revert if the user does not have enough avTokens.
        _burn(msg.sender, underlyingAmount.fdiv(exchangeRate(), BASE_UNIT));

        emit Withdraw(msg.sender, underlyingAmount);

        // Withdraw from strategies if needed and transfer.
        transferUnderlyingTo(msg.sender, underlyingAmount);
    }

    
    
    function redeem(uint256 avTokenAmount) external {
        // Determine the equivalent amount of underlying tokens.
        uint256 underlyingAmount = avTokenAmount.fmul(exchangeRate(), BASE_UNIT);

        // Burn the provided amount of avTokens.
        // This will revert if the user does not have enough avTokens.
        _burn(msg.sender, avTokenAmount);

        emit Withdraw(msg.sender, underlyingAmount);

        // Withdraw from strategies if needed and transfer.
        transferUnderlyingTo(msg.sender, underlyingAmount);
    }

    
    
    
    
    function transferUnderlyingTo(address recipient, uint256 underlyingAmount) internal {
        // Get the Vault's floating balance.
        uint256 float = totalFloat();

        // If the amount is greater than the float, withdraw from strategies.
        if (underlyingAmount > float) {
            // Compute the amount needed to reach our target float percentage.
            uint256 floatMissingForTarget = (totalHoldings() - underlyingAmount).fmul(targetFloatPercent, 1e18);

            // Compute the bare minimum amount we need for this withdrawal.
            uint256 floatMissingForWithdrawal = underlyingAmount - float;

            // Pull enough to cover the withdrawal and reach our target float percentage.
            pullFromWithdrawalStack(floatMissingForWithdrawal + floatMissingForTarget);
        }

        // Transfer the provided amount of underlying tokens.
        UNDERLYING.safeTransfer(recipient, underlyingAmount);
    }

    /* //////////////////////////////////////////////////////////////
                        VAULT ACCOUNTING LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    function balanceOfUnderlying(address user) external view returns (uint256) {
        return balanceOf[user].fmul(exchangeRate(), BASE_UNIT);
    }

    
    
    function exchangeRate() public view returns (uint256) {
        // Get the total supply of avTokens.
        uint256 avTokenSupply = totalSupply;

        // If there are no avTokens in circulation, return an exchange rate of 1:1.
        if (avTokenSupply == 0) return BASE_UNIT;

        // Calculate the exchange rate by dividing the total holdings by the avToken supply.
        return totalHoldings().fdiv(avTokenSupply, BASE_UNIT);
    }

    
    
    function totalHoldings() public view returns (uint256 totalUnderlyingHeld) {
        unchecked {
            // Cannot underflow as locked profit can't exceed total strategy holdings.
            totalUnderlyingHeld = totalStrategyHoldings - lockedProfit();
        }

        // Include our floating balance in the total.
        totalUnderlyingHeld += totalFloat();
    }

    
    
    function lockedProfit() public view returns (uint256) {
        // Get the last harvest and harvest delay.
        uint256 previousHarvest = lastHarvest;
        uint256 harvestInterval = harvestDelay;

        unchecked {
            // If the harvest delay has passed, there is no locked profit.
            // Cannot overflow on human timescales since harvestInterval is capped.
            if (block.timestamp >= previousHarvest + harvestInterval) return 0;

            // Get the maximum amount we could return.
            uint256 maximumLockedProfit = maxLockedProfit;

            // Compute how much profit remains locked based on the last harvest and harvest delay.
            // It's impossible for the previous harvest to be in the future, so this will never underflow.
            return maximumLockedProfit - (maximumLockedProfit * (block.timestamp - previousHarvest)) / harvestInterval;
        }
    }

    
    
    function totalFloat() public view returns (uint256) {
        return UNDERLYING.balanceOf(address(this));
    }

    /* //////////////////////////////////////////////////////////////
                             HARVEST LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    event Harvest(address indexed user, Strategy[] strategies);

    
    
    
    /// harvest window or before the harvest delay has passed.
    function harvest(Strategy[] calldata strategies) external requiresAuth {
        // If this is the first harvest after the last window:
        if (block.timestamp >= lastHarvest + harvestDelay) {
            // Set the harvest window's start timestamp.
            // Cannot overflow 64 bits on human timescales.
            lastHarvestWindowStart = uint64(block.timestamp);
        } else {
            // We know this harvest is not the first in the window so we need to ensure it's within it.
            require(block.timestamp <= lastHarvestWindowStart + harvestWindow, "BAD_HARVEST_TIME");
        }

        // Get the Vault's current total strategy holdings.
        uint256 oldTotalStrategyHoldings = totalStrategyHoldings;

        // Used to store the total profit accrued by the strategies.
        uint256 totalProfitAccrued;

        // Used to store the new total strategy holdings after harvesting.
        uint256 newTotalStrategyHoldings = oldTotalStrategyHoldings;

        // Will revert if any of the specified strategies are untrusted.
        for (uint256 i = 0; i < strategies.length; i++) {
            // Get the strategy at the current index.
            Strategy strategy = strategies[i];

            // If an untrusted strategy could be harvested a malicious user could use
            // a fake strategy that over-reports holdings to manipulate the exchange rate.
            require(getStrategyData[strategy].trusted, "UNTRUSTED_STRATEGY");

            // Get the strategy's previous and current balance.
            uint256 balanceLastHarvest = getStrategyData[strategy].balance;
            uint256 balanceThisHarvest = strategy.balanceOfUnderlying(address(this));

            // Update the strategy's stored balance. Cast overflow is unrealistic.
            getStrategyData[strategy].balance = balanceThisHarvest.safeCastTo248();

            // Increase/decrease newTotalStrategyHoldings based on the profit/loss registered.
            // We cannot wrap the subtraction in parenthesis as it would underflow if the strategy had a loss.
            newTotalStrategyHoldings = newTotalStrategyHoldings + balanceThisHarvest - balanceLastHarvest;

            unchecked {
                // Update the total profit accrued while counting losses as zero profit.
                // Cannot overflow as we already increased total holdings without reverting.
                totalProfitAccrued += balanceThisHarvest > balanceLastHarvest
                    ? balanceThisHarvest - balanceLastHarvest // Profits since last harvest.
                    : 0; // If the strategy registered a net loss we don't have any new profit.
            }
        }

        // Compute fees as the fee percent multiplied by the profit.
        uint256 feesAccrued = totalProfitAccrued.fmul(feePercent, 1e18);

        // If we accrued any fees, mint an equivalent amount of avTokens.
        // Authorized users can claim the newly minted avTokens via claimFees.
        _mint(address(this), feesAccrued.fdiv(exchangeRate(), BASE_UNIT));

        // Update max unlocked profit based on any remaining locked profit plus new profit.
        maxLockedProfit = (lockedProfit() + totalProfitAccrued - feesAccrued).safeCastTo128();

        // Set strategy holdings to our new total.
        totalStrategyHoldings = newTotalStrategyHoldings;

        // Update the last harvest timestamp.
        // Cannot overflow on human timescales.
        lastHarvest = uint64(block.timestamp);

        emit Harvest(msg.sender, strategies);

        // Get the next harvest delay.
        uint64 newHarvestDelay = nextHarvestDelay;

        // If the next harvest delay is not 0:
        if (newHarvestDelay != 0) {
            // Update the harvest delay.
            harvestDelay = newHarvestDelay;

            // Reset the next harvest delay.
            nextHarvestDelay = 0;

            emit HarvestDelayUpdated(msg.sender, newHarvestDelay);
        }
    }

    /* //////////////////////////////////////////////////////////////
                    STRATEGY DEPOSIT/WITHDRAWAL LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    
    event StrategyDeposit(address indexed user, Strategy indexed strategy, uint256 underlyingAmount);

    
    
    
    
    event StrategyWithdrawal(address indexed user, Strategy indexed strategy, uint256 underlyingAmount);

    
    
    
    function depositIntoStrategy(Strategy strategy, uint256 underlyingAmount) external requiresAuth {
        // A strategy must be trusted before it can be deposited into.
        require(getStrategyData[strategy].trusted, "UNTRUSTED_STRATEGY");

        // Increase totalStrategyHoldings to account for the deposit.
        totalStrategyHoldings += underlyingAmount;

        unchecked {
            // Without this the next harvest would count the deposit as profit.
            // Cannot overflow as the balance of one strategy can't exceed the sum of all.
            getStrategyData[strategy].balance += underlyingAmount.safeCastTo248();
        }

        emit StrategyDeposit(msg.sender, strategy, underlyingAmount);

        // We need to deposit differently if the strategy takes ETH.
        if (strategy.isCEther()) {
            // Unwrap the right amount of WETH.
            WETH(payable(address(UNDERLYING))).withdraw(underlyingAmount);

            // Deposit into the strategy and assume it will revert on error.
            ETHStrategy(address(strategy)).mint{value: underlyingAmount}();
        } else {
            // Approve underlyingAmount to the strategy so we can deposit.
            UNDERLYING.safeApprove(address(strategy), underlyingAmount);

            // Deposit into the strategy and revert if it returns an error code.
            require(ERC20Strategy(address(strategy)).mint(underlyingAmount) == 0, "MINT_FAILED");
        }
    }

    
    
    
    
    function withdrawFromStrategy(Strategy strategy, uint256 underlyingAmount) external requiresAuth {
        // A strategy must be trusted before it can be withdrawn from.
        require(getStrategyData[strategy].trusted, "UNTRUSTED_STRATEGY");

        // Without this the next harvest would count the withdrawal as a loss.
        getStrategyData[strategy].balance -= underlyingAmount.safeCastTo248();

        unchecked {
            // Decrease totalStrategyHoldings to account for the withdrawal.
            // Cannot underflow as the balance of one strategy will never exceed the sum of all.
            totalStrategyHoldings -= underlyingAmount;
        }

        emit StrategyWithdrawal(msg.sender, strategy, underlyingAmount);

        // Withdraw from the strategy and revert if it returns an error code.
        require(strategy.redeemUnderlying(underlyingAmount) == 0, "REDEEM_FAILED");

        // Wrap the withdrawn Ether into WETH if necessary.
        if (strategy.isCEther()) WETH(payable(address(UNDERLYING))).deposit{value: underlyingAmount}();
    }

    /* //////////////////////////////////////////////////////////////
                      STRATEGY TRUST/DISTRUST LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    event StrategyTrusted(address indexed user, Strategy indexed strategy);

    
    
    
    event StrategyDistrusted(address indexed user, Strategy indexed strategy);

    
    
    function trustStrategy(Strategy strategy) external requiresAuth {
        // Ensure the strategy accepts the correct underlying token.
        // If the strategy accepts ETH the Vault should accept WETH, it'll handle wrapping when necessary.
        require(
            strategy.isCEther() ? underlyingIsWETH : ERC20Strategy(address(strategy)).underlying() == UNDERLYING,
            "WRONG_UNDERLYING"
        );

        // Store the strategy as trusted.
        getStrategyData[strategy].trusted = true;

        emit StrategyTrusted(msg.sender, strategy);
    }

    
    
    function distrustStrategy(Strategy strategy) external requiresAuth {
        // Store the strategy as untrusted.
        getStrategyData[strategy].trusted = false;

        emit StrategyDistrusted(msg.sender, strategy);
    }

    /* //////////////////////////////////////////////////////////////
                         WITHDRAWAL STACK LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    event WithdrawalStackPushed(address indexed user, Strategy indexed pushedStrategy);

    
    
    
    event WithdrawalStackPopped(address indexed user, Strategy indexed poppedStrategy);

    
    
    
    event WithdrawalStackSet(address indexed user, Strategy[] replacedWithdrawalStack);

    
    
    
    
    
    event WithdrawalStackIndexReplaced(
        address indexed user,
        uint256 index,
        Strategy indexed replacedStrategy,
        Strategy indexed replacementStrategy
    );

    
    
    
    
    
    event WithdrawalStackIndexReplacedWithTip(
        address indexed user,
        uint256 index,
        Strategy indexed replacedStrategy,
        Strategy indexed previousTipStrategy
    );

    
    
    
    
    
    
    event WithdrawalStackIndexesSwapped(
        address indexed user,
        uint256 index1,
        uint256 index2,
        Strategy indexed newStrategy1,
        Strategy indexed newStrategy2
    );

    
    
    
    function pullFromWithdrawalStack(uint256 underlyingAmount) internal {
        // We will update this variable as we pull from strategies.
        uint256 amountLeftToPull = underlyingAmount;

        // We'll start at the tip of the stack and traverse backwards.
        uint256 currentIndex = withdrawalStack.length - 1;

        // Iterate in reverse so we pull from the stack in a "last in, first out" manner.
        // Will revert due to underflow if we empty the stack before pulling the desired amount.
        for (; ; currentIndex--) {
            // Get the strategy at the current stack index.
            Strategy strategy = withdrawalStack[currentIndex];

            // Get the balance of the strategy before we withdraw from it.
            uint256 strategyBalance = getStrategyData[strategy].balance;

            // If the strategy is currently untrusted or was already depleted:
            if (!getStrategyData[strategy].trusted || strategyBalance == 0) {
                // Remove it from the stack.
                withdrawalStack.pop();

                emit WithdrawalStackPopped(msg.sender, strategy);

                // Move onto the next strategy.
                continue;
            }

            // We want to pull as much as we can from the strategy, but no more than we need.
            uint256 amountToPull = strategyBalance > amountLeftToPull ? amountLeftToPull : strategyBalance;

            unchecked {
                // Compute the balance of the strategy that will remain after we withdraw.
                // Cannot underflow as we cap the amount to pull at the strategy's balance.
                uint256 strategyBalanceAfterWithdrawal = strategyBalance - amountToPull;

                // Without this the next harvest would count the withdrawal as a loss.
                getStrategyData[strategy].balance = strategyBalanceAfterWithdrawal.safeCastTo248();

                // Adjust our goal based on how much we can pull from the strategy.
                // Cannot underflow as we cap the amount to pull at the amount left to pull.
                amountLeftToPull -= amountToPull;

                emit StrategyWithdrawal(msg.sender, strategy, amountToPull);

                // Withdraw from the strategy and revert if returns an error code.
                require(strategy.redeemUnderlying(amountToPull) == 0, "REDEEM_FAILED");

                // If we fully depleted the strategy:
                if (strategyBalanceAfterWithdrawal == 0) {
                    // Remove it from the stack.
                    withdrawalStack.pop();

                    emit WithdrawalStackPopped(msg.sender, strategy);
                }
            }

            // If we've pulled all we need, exit the loop.
            if (amountLeftToPull == 0) break;
        }

        unchecked {
            // Account for the withdrawals done in the loop above.
            // Cannot underflow as the balances of some strategies cannot exceed the sum of all.
            totalStrategyHoldings -= underlyingAmount;
        }

        // Cache the Vault's balance of ETH.
        uint256 ethBalance = address(this).balance;

        // If the Vault's underlying token is WETH compatible and we have some ETH, wrap it into WETH.
        if (ethBalance != 0 && underlyingIsWETH) WETH(payable(address(UNDERLYING))).deposit{value: ethBalance}();
    }

    
    
    
    /// filtered out when encountered at withdrawal time, not validated upfront.
    function pushToWithdrawalStack(Strategy strategy) external requiresAuth {
        // Ensure pushing the strategy will not cause the stack exceed its limit.
        require(withdrawalStack.length < MAX_WITHDRAWAL_STACK_SIZE, "STACK_FULL");

        // Push the strategy to the front of the stack.
        withdrawalStack.push(strategy);

        emit WithdrawalStackPushed(msg.sender, strategy);
    }

    
    
    /// than expected to the stack while a popFromWithdrawalStack transaction is pending.
    function popFromWithdrawalStack() external requiresAuth {
        // Get the (soon to be) popped strategy.
        Strategy poppedStrategy = withdrawalStack[withdrawalStack.length - 1];

        // Pop the first strategy in the stack.
        withdrawalStack.pop();

        emit WithdrawalStackPopped(msg.sender, poppedStrategy);
    }

    
    
    
    /// filtered out when encountered at withdrawal time, not validated upfront.
    function setWithdrawalStack(Strategy[] calldata newStack) external requiresAuth {
        // Ensure the new stack is not larger than the maximum stack size.
        require(newStack.length <= MAX_WITHDRAWAL_STACK_SIZE, "STACK_TOO_BIG");

        // Replace the withdrawal stack.
        withdrawalStack = newStack;

        emit WithdrawalStackSet(msg.sender, newStack);
    }

    
    
    
    
    /// filtered out when encountered at withdrawal time, not validated upfront.
    function replaceWithdrawalStackIndex(uint256 index, Strategy replacementStrategy) external requiresAuth {
        // Get the (soon to be) replaced strategy.
        Strategy replacedStrategy = withdrawalStack[index];

        // Update the index with the replacement strategy.
        withdrawalStack[index] = replacementStrategy;

        emit WithdrawalStackIndexReplaced(msg.sender, index, replacedStrategy, replacementStrategy);
    }

    
    
    function replaceWithdrawalStackIndexWithTip(uint256 index) external requiresAuth {
        // Get the (soon to be) previous tip and strategy we will replace at the index.
        Strategy previousTipStrategy = withdrawalStack[withdrawalStack.length - 1];
        Strategy replacedStrategy = withdrawalStack[index];

        // Replace the index specified with the tip of the stack.
        withdrawalStack[index] = previousTipStrategy;

        // Remove the now duplicated tip from the array.
        withdrawalStack.pop();

        emit WithdrawalStackIndexReplacedWithTip(msg.sender, index, replacedStrategy, previousTipStrategy);
    }

    
    
    
    function swapWithdrawalStackIndexes(uint256 index1, uint256 index2) external requiresAuth {
        // Get the (soon to be) new strategies at each index.
        Strategy newStrategy2 = withdrawalStack[index1];
        Strategy newStrategy1 = withdrawalStack[index2];

        // Swap the strategies at both indexes.
        withdrawalStack[index1] = newStrategy1;
        withdrawalStack[index2] = newStrategy2;

        emit WithdrawalStackIndexesSwapped(msg.sender, index1, index2, newStrategy1, newStrategy2);
    }

    /* //////////////////////////////////////////////////////////////
                         SEIZE STRATEGY LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    event StrategySeized(address indexed user, Strategy indexed strategy);

    
    
    
    /// strategy requires interaction outside of the Vault's standard operating procedures.
    function seizeStrategy(Strategy strategy) external requiresAuth {
        // Get the strategy's last reported balance of underlying tokens.
        uint256 strategyBalance = getStrategyData[strategy].balance;

        // If the strategy's balance exceeds the Vault's current
        // holdings, instantly unlock any remaining locked profit.
        if (strategyBalance > totalHoldings()) maxLockedProfit = 0;

        // Set the strategy's balance to 0.
        getStrategyData[strategy].balance = 0;

        unchecked {
            // Decrease totalStrategyHoldings to account for the seize.
            // Cannot underflow as the balance of one strategy will never exceed the sum of all.
            totalStrategyHoldings -= strategyBalance;
        }

        emit StrategySeized(msg.sender, strategy);

        // Transfer all of the strategy's tokens to the caller.
        ERC20(strategy).safeTransfer(msg.sender, strategy.balanceOf(address(this)));
    }

    /* //////////////////////////////////////////////////////////////
                             FEE CLAIM LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    
    event FeesClaimed(address indexed user, uint256 avTokenAmount);

    
    
    
    function claimFees(uint256 avTokenAmount) external requiresAuth {
        emit FeesClaimed(msg.sender, avTokenAmount);

        // Transfer the provided amount of avTokens to the caller.
        ERC20(this).safeTransfer(msg.sender, avTokenAmount);
    }

    /* //////////////////////////////////////////////////////////////
                    INITIALIZATION AND DESTRUCTION LOGIC
    ///////////////////////////////////////////////////////////// */

    
    
    event Initialized(address indexed user);

    
    
    bool public isInitialized;

    
    
    function initialize() external requiresAuth {
        // Ensure the Vault has not already been initialized.
        require(!isInitialized, "ALREADY_INITIALIZED");

        // Mark the Vault as initialized.
        isInitialized = true;

        // Open for deposits.
        totalSupply = 0;

        emit Initialized(msg.sender);
    }

    
    
    function destroy() external requiresAuth {
        selfdestruct(payable(msg.sender));
    }

    /* //////////////////////////////////////////////////////////////
                          RECIEVE ETHER LOGIC
    ///////////////////////////////////////////////////////////// */

    
    receive() external payable {}
}