// SPDX-License-Identifier: AGPL-3.0

/**
 *Submitted for verification at Etherscan.io on 2022-07-08
*/

// 
pragma solidity ^0.8.4;





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





library SafeTransferLib {
    event Debug(bool one, bool two, uint256 retsize);

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
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
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
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
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
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}




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
            // Start off with z at 1.
            z := 1

            // Used below to help find a nearby power of 2.
            let y := x

            // Find the lowest power of 2 that is at least sqrt(x).
            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z) // Like multiplying by 2 ** 64.
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z) // Like multiplying by 2 ** 32.
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z) // Like multiplying by 2 ** 16.
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z) // Like multiplying by 2 ** 8.
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z) // Like multiplying by 2 ** 4.
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z) // Like multiplying by 2 ** 2.
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



abstract contract ERC4626 is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    ERC20 public immutable asset;

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        // Check for rounding error since we round down in previewRedeem.
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}

// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol
// Simplified by BoringCrypto

contract BoringOwnableData {
    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    
    /// Can only be invoked by the current `owner`.
    
    
    
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}




abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}



library Bytes32AddressLib {
    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {
        return address(uint160(uint256(bytesValue)));
    }

    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {
        return bytes32(bytes20(addressValue));
    }
}





contract BaseERC20 is ERC20 {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error Error_NotGate();

    /// -----------------------------------------------------------------------
    /// Immutable parameters
    /// -----------------------------------------------------------------------

    Gate public immutable gate;
    address public immutable vault;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        string memory name_,
        string memory symbol_,
        Gate gate_,
        address vault_
    ) ERC20(name_, symbol_, gate_.getUnderlyingOfVault(vault_).decimals()) {
        gate = gate_;
        vault = vault_;
    }

    /// -----------------------------------------------------------------------
    /// Gate-callable functions
    /// -----------------------------------------------------------------------

    function gateMint(address to, uint256 amount) external virtual {
        if (msg.sender != address(gate)) {
            revert Error_NotGate();
        }

        _mint(to, amount);
    }

    function gateBurn(address from, uint256 amount) external virtual {
        if (msg.sender != address(gate)) {
            revert Error_NotGate();
        }

        _burn(from, amount);
    }
}




contract NegativeYieldToken is BaseERC20 {
    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(Gate gate_, address vault_)
        BaseERC20(
            gate_.negativeYieldTokenName(vault_),
            gate_.negativeYieldTokenSymbol(vault_),
            gate_,
            vault_
        )
    {}
}




contract PerpetualYieldToken is BaseERC20 {
    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(Gate gate_, address vault_)
        BaseERC20(
            gate_.perpetualYieldTokenName(vault_),
            gate_.perpetualYieldTokenSymbol(vault_),
            gate_,
            vault_
        )
    {}

    /// -----------------------------------------------------------------------
    /// ERC20 overrides
    /// -----------------------------------------------------------------------

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        // load balances to save gas
        uint256 fromBalance = balanceOf[msg.sender];
        uint256 toBalance = balanceOf[to];

        // call transfer hook
        gate.beforePerpetualYieldTokenTransfer(
            msg.sender,
            to,
            amount,
            fromBalance,
            toBalance
        );

        // do transfer
        // skip during self transfers since toBalance is cached
        // which leads to free minting, a critical issue
        if (msg.sender != to) {
            balanceOf[msg.sender] = fromBalance - amount;

            // Cannot overflow because the sum of all user
            // balances can't exceed the max uint256 value.
            unchecked {
                balanceOf[to] = toBalance + amount;
            }
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        // load balances to save gas
        uint256 fromBalance = balanceOf[from];
        uint256 toBalance = balanceOf[to];

        // call transfer hook
        gate.beforePerpetualYieldTokenTransfer(
            from,
            to,
            amount,
            fromBalance,
            toBalance
        );

        // update allowance
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        // do transfer
        // skip during self transfers since toBalance is cached
        // which leads to free minting, a critical issue
        if (from != to) {
            balanceOf[from] = fromBalance - amount;

            // Cannot overflow because the sum of all user
            // balances can't exceed the max uint256 value.
            unchecked {
                balanceOf[to] = toBalance + amount;
            }
        }

        emit Transfer(from, to, amount);

        return true;
    }
}

contract Factory is BoringOwnable {
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using Bytes32AddressLib for address;
    using Bytes32AddressLib for bytes32;

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error Error_ProtocolFeeRecipientIsZero();

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event SetProtocolFee(ProtocolFeeInfo protocolFeeInfo_);
    event DeployYieldTokenPair(
        Gate indexed gate,
        address indexed vault,
        NegativeYieldToken nyt,
        PerpetualYieldToken pyt
    );

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    struct ProtocolFeeInfo {
        uint8 fee; // each increment represents 0.1%, so max is 25.5%
        address recipient;
    }
    
    ProtocolFeeInfo public protocolFeeInfo;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(ProtocolFeeInfo memory protocolFeeInfo_) {
        if (
            protocolFeeInfo_.fee != 0 &&
            protocolFeeInfo_.recipient == address(0)
        ) {
            revert Error_ProtocolFeeRecipientIsZero();
        }
        protocolFeeInfo = protocolFeeInfo_;
        emit SetProtocolFee(protocolFeeInfo_);
    }

    /// -----------------------------------------------------------------------
    /// User actions
    /// -----------------------------------------------------------------------

    
    
    
    
    
    
    function deployYieldTokenPair(Gate gate, address vault)
        public
        virtual
        returns (NegativeYieldToken nyt, PerpetualYieldToken pyt)
    {
        // Use the CREATE2 opcode to deploy new NegativeYieldToken and PerpetualYieldToken contracts.
        // This will revert if the contracts have already been deployed,
        // as the salt & bytecode hash would be the same and we can't deploy with it twice.
        nyt = new NegativeYieldToken{salt: bytes32(0)}(gate, vault);
        pyt = new PerpetualYieldToken{salt: bytes32(0)}(gate, vault);

        emit DeployYieldTokenPair(gate, vault, nyt, pyt);
    }

    /// -----------------------------------------------------------------------
    /// Getters
    /// -----------------------------------------------------------------------

    
    
    
    
    
    function getNegativeYieldToken(Gate gate, address vault)
        public
        view
        virtual
        returns (NegativeYieldToken)
    {
        return
            NegativeYieldToken(_computeYieldTokenAddress(gate, vault, false));
    }

    
    
    
    
    
    function getPerpetualYieldToken(Gate gate, address vault)
        public
        view
        virtual
        returns (PerpetualYieldToken)
    {
        return
            PerpetualYieldToken(_computeYieldTokenAddress(gate, vault, true));
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    
    /// Only callable by the owner.
    
    function ownerSetProtocolFee(ProtocolFeeInfo calldata protocolFeeInfo_)
        external
        virtual
        onlyOwner
    {
        if (
            protocolFeeInfo_.fee != 0 &&
            protocolFeeInfo_.recipient == address(0)
        ) {
            revert Error_ProtocolFeeRecipientIsZero();
        }
        protocolFeeInfo = protocolFeeInfo_;

        emit SetProtocolFee(protocolFeeInfo_);
    }

    /// -----------------------------------------------------------------------
    /// Internal utilities
    /// -----------------------------------------------------------------------

    
    function _computeYieldTokenAddress(
        Gate gate,
        address vault,
        bool isPerpetualYieldToken
    ) internal view virtual returns (address) {
        return
            keccak256(
                abi.encodePacked(
                    // Prefix:
                    bytes1(0xFF),
                    // Creator:
                    address(this),
                    // Salt:
                    bytes32(0),
                    // Bytecode hash:
                    keccak256(
                        abi.encodePacked(
                            // Deployment bytecode:
                            isPerpetualYieldToken
                                ? type(PerpetualYieldToken).creationCode
                                : type(NegativeYieldToken).creationCode,
                            // Constructor arguments:
                            abi.encode(gate, vault)
                        )
                    )
                )
            ).fromLast20Bytes(); // Convert the CREATE2 hash into an address.
    }
}

abstract contract IxPYT is ERC4626 {
    function sweep(address receiver) external virtual returns (uint256 shares);
}




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
            uint256 twos = (0 - denominator) & denominator;
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
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}



abstract contract Multicall {
    function multicall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                data[i]
            );

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}




/// that requires an approval in a single transaction.
abstract contract SelfPermit {
    function selfPermit(
        ERC20 token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        token.permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    function selfPermitIfNecessary(
        ERC20 token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        if (token.allowance(msg.sender, address(this)) < value)
            selfPermit(token, value, deadline, v, r, s);
    }
}




/// and PerpetualYieldToken, as well as claim the yield earned by PYTs.

/// a specific vault protocol (e.g. YearnGate supports YearnVault). Each Gate handles
/// all vaults & associated NYTs/PYTs of a specific vault protocol.
///
/// Vaults are yield-generating contracts used by Gate. Gate makes several assumptions about
/// a vault:
/// 1) A vault has a single associated underlying token that is immutable.
/// 2) A vault gives depositors yield denominated in the underlying token.
/// 3) A vault depositor owns shares in the vault, which represents their deposit.
/// 4) Vaults have a notion of "price per share", which is the amount of underlying tokens
///    each vault share can be redeemed for.
/// 5) If vault shares are represented using an ERC20 token, then the ERC20 token contract must be
///    the vault contract itself.
abstract contract Gate is
    ReentrancyGuard,
    Multicall,
    SelfPermit,
    BoringOwnable
{
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using SafeTransferLib for ERC20;
    using SafeTransferLib for ERC4626;

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error Error_InvalidInput();
    error Error_VaultSharesNotERC20();
    error Error_TokenPairNotDeployed();
    error Error_EmergencyExitNotActivated();
    error Error_SenderNotPerpetualYieldToken();
    error Error_EmergencyExitAlreadyActivated();

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event EnterWithUnderlying(
        address sender,
        address indexed nytRecipient,
        address indexed pytRecipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    );
    event EnterWithVaultShares(
        address sender,
        address indexed nytRecipient,
        address indexed pytRecipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    );
    event ExitToUnderlying(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    );
    event ExitToVaultShares(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    );
    event ClaimYieldInUnderlying(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        uint256 underlyingAmount
    );
    event ClaimYieldInVaultShares(
        address indexed sender,
        address indexed recipient,
        address indexed vault,
        uint256 vaultSharesAmount
    );
    event ClaimYieldAndEnter(
        address sender,
        address indexed nytRecipient,
        address indexed pytRecipient,
        address indexed vault,
        IxPYT xPYT,
        uint256 amount
    );

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    
    
    /// Should be a value in the range [0, PRECISION]
    struct EmergencyExitStatus {
        bool activated;
        uint96 pytPriceInUnderlying;
    }

    /// -----------------------------------------------------------------------
    /// Constants
    /// -----------------------------------------------------------------------

    
    uint256 internal constant PRECISION_DECIMALS = 27;

    
    uint256 internal constant PRECISION = 10**PRECISION_DECIMALS;

    /// -----------------------------------------------------------------------
    /// Immutable parameters
    /// -----------------------------------------------------------------------

    Factory public immutable factory;

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    
    /// Uses PRECISION.
    
    mapping(address => uint256) public pricePerVaultShareStored;

    
    /// Scaled by PRECISION.
    
    mapping(address => uint256) public yieldPerTokenStored;

    
    /// with the gate/PYT. Shifted by 1, so e.g. 3 represents 2, 10 represents 9.
    
    /// The value is shifted to use 0 for representing uninitialized users.
    mapping(address => mapping(address => uint256))
        public userYieldPerTokenStored;

    
    /// with the gate/PYT (without calling claimYieldInUnderlying()).
    /// Shifted by 1, so e.g. 3 represents 2, 10 represents 9.
    
    mapping(address => mapping(address => uint256)) public userAccruedYield;

    
    
    mapping(address => EmergencyExitStatus) public emergencyExitStatusOfVault;

    /// -----------------------------------------------------------------------
    /// Initialization
    /// -----------------------------------------------------------------------

    constructor(Factory factory_) {
        factory = factory_;
    }

    /// -----------------------------------------------------------------------
    /// User actions
    /// -----------------------------------------------------------------------

    
    /// The amount of NYT and PYT minted will be equal to the underlying token amount.
    
    /// If the NYT and PYT for the specified vault haven't been deployed yet, this call will
    /// deploy them before proceeding, which will increase the gas cost significantly.
    
    
    
    
    
    
    function enterWithUnderlying(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    ) external virtual nonReentrant returns (uint256 mintAmount) {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (underlyingAmount == 0) {
            return 0;
        }

        /// -----------------------------------------------------------------------
        /// State updates & effects
        /// -----------------------------------------------------------------------

        // mint PYT and NYT
        mintAmount = underlyingAmount;
        _enter(
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            underlyingAmount,
            getPricePerVaultShare(vault)
        );

        // transfer underlying from msg.sender to address(this)
        ERC20 underlying = getUnderlyingOfVault(vault);
        underlying.safeTransferFrom(
            msg.sender,
            address(this),
            underlyingAmount
        );

        // deposit underlying into vault
        _depositIntoVault(underlying, underlyingAmount, vault);

        emit EnterWithUnderlying(
            msg.sender,
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            underlyingAmount
        );
    }

    
    
    /// If the NYT and PYT for the specified vault haven't been deployed yet, this call will
    /// deploy them before proceeding, which will increase the gas cost significantly.
    
    
    
    
    
    
    function enterWithVaultShares(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    ) external virtual nonReentrant returns (uint256 mintAmount) {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (vaultSharesAmount == 0) {
            return 0;
        }

        // only supported if vault shares are ERC20
        if (!vaultSharesIsERC20()) {
            revert Error_VaultSharesNotERC20();
        }

        /// -----------------------------------------------------------------------
        /// State updates & effects
        /// -----------------------------------------------------------------------

        // mint PYT and NYT
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        mintAmount = _vaultSharesAmountToUnderlyingAmount(
            vault,
            vaultSharesAmount,
            updatedPricePerVaultShare
        );
        _enter(
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            mintAmount,
            updatedPricePerVaultShare
        );

        // transfer vault tokens from msg.sender to address(this)
        ERC20(vault).safeTransferFrom(
            msg.sender,
            address(this),
            vaultSharesAmount
        );

        emit EnterWithVaultShares(
            msg.sender,
            nytRecipient,
            pytRecipient,
            vault,
            xPYT,
            vaultSharesAmount
        );
    }

    
    /// The amount of NYT and PYT burned will be equal to the underlying token amount.
    
    /// If the NYT and PYT for the specified vault haven't been deployed yet, this call will
    /// revert.
    
    
    
    
    
    function exitToUnderlying(
        address recipient,
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount
    ) external virtual nonReentrant returns (uint256 burnAmount) {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (underlyingAmount == 0) {
            return 0;
        }

        /// -----------------------------------------------------------------------
        /// State updates & effects
        /// -----------------------------------------------------------------------

        // burn PYT and NYT
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        burnAmount = underlyingAmount;
        _exit(vault, xPYT, underlyingAmount, updatedPricePerVaultShare);

        // withdraw underlying from vault to recipient
        // don't check balance since user can just withdraw slightly less
        // saves gas this way
        underlyingAmount = _withdrawFromVault(
            recipient,
            vault,
            underlyingAmount,
            updatedPricePerVaultShare,
            false
        );

        emit ExitToUnderlying(
            msg.sender,
            recipient,
            vault,
            xPYT,
            underlyingAmount
        );
    }

    
    /// The amount of NYT and PYT burned will be equal to the underlying token amount.
    
    /// If the NYT and PYT for the specified vault haven't been deployed yet, this call will
    /// revert.
    
    
    
    
    
    function exitToVaultShares(
        address recipient,
        address vault,
        IxPYT xPYT,
        uint256 vaultSharesAmount
    ) external virtual nonReentrant returns (uint256 burnAmount) {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (vaultSharesAmount == 0) {
            return 0;
        }

        // only supported if vault shares are ERC20
        if (!vaultSharesIsERC20()) {
            revert Error_VaultSharesNotERC20();
        }

        /// -----------------------------------------------------------------------
        /// State updates & effects
        /// -----------------------------------------------------------------------

        // burn PYT and NYT
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        burnAmount = _vaultSharesAmountToUnderlyingAmountRoundingUp(
            vault,
            vaultSharesAmount,
            updatedPricePerVaultShare
        );
        _exit(vault, xPYT, burnAmount, updatedPricePerVaultShare);

        // transfer vault tokens to recipient
        ERC20(vault).safeTransfer(recipient, vaultSharesAmount);

        emit ExitToVaultShares(
            msg.sender,
            recipient,
            vault,
            xPYT,
            vaultSharesAmount
        );
    }

    
    
    /// revert.
    
    
    
    function claimYieldInUnderlying(address recipient, address vault)
        external
        virtual
        nonReentrant
        returns (uint256 yieldAmount)
    {
        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // update storage variables and compute yield amount
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        yieldAmount = _claimYield(vault, updatedPricePerVaultShare);

        // withdraw yield
        if (yieldAmount != 0) {
            /// -----------------------------------------------------------------------
            /// Effects
            /// -----------------------------------------------------------------------

            (uint8 fee, address protocolFeeRecipient) = factory
                .protocolFeeInfo();

            if (fee != 0) {
                uint256 protocolFee = (yieldAmount * fee) / 1000;
                unchecked {
                    // can't underflow since fee < 256
                    yieldAmount -= protocolFee;
                }

                if (vaultSharesIsERC20()) {
                    // vault shares are in ERC20
                    // do share transfer
                    protocolFee = _underlyingAmountToVaultSharesAmount(
                        vault,
                        protocolFee,
                        updatedPricePerVaultShare
                    );
                    uint256 vaultSharesBalance = ERC20(vault).balanceOf(
                        address(this)
                    );
                    if (protocolFee > vaultSharesBalance) {
                        protocolFee = vaultSharesBalance;
                    }
                    if (protocolFee != 0) {
                        ERC20(vault).safeTransfer(
                            protocolFeeRecipient,
                            protocolFee
                        );
                    }
                } else {
                    // vault shares are not in ERC20
                    // withdraw underlying from vault
                    // checkBalance is set to true to prevent getting stuck
                    // due to rounding errors
                    if (protocolFee != 0) {
                        _withdrawFromVault(
                            protocolFeeRecipient,
                            vault,
                            protocolFee,
                            updatedPricePerVaultShare,
                            true
                        );
                    }
                }
            }

            // withdraw underlying to recipient
            // checkBalance is set to true to prevent getting stuck
            // due to rounding errors
            yieldAmount = _withdrawFromVault(
                recipient,
                vault,
                yieldAmount,
                updatedPricePerVaultShare,
                true
            );

            emit ClaimYieldInUnderlying(
                msg.sender,
                recipient,
                vault,
                yieldAmount
            );
        }
    }

    
    
    /// If the NYT and PYT for the specified vault haven't been deployed yet, this call will
    /// revert.
    
    
    
    function claimYieldInVaultShares(address recipient, address vault)
        external
        virtual
        nonReentrant
        returns (uint256 yieldAmount)
    {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        // only supported if vault shares are ERC20
        if (!vaultSharesIsERC20()) {
            revert Error_VaultSharesNotERC20();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // update storage variables and compute yield amount
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        yieldAmount = _claimYield(vault, updatedPricePerVaultShare);

        // withdraw yield
        if (yieldAmount != 0) {
            /// -----------------------------------------------------------------------
            /// Effects
            /// -----------------------------------------------------------------------

            // convert yieldAmount to be denominated in vault shares
            yieldAmount = _underlyingAmountToVaultSharesAmount(
                vault,
                yieldAmount,
                updatedPricePerVaultShare
            );

            (uint8 fee, address protocolFeeRecipient) = factory
                .protocolFeeInfo();
            uint256 vaultSharesBalance = getVaultShareBalance(vault);
            if (fee != 0) {
                uint256 protocolFee = (yieldAmount * fee) / 1000;
                protocolFee = protocolFee > vaultSharesBalance
                    ? vaultSharesBalance
                    : protocolFee;
                unchecked {
                    // can't underflow since fee < 256
                    yieldAmount -= protocolFee;
                }

                if (protocolFee > 0) {
                    ERC20(vault).safeTransfer(
                        protocolFeeRecipient,
                        protocolFee
                    );

                    vaultSharesBalance -= protocolFee;
                }
            }

            // transfer vault shares to recipient
            // check if vault shares is enough to prevent getting stuck
            // from rounding errors
            yieldAmount = yieldAmount > vaultSharesBalance
                ? vaultSharesBalance
                : yieldAmount;
            if (yieldAmount > 0) {
                ERC20(vault).safeTransfer(recipient, yieldAmount);
            }

            emit ClaimYieldInVaultShares(
                msg.sender,
                recipient,
                vault,
                yieldAmount
            );
        }
    }

    
    /// use the yield to mint NYT and PYT.
    
    /// If the NYT and PYT for the specified vault haven't been deployed yet, this call will
    /// revert.
    
    
    
    
    
    function claimYieldAndEnter(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT
    ) external virtual nonReentrant returns (uint256 yieldAmount) {
        // update storage variables and compute yield amount
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        yieldAmount = _claimYield(vault, updatedPricePerVaultShare);

        // use yield to mint NYT and PYT
        if (yieldAmount != 0) {
            (uint8 fee, address protocolFeeRecipient) = factory
                .protocolFeeInfo();

            if (fee != 0) {
                uint256 protocolFee = (yieldAmount * fee) / 1000;
                unchecked {
                    // can't underflow since fee < 256
                    yieldAmount -= protocolFee;
                }

                if (vaultSharesIsERC20()) {
                    // vault shares are in ERC20
                    // do share transfer
                    protocolFee = _underlyingAmountToVaultSharesAmount(
                        vault,
                        protocolFee,
                        updatedPricePerVaultShare
                    );
                    uint256 vaultSharesBalance = ERC20(vault).balanceOf(
                        address(this)
                    );
                    if (protocolFee > vaultSharesBalance) {
                        protocolFee = vaultSharesBalance;
                    }
                    if (protocolFee != 0) {
                        ERC20(vault).safeTransfer(
                            protocolFeeRecipient,
                            protocolFee
                        );
                    }
                } else {
                    // vault shares are not in ERC20
                    // withdraw underlying from vault
                    // checkBalance is set to true to prevent getting stuck
                    // due to rounding errors
                    if (protocolFee != 0) {
                        _withdrawFromVault(
                            protocolFeeRecipient,
                            vault,
                            protocolFee,
                            updatedPricePerVaultShare,
                            true
                        );
                    }
                }
            }

            NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
            PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);

            if (address(xPYT) == address(0)) {
                // accrue yield to pytRecipient if they're not msg.sender
                // no need to do it if the recipient is msg.sender, since
                // we already accrued yield in _claimYield
                if (pytRecipient != msg.sender) {
                    _accrueYield(
                        vault,
                        pyt,
                        pytRecipient,
                        updatedPricePerVaultShare
                    );
                }
            } else {
                // accrue yield to xPYT contract since it gets minted PYT
                _accrueYield(
                    vault,
                    pyt,
                    address(xPYT),
                    updatedPricePerVaultShare
                );
            }

            // mint NYTs and PYTs
            nyt.gateMint(nytRecipient, yieldAmount);
            if (address(xPYT) == address(0)) {
                // mint raw PYT to recipient
                pyt.gateMint(pytRecipient, yieldAmount);
            } else {
                // mint PYT to xPYT contract
                pyt.gateMint(address(xPYT), yieldAmount);

                /// -----------------------------------------------------------------------
                /// Effects
                /// -----------------------------------------------------------------------

                // call sweep to mint xPYT using the PYT
                xPYT.sweep(pytRecipient);
            }

            emit ClaimYieldAndEnter(
                msg.sender,
                nytRecipient,
                pytRecipient,
                vault,
                xPYT,
                yieldAmount
            );
        }
    }

    /// -----------------------------------------------------------------------
    /// Getters
    /// -----------------------------------------------------------------------

    
    
    
    
    function getNegativeYieldTokenForVault(address vault)
        public
        view
        virtual
        returns (NegativeYieldToken)
    {
        return factory.getNegativeYieldToken(this, vault);
    }

    
    
    
    
    function getPerpetualYieldTokenForVault(address vault)
        public
        view
        virtual
        returns (PerpetualYieldToken)
    {
        return factory.getPerpetualYieldToken(this, vault);
    }

    
    /// Accounts for protocol fees.
    
    
    
    function getClaimableYieldAmount(address vault, address user)
        external
        view
        virtual
        returns (uint256 yieldAmount)
    {
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        uint256 userYieldPerTokenStored_ = userYieldPerTokenStored[vault][user];
        if (userYieldPerTokenStored_ == 0) {
            // uninitialized account
            return 0;
        }
        yieldAmount = _getClaimableYieldAmount(
            vault,
            user,
            _computeYieldPerToken(vault, pyt, getPricePerVaultShare(vault)),
            userYieldPerTokenStored_,
            pyt.balanceOf(user)
        );
        (uint8 fee, ) = factory.protocolFeeInfo();
        if (fee != 0) {
            uint256 protocolFee = (yieldAmount * fee) / 1000;
            unchecked {
                // can't underflow since fee < 256
                yieldAmount -= protocolFee;
            }
        }
    }

    
    
    
    function computeYieldPerToken(address vault)
        external
        view
        virtual
        returns (uint256)
    {
        return
            _computeYieldPerToken(
                vault,
                getPerpetualYieldTokenForVault(vault),
                getPricePerVaultShare(vault)
            );
    }

    
    
    
    function getUnderlyingOfVault(address vault)
        public
        view
        virtual
        returns (ERC20);

    
    
    
    function getPricePerVaultShare(address vault)
        public
        view
        virtual
        returns (uint256);

    
    
    
    function getVaultShareBalance(address vault)
        public
        view
        virtual
        returns (uint256);

    
    /// to represent shares, false otherwise.
    function vaultSharesIsERC20() public pure virtual returns (bool);

    
    
    
    function negativeYieldTokenName(address vault)
        external
        view
        virtual
        returns (string memory);

    
    
    
    function negativeYieldTokenSymbol(address vault)
        external
        view
        virtual
        returns (string memory);

    
    
    
    function perpetualYieldTokenName(address vault)
        external
        view
        virtual
        returns (string memory);

    
    
    
    function perpetualYieldTokenSymbol(address vault)
        external
        view
        virtual
        returns (string memory);

    /// -----------------------------------------------------------------------
    /// PYT transfer hook
    /// -----------------------------------------------------------------------

    
    
    /// accrue the yield earned by the from & to accounts
    
    
    
    
    function beforePerpetualYieldTokenTransfer(
        address from,
        address to,
        uint256 amount,
        uint256 fromBalance,
        uint256 toBalance
    ) external virtual {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (amount == 0) {
            return;
        }

        address vault = PerpetualYieldToken(msg.sender).vault();
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        if (msg.sender != address(pyt)) {
            revert Error_SenderNotPerpetualYieldToken();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // accrue yield
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);
        uint256 updatedYieldPerToken = _computeYieldPerToken(
            vault,
            pyt,
            updatedPricePerVaultShare
        );
        yieldPerTokenStored[vault] = updatedYieldPerToken;
        pricePerVaultShareStored[vault] = updatedPricePerVaultShare;

        // we know the from account must have held PYTs before
        // so we will always accrue the yield earned by the from account
        userAccruedYield[vault][from] =
            _getClaimableYieldAmount(
                vault,
                from,
                updatedYieldPerToken,
                userYieldPerTokenStored[vault][from],
                fromBalance
            ) +
            1;
        userYieldPerTokenStored[vault][from] = updatedYieldPerToken + 1;

        // the to account might not have held PYTs before
        // we only accrue yield if they have
        uint256 toUserYieldPerTokenStored = userYieldPerTokenStored[vault][to];
        if (toUserYieldPerTokenStored != 0) {
            // to account has held PYTs before
            userAccruedYield[vault][to] =
                _getClaimableYieldAmount(
                    vault,
                    to,
                    updatedYieldPerToken,
                    toUserYieldPerTokenStored,
                    toBalance
                ) +
                1;
        }
        userYieldPerTokenStored[vault][to] = updatedYieldPerToken + 1;
    }

    /// -----------------------------------------------------------------------
    /// Emergency exit
    /// -----------------------------------------------------------------------

    
    
    /// collateral. This is to prevent cases where a large portion of PYT/NYT is locked up in a buggy/malicious contract
    /// and locks up the underlying collateral forever.
    
    
    function ownerActivateEmergencyExitForVault(
        address vault,
        uint96 pytPriceInUnderlying
    ) external virtual onlyOwner {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        // we only allow emergency exit to be activated once (until deactivation)
        // because if pytPriceInUnderlying is ever modified after activation
        // then PYT/NYT will become unbacked
        if (emergencyExitStatusOfVault[vault].activated) {
            revert Error_EmergencyExitAlreadyActivated();
        }

        // we need to ensure the PYT price value is within the range [0, PRECISION]
        if (pytPriceInUnderlying > PRECISION) {
            revert Error_InvalidInput();
        }

        // the PYT & NYT must have already been deployed
        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        if (address(nyt).code.length == 0) {
            revert Error_TokenPairNotDeployed();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        emergencyExitStatusOfVault[vault] = EmergencyExitStatus({
            activated: true,
            pytPriceInUnderlying: pytPriceInUnderlying
        });
    }

    
    
    function ownerDeactivateEmergencyExitForVault(address vault)
        external
        virtual
        onlyOwner
    {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        // can only deactivate emergency exit when it's already activated
        if (!emergencyExitStatusOfVault[vault].activated) {
            revert Error_EmergencyExitNotActivated();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // reset the emergency exit status
        delete emergencyExitStatusOfVault[vault];
    }

    
    /// been activated for the vault.
    
    
    
    
    function emergencyExitNegativeYieldToken(
        address vault,
        uint256 amount,
        address recipient
    ) external virtual returns (uint256 underlyingAmount) {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        // ensure emergency exit is active
        EmergencyExitStatus memory status = emergencyExitStatusOfVault[vault];
        if (!status.activated) {
            revert Error_EmergencyExitNotActivated();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);

        // accrue yield
        _accrueYield(vault, pyt, msg.sender, updatedPricePerVaultShare);

        // burn NYT from the sender
        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        nyt.gateBurn(msg.sender, amount);

        /// -----------------------------------------------------------------------
        /// Effects
        /// -----------------------------------------------------------------------

        // compute how much of the underlying assets to give the recipient
        // rounds down
        underlyingAmount = FullMath.mulDiv(
            amount,
            PRECISION - status.pytPriceInUnderlying,
            PRECISION
        );

        // withdraw underlying from vault to recipient
        // don't check balance since user can just withdraw slightly less
        // saves gas this way
        underlyingAmount = _withdrawFromVault(
            recipient,
            vault,
            underlyingAmount,
            updatedPricePerVaultShare,
            false
        );
    }

    
    /// been activated for the vault.
    
    
    
    
    
    function emergencyExitPerpetualYieldToken(
        address vault,
        IxPYT xPYT,
        uint256 amount,
        address recipient
    ) external virtual returns (uint256 underlyingAmount) {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        // ensure emergency exit is active
        EmergencyExitStatus memory status = emergencyExitStatusOfVault[vault];
        if (!status.activated) {
            revert Error_EmergencyExitNotActivated();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        uint256 updatedPricePerVaultShare = getPricePerVaultShare(vault);

        // accrue yield
        _accrueYield(vault, pyt, msg.sender, updatedPricePerVaultShare);

        if (address(xPYT) == address(0)) {
            // burn raw PYT from sender
            pyt.gateBurn(msg.sender, amount);
        } else {
            /// -----------------------------------------------------------------------
            /// Effects
            /// -----------------------------------------------------------------------

            // convert xPYT to PYT then burn
            xPYT.withdraw(amount, address(this), msg.sender);
            pyt.gateBurn(address(this), amount);
        }

        /// -----------------------------------------------------------------------
        /// Effects
        /// -----------------------------------------------------------------------

        // compute how much of the underlying assets to give the recipient
        // rounds down
        underlyingAmount = FullMath.mulDiv(
            amount,
            status.pytPriceInUnderlying,
            PRECISION
        );

        // withdraw underlying from vault to recipient
        // don't check balance since user can just withdraw slightly less
        // saves gas this way
        underlyingAmount = _withdrawFromVault(
            recipient,
            vault,
            underlyingAmount,
            updatedPricePerVaultShare,
            false
        );
    }

    /// -----------------------------------------------------------------------
    /// Internal utilities
    /// -----------------------------------------------------------------------

    
    function _accrueYield(
        address vault,
        PerpetualYieldToken pyt,
        address user,
        uint256 updatedPricePerVaultShare
    ) internal virtual {
        uint256 updatedYieldPerToken = _computeYieldPerToken(
            vault,
            pyt,
            updatedPricePerVaultShare
        );
        uint256 userYieldPerTokenStored_ = userYieldPerTokenStored[vault][user];
        if (userYieldPerTokenStored_ != 0) {
            userAccruedYield[vault][user] =
                _getClaimableYieldAmount(
                    vault,
                    user,
                    updatedYieldPerToken,
                    userYieldPerTokenStored_,
                    pyt.balanceOf(user)
                ) +
                1;
        }
        yieldPerTokenStored[vault] = updatedYieldPerToken;
        pricePerVaultShareStored[vault] = updatedPricePerVaultShare;
        userYieldPerTokenStored[vault][user] = updatedYieldPerToken + 1;
    }

    
    function _enter(
        address nytRecipient,
        address pytRecipient,
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount,
        uint256 updatedPricePerVaultShare
    ) internal virtual {
        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        if (address(nyt).code.length == 0) {
            // token pair hasn't been deployed yet
            // do the deployment now
            // only need to check nyt since nyt and pyt are always deployed in pairs
            factory.deployYieldTokenPair(this, vault);
        }
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // accrue yield
        _accrueYield(
            vault,
            pyt,
            address(xPYT) == address(0) ? pytRecipient : address(xPYT),
            updatedPricePerVaultShare
        );

        // mint NYTs and PYTs
        nyt.gateMint(nytRecipient, underlyingAmount);
        if (address(xPYT) == address(0)) {
            // mint raw PYT to recipient
            pyt.gateMint(pytRecipient, underlyingAmount);
        } else {
            // mint PYT to xPYT contract
            pyt.gateMint(address(xPYT), underlyingAmount);

            /// -----------------------------------------------------------------------
            /// Effects
            /// -----------------------------------------------------------------------

            // call sweep to mint xPYT using the PYT
            xPYT.sweep(pytRecipient);
        }
    }

    
    function _exit(
        address vault,
        IxPYT xPYT,
        uint256 underlyingAmount,
        uint256 updatedPricePerVaultShare
    ) internal virtual {
        NegativeYieldToken nyt = getNegativeYieldTokenForVault(vault);
        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        if (address(nyt).code.length == 0) {
            revert Error_TokenPairNotDeployed();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // accrue yield
        _accrueYield(
            vault,
            pyt,
            address(xPYT) == address(0) ? msg.sender : address(this),
            updatedPricePerVaultShare
        );

        // burn NYTs and PYTs
        nyt.gateBurn(msg.sender, underlyingAmount);
        if (address(xPYT) == address(0)) {
            // burn raw PYT from sender
            pyt.gateBurn(msg.sender, underlyingAmount);
        } else {
            /// -----------------------------------------------------------------------
            /// Effects
            /// -----------------------------------------------------------------------

            // convert xPYT to PYT then burn
            xPYT.withdraw(underlyingAmount, address(this), msg.sender);
            pyt.gateBurn(address(this), underlyingAmount);
        }
    }

    
    function _claimYield(address vault, uint256 updatedPricePerVaultShare)
        internal
        virtual
        returns (uint256 yieldAmount)
    {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        PerpetualYieldToken pyt = getPerpetualYieldTokenForVault(vault);
        if (address(pyt).code.length == 0) {
            revert Error_TokenPairNotDeployed();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // accrue yield
        uint256 updatedYieldPerToken = _computeYieldPerToken(
            vault,
            pyt,
            updatedPricePerVaultShare
        );
        uint256 userYieldPerTokenStored_ = userYieldPerTokenStored[vault][
            msg.sender
        ];
        if (userYieldPerTokenStored_ != 0) {
            yieldAmount = _getClaimableYieldAmount(
                vault,
                msg.sender,
                updatedYieldPerToken,
                userYieldPerTokenStored_,
                pyt.balanceOf(msg.sender)
            );
        }
        yieldPerTokenStored[vault] = updatedYieldPerToken;
        pricePerVaultShareStored[vault] = updatedPricePerVaultShare;
        userYieldPerTokenStored[vault][msg.sender] = updatedYieldPerToken + 1;
        if (yieldAmount != 0) {
            userAccruedYield[vault][msg.sender] = 1;
        }
    }

    
    /// Assumes userYieldPerTokenStored_ != 0. Does not account for protocol fees.
    function _getClaimableYieldAmount(
        address vault,
        address user,
        uint256 updatedYieldPerToken,
        uint256 userYieldPerTokenStored_,
        uint256 userPYTBalance
    ) internal view virtual returns (uint256 yieldAmount) {
        unchecked {
            // the stored value is shifted by one
            uint256 actualUserYieldPerToken = userYieldPerTokenStored_ - 1;

            // updatedYieldPerToken - actualUserYieldPerToken won't underflow since we check updatedYieldPerToken > actualUserYieldPerToken
            yieldAmount = FullMath.mulDiv(
                userPYTBalance,
                updatedYieldPerToken > actualUserYieldPerToken
                    ? updatedYieldPerToken - actualUserYieldPerToken
                    : 0,
                PRECISION
            );

            uint256 accruedYield = userAccruedYield[vault][user];
            if (accruedYield > 1) {
                // won't overflow since the sum is at most the totalSupply of the vault's underlying, which
                // is at most 256 bits.
                // the stored accruedYield value is shifted by one
                yieldAmount += accruedYield - 1;
            }
        }
    }

    
    
    
    
    function _depositIntoVault(
        ERC20 underlying,
        uint256 underlyingAmount,
        address vault
    ) internal virtual;

    
    
    
    
    
    
    /// to withdraw more than the balance (due to rounding errors)
    
    function _withdrawFromVault(
        address recipient,
        address vault,
        uint256 underlyingAmount,
        uint256 pricePerVaultShare,
        bool checkBalance
    ) internal virtual returns (uint256 withdrawnUnderlyingAmount);

    
    function _vaultSharesAmountToUnderlyingAmount(
        address vault,
        uint256 vaultSharesAmount,
        uint256 pricePerVaultShare
    ) internal view virtual returns (uint256);

    
    function _vaultSharesAmountToUnderlyingAmountRoundingUp(
        address vault,
        uint256 vaultSharesAmount,
        uint256 pricePerVaultShare
    ) internal view virtual returns (uint256);

    
    function _underlyingAmountToVaultSharesAmount(
        address vault,
        uint256 underlyingAmount,
        uint256 pricePerVaultShare
    ) internal view virtual returns (uint256);

    
    function _computeYieldPerToken(
        address vault,
        PerpetualYieldToken pyt,
        uint256 updatedPricePerVaultShare
    ) internal view virtual returns (uint256) {
        uint256 pytTotalSupply = pyt.totalSupply();
        if (pytTotalSupply == 0) {
            return yieldPerTokenStored[vault];
        }
        uint256 pricePerVaultShareStored_ = pricePerVaultShareStored[vault];
        if (updatedPricePerVaultShare <= pricePerVaultShareStored_) {
            // rounding error in vault share or no yield accrued
            return yieldPerTokenStored[vault];
        }
        uint256 newYieldPerTokenAccrued;
        unchecked {
            // can't underflow since we know updatedPricePerVaultShare > pricePerVaultShareStored_
            newYieldPerTokenAccrued = FullMath.mulDiv(
                updatedPricePerVaultShare - pricePerVaultShareStored_,
                getVaultShareBalance(vault),
                pytTotalSupply
            );
        }
        return yieldPerTokenStored[vault] + newYieldPerTokenAccrued;
    }
}



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



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}



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



interface IUniswapV3SwapCallback {
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}




/// swapping via an external DEX and minting/burning xPYT/NYT.

/// which enables swapping any supported token into any xPYT/NYT. Two-hop swaps are done by chaining
/// two calls together via Multicall and setting the recipient of the first swap to the Swapper.
abstract contract Swapper is
    Multicall,
    SelfPermit,
    ReentrancyGuard,
    BoringOwnable
{
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using SafeTransferLib for ERC20;

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error Error_SameToken();
    error Error_PastDeadline();
    error Error_ZeroExSwapFailed();
    error Error_InsufficientOutput();
    error Error_ProtocolFeeRecipientIsZero();

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event SetProtocolFee(ProtocolFeeInfo protocolFeeInfo_);

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    
    
    
    
    
    
    
    
    
    
    /// case `tokenAmountIn` will be overriden to the balance.
    
    /// when swapping from the underlying to NYT.
    
    
    struct SwapArgs {
        Gate gate;
        address vault;
        ERC20 underlying;
        ERC20 nyt;
        ERC20 pyt;
        IxPYT xPYT;
        uint256 tokenAmountIn;
        uint256 minAmountOut;
        address recipient;
        bool useSwapperBalance;
        bool usePYT;
        uint256 deadline;
        bytes extraArgs;
    }

    
    
    struct ProtocolFeeInfo {
        uint8 fee;
        address recipient;
    }

    /// -----------------------------------------------------------------------
    /// Immutable parameters
    /// -----------------------------------------------------------------------

    
    address public immutable zeroExProxy;

    
    WETH public immutable weth;

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    
    ProtocolFeeInfo public protocolFeeInfo;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        address zeroExProxy_,
        WETH weth_,
        ProtocolFeeInfo memory protocolFeeInfo_
    ) {
        zeroExProxy = zeroExProxy_;
        weth = weth_;

        if (
            protocolFeeInfo_.fee != 0 &&
            protocolFeeInfo_.recipient == address(0)
        ) {
            revert Error_ProtocolFeeRecipientIsZero();
        }
        protocolFeeInfo = protocolFeeInfo_;
        emit SetProtocolFee(protocolFeeInfo_);
    }

    /// -----------------------------------------------------------------------
    /// Swaps
    /// -----------------------------------------------------------------------

    
    
    
    function swapUnderlyingToNyt(SwapArgs calldata args)
        external
        payable
        virtual
        returns (uint256 tokenAmountOut);

    
    
    
    function swapUnderlyingToXpyt(SwapArgs calldata args)
        external
        payable
        virtual
        returns (uint256 tokenAmountOut);

    
    
    
    function swapNytToUnderlying(SwapArgs calldata args)
        external
        payable
        virtual
        returns (uint256 tokenAmountOut);

    
    
    
    function swapXpytToUnderlying(SwapArgs calldata args)
        external
        payable
        virtual
        returns (uint256 tokenAmountOut);

    /// -----------------------------------------------------------------------
    /// 0x support
    /// -----------------------------------------------------------------------

    
    
    
    
    
    
    
    
    
    
    
    /// the https://api.0x.org/swap/v1/quote endpoint
    
    function doZeroExSwap(
        ERC20 tokenIn,
        uint256 tokenAmountIn,
        ERC20 tokenOut,
        uint256 minAmountOut,
        address recipient,
        bool useSwapperBalance,
        bool requireApproval,
        uint256 deadline,
        bytes calldata swapData
    ) external payable virtual nonReentrant returns (uint256 tokenAmountOut) {
        // check if input token equals output
        if (tokenIn == tokenOut) {
            revert Error_SameToken();
        }

        // check deadline
        if (block.timestamp > deadline) {
            revert Error_PastDeadline();
        }

        // transfer in input tokens
        if (!useSwapperBalance) {
            tokenIn.safeTransferFrom(msg.sender, address(this), tokenAmountIn);
        }

        // approve zeroExProxy
        if (requireApproval) {
            tokenIn.safeApprove(zeroExProxy, type(uint256).max);
        }

        // do swap via zeroExProxy
        (bool success, ) = zeroExProxy.call(swapData);
        if (!success) {
            revert Error_ZeroExSwapFailed();
        }

        // check slippage
        tokenAmountOut = tokenOut.balanceOf(address(this));
        if (tokenAmountOut < minAmountOut) {
            revert Error_InsufficientOutput();
        }

        // transfer output tokens to recipient
        if (recipient != address(this)) {
            tokenOut.safeTransfer(recipient, tokenAmountOut);
        }
    }

    /// -----------------------------------------------------------------------
    /// WETH support
    /// -----------------------------------------------------------------------

    
    
    /// so that it can be swapped into xPYT/NYT.
    function wrapEthInput() external payable {
        weth.deposit{value: msg.value}();
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    
    /// Only callable by the owner.
    
    function ownerSetProtocolFee(ProtocolFeeInfo calldata protocolFeeInfo_)
        external
        virtual
        onlyOwner
    {
        if (
            protocolFeeInfo_.fee != 0 &&
            protocolFeeInfo_.recipient == address(0)
        ) {
            revert Error_ProtocolFeeRecipientIsZero();
        }
        protocolFeeInfo = protocolFeeInfo_;

        emit SetProtocolFee(protocolFeeInfo_);
    }
}


library PoolAddress {
    using Bytes32AddressLib for bytes32;

    bytes32 internal constant POOL_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key)
        internal
        pure
        returns (address pool)
    {
        require(key.token0 < key.token1);
        pool = keccak256(
            abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encode(key.token0, key.token1, key.fee)),
                POOL_INIT_CODE_HASH
            )
        ).fromLast20Bytes();
    }
}




contract UniswapV3Swapper is Swapper, IUniswapV3SwapCallback {
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using SafeCast for uint256;
    using SafeTransferLib for ERC20;
    using SafeTransferLib for IxPYT;

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error Error_NotUniswapV3Pool();
    error Error_BothTokenDeltasAreZero();

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    struct SwapCallbackData {
        ERC20 tokenIn;
        ERC20 tokenOut;
        uint24 fee;
    }

    /// -----------------------------------------------------------------------
    /// Constants
    /// -----------------------------------------------------------------------

    
    /// Copied from v3-core/libraries/TickMath.sol
    uint160 internal constant MIN_SQRT_RATIO_PLUS_ONE = 4295128740;

    
    /// Copied from v3-core/libraries/TickMath.sol
    uint160 internal constant MAX_SQRT_RATIO_MINUS_ONE =
        1461446703485210103287273052203988822378723970341;

    /// -----------------------------------------------------------------------
    /// Immutable parameters
    /// -----------------------------------------------------------------------

    
    address public immutable uniswapV3Factory;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        address zeroExProxy_,
        WETH weth_,
        ProtocolFeeInfo memory protocolFeeInfo_,
        address uniswapV3Factory_
    ) Swapper(zeroExProxy_, weth_, protocolFeeInfo_) {
        uniswapV3Factory = uniswapV3Factory_;
    }

    /// -----------------------------------------------------------------------
    /// Swaps
    /// -----------------------------------------------------------------------

    
    
    /// fee: The fee tier of the Uniswap V3 pool to use
    function swapUnderlyingToNyt(SwapArgs calldata args)
        external
        payable
        virtual
        override
        nonReentrant
        returns (uint256 tokenAmountOut)
    {
        // check deadline
        if (block.timestamp > args.deadline) {
            revert Error_PastDeadline();
        }

        uint256 xPYTMinted;
        {
            // determine token input amount
            uint256 tokenAmountIn = args.useSwapperBalance
                ? args.underlying.balanceOf(address(this))
                : args.tokenAmountIn;

            // transfer underlying from sender
            if (!args.useSwapperBalance) {
                args.underlying.safeTransferFrom(
                    msg.sender,
                    address(this),
                    tokenAmountIn
                );
            }

            // take protocol fee
            ProtocolFeeInfo memory protocolFeeInfo_ = protocolFeeInfo;
            if (protocolFeeInfo_.fee > 0) {
                uint256 feeAmount = (tokenAmountIn * protocolFeeInfo_.fee) /
                    10000;
                if (feeAmount > 0) {
                    // deduct fee from token input
                    tokenAmountIn -= feeAmount;

                    // transfer fee to recipient
                    args.underlying.safeTransfer(
                        protocolFeeInfo_.recipient,
                        feeAmount
                    );
                }
            }

            // add token output from minting to result
            tokenAmountOut = tokenAmountIn;

            // use underlying to mint xPYT & NYT
            xPYTMinted = args.xPYT.previewDeposit(tokenAmountIn);
            if (
                args.underlying.allowance(address(this), address(args.gate)) <
                tokenAmountIn
            ) {
                args.underlying.safeApprove(
                    address(args.gate),
                    type(uint256).max
                );
            }
            args.gate.enterWithUnderlying(
                args.recipient, // nytRecipient
                address(this), // pytRecipient
                args.vault,
                args.xPYT,
                tokenAmountIn
            );
        }

        // swap xPYT to NYT
        {
            uint24 fee = abi.decode(args.extraArgs, (uint24));
            // swap and add swap output to result
            tokenAmountOut += _swap(
                args.xPYT,
                xPYTMinted,
                args.nyt,
                fee,
                args.recipient
            );
        }

        // check slippage
        if (tokenAmountOut < args.minAmountOut) {
            revert Error_InsufficientOutput();
        }
    }

    
    
    /// fee: The fee tier of the Uniswap V3 pool to use
    function swapUnderlyingToXpyt(SwapArgs calldata args)
        external
        payable
        virtual
        override
        nonReentrant
        returns (uint256 tokenAmountOut)
    {
        // check deadline
        if (block.timestamp > args.deadline) {
            revert Error_PastDeadline();
        }

        uint256 tokenAmountIn;
        {
            // determine token input and output amounts
            tokenAmountIn = args.useSwapperBalance
                ? args.underlying.balanceOf(address(this))
                : args.tokenAmountIn;

            // transfer underlying from sender
            if (!args.useSwapperBalance) {
                args.underlying.safeTransferFrom(
                    msg.sender,
                    address(this),
                    tokenAmountIn
                );
            }

            // take protocol fee
            ProtocolFeeInfo memory protocolFeeInfo_ = protocolFeeInfo;
            if (protocolFeeInfo_.fee > 0) {
                uint256 feeAmount = (tokenAmountIn * protocolFeeInfo_.fee) /
                    10000;
                if (feeAmount > 0) {
                    // deduct fee from token input
                    tokenAmountIn -= feeAmount;

                    // transfer fee to recipient
                    args.underlying.safeTransfer(
                        protocolFeeInfo_.recipient,
                        feeAmount
                    );
                }
            }

            // add token output from minting to result
            tokenAmountOut = args.usePYT
                ? tokenAmountIn
                : args.xPYT.previewDeposit(tokenAmountIn);

            // use underlying to mint xPYT & NYT
            if (
                args.underlying.allowance(address(this), address(args.gate)) <
                tokenAmountIn
            ) {
                args.underlying.safeApprove(
                    address(args.gate),
                    type(uint256).max
                );
            }
            args.gate.enterWithUnderlying(
                address(this), // nytRecipient
                args.recipient, // pytRecipient
                args.vault,
                args.usePYT ? IxPYT(address(0)) : args.xPYT,
                tokenAmountIn
            );
        }

        // swap NYT to xPYT
        uint256 swapOutput;
        {
            uint24 fee = abi.decode(args.extraArgs, (uint24));
            swapOutput = _swap(
                args.nyt,
                tokenAmountIn,
                args.xPYT,
                fee,
                args.usePYT ? address(this) : args.recipient // set recipient to this when using PYT in order to unwrap xPYT
            );
        }

        // unwrap xPYT if necessary
        if (args.usePYT) {
            tokenAmountOut += args.xPYT.redeem(
                swapOutput,
                args.recipient,
                address(this)
            );
        } else {
            tokenAmountOut += swapOutput;
        }

        // check slippage
        if (tokenAmountOut < args.minAmountOut) {
            revert Error_InsufficientOutput();
        }
    }

    
    
    /// fee: The fee tier of the Uniswap V3 pool to use
    /// swapAmountIn: The amount of NYT to swap to xPYT
    function swapNytToUnderlying(SwapArgs calldata args)
        external
        payable
        virtual
        override
        nonReentrant
        returns (uint256 tokenAmountOut)
    {
        // check deadline
        if (block.timestamp > args.deadline) {
            revert Error_PastDeadline();
        }

        // transfer token input from sender
        uint256 tokenAmountIn = args.tokenAmountIn;
        if (!args.useSwapperBalance) {
            args.nyt.safeTransferFrom(msg.sender, address(this), tokenAmountIn);
        }

        // take protocol fee
        ProtocolFeeInfo memory protocolFeeInfo_ = protocolFeeInfo;
        if (protocolFeeInfo_.fee > 0) {
            uint256 feeAmount = (tokenAmountIn * protocolFeeInfo_.fee) / 10000;
            if (feeAmount > 0) {
                // deduct fee from token input
                tokenAmountIn -= feeAmount;

                // transfer fee to recipient
                args.nyt.safeTransfer(protocolFeeInfo_.recipient, feeAmount);
            }
        }

        // swap NYT to xPYT
        uint256 swapAmountOut;
        uint256 swapAmountIn;
        {
            uint24 fee;
            (fee, swapAmountIn) = abi.decode(args.extraArgs, (uint24, uint256));
            swapAmountOut = _swap(
                args.nyt,
                swapAmountIn,
                args.xPYT,
                fee,
                address(this)
            );

            // convert swap output xPYT amount into equivalent PYT amount
            swapAmountOut = args.xPYT.convertToAssets(swapAmountOut);
        }

        // determine token output amount
        uint256 remainingAmountIn = args.useSwapperBalance
            ? args.nyt.balanceOf(address(this))
            : tokenAmountIn - swapAmountIn;
        if (remainingAmountIn < swapAmountOut) {
            // NYT to burn < PYT balance
            tokenAmountOut = remainingAmountIn;
        } else {
            // NYT balance >= PYT to burn
            tokenAmountOut = swapAmountOut;
        }

        // check slippage
        if (tokenAmountOut < args.minAmountOut) {
            revert Error_InsufficientOutput();
        }

        // burn xPYT & NYT into underlying
        if (
            args.xPYT.allowance(address(this), address(args.gate)) <
            args.xPYT.previewWithdraw(tokenAmountOut)
        ) {
            args.xPYT.safeApprove(address(args.gate), type(uint256).max);
        }
        args.gate.exitToUnderlying(
            args.recipient,
            args.vault,
            args.xPYT,
            tokenAmountOut
        );

        // handle leftover tokens
        if (remainingAmountIn < swapAmountOut) {
            // NYT to burn < PYT balance
            // give leftover xPYT to recipient
            if (args.usePYT) {
                uint256 maxRedeemAmount = args.xPYT.maxRedeem(address(this));
                if (maxRedeemAmount != 0) {
                    args.xPYT.redeem(
                        args.xPYT.maxRedeem(address(this)),
                        args.recipient,
                        address(this)
                    );
                }
            } else {
                args.xPYT.safeTransfer(
                    args.recipient,
                    args.xPYT.balanceOf(address(this))
                );
            }
        } else {
            // NYT balance >= PYT to burn
            // give leftover NYT to recipient
            args.nyt.safeTransfer(
                args.recipient,
                args.nyt.balanceOf(address(this))
            );
        }
    }

    
    
    /// fee: The fee tier of the Uniswap V3 pool to use
    /// swapAmountIn: The amount of xPYT to swap to NYT
    function swapXpytToUnderlying(SwapArgs calldata args)
        external
        payable
        virtual
        override
        nonReentrant
        returns (uint256 tokenAmountOut)
    {
        // check deadline
        if (block.timestamp > args.deadline) {
            revert Error_PastDeadline();
        }

        // transfer token input from sender
        uint256 tokenAmountIn = args.tokenAmountIn;
        if (!args.useSwapperBalance) {
            if (args.usePYT) {
                // transfer PYT from sender to this
                args.pyt.safeTransferFrom(
                    msg.sender,
                    address(this),
                    tokenAmountIn
                );

                // convert PYT input into xPYT and update tokenAmountIn
                if (
                    args.pyt.allowance(address(this), address(args.xPYT)) <
                    tokenAmountIn
                ) {
                    args.pyt.approve(address(args.xPYT), type(uint256).max);
                }
                tokenAmountIn = args.xPYT.deposit(tokenAmountIn, address(this));
            } else {
                args.xPYT.safeTransferFrom(
                    msg.sender,
                    address(this),
                    tokenAmountIn
                );
            }
        }

        // take protocol fee
        ProtocolFeeInfo memory protocolFeeInfo_ = protocolFeeInfo;
        if (protocolFeeInfo_.fee > 0) {
            uint256 feeAmount = (tokenAmountIn * protocolFeeInfo_.fee) / 10000;
            if (feeAmount > 0) {
                // deduct fee from token input
                tokenAmountIn -= feeAmount;

                // transfer fee to recipient
                args.xPYT.safeTransfer(protocolFeeInfo_.recipient, feeAmount);
            }
        }

        // swap xPYT to NYT
        uint256 swapAmountOut;
        uint256 swapAmountIn;
        {
            uint24 fee;
            (fee, swapAmountIn) = abi.decode(args.extraArgs, (uint24, uint256));
            swapAmountOut = _swap(
                args.xPYT,
                swapAmountIn,
                args.nyt,
                fee,
                address(this)
            );
        }

        // determine token output amount
        uint256 remainingAmountIn = args.useSwapperBalance
            ? args.xPYT.balanceOf(address(this))
            : tokenAmountIn - swapAmountIn;
        // convert remainingAmountIn from xPYT amount to equivalent PYT amount
        remainingAmountIn = args.xPYT.previewRedeem(remainingAmountIn);
        if (remainingAmountIn < swapAmountOut) {
            // PYT to burn < NYT balance
            tokenAmountOut = remainingAmountIn;
        } else {
            // PYT balance >= NYT to burn
            tokenAmountOut = swapAmountOut;
        }

        // check slippage
        if (tokenAmountOut < args.minAmountOut) {
            revert Error_InsufficientOutput();
        }

        // burn xPYT & NYT into underlying
        if (
            args.xPYT.allowance(address(this), address(args.gate)) <
            args.xPYT.previewWithdraw(tokenAmountOut)
        ) {
            args.xPYT.safeApprove(address(args.gate), type(uint256).max);
        }
        args.gate.exitToUnderlying(
            args.recipient,
            args.vault,
            args.xPYT,
            tokenAmountOut
        );

        // handle leftover tokens
        if (remainingAmountIn < swapAmountOut) {
            // PYT to burn < NYT balance
            // give leftover NYT to recipient
            args.nyt.safeTransfer(
                args.recipient,
                args.nyt.balanceOf(address(this))
            );
        } else {
            // PYT balance >= NYT to burn
            // give leftover xPYT to recipient
            if (args.usePYT) {
                uint256 maxRedeemAmount = args.xPYT.maxRedeem(address(this));
                if (maxRedeemAmount != 0) {
                    args.xPYT.redeem(
                        args.xPYT.maxRedeem(address(this)),
                        args.recipient,
                        address(this)
                    );
                }
            } else {
                args.xPYT.safeTransfer(
                    args.recipient,
                    args.xPYT.balanceOf(address(this))
                );
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// Uniswap V3 support
    /// -----------------------------------------------------------------------

    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        // determine amount to pay
        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else if (amount1Delta > 0) {
            amountToPay = uint256(amount1Delta);
        } else {
            revert Error_BothTokenDeltasAreZero();
        }

        // decode callback data
        SwapCallbackData memory callbackData = abi.decode(
            data,
            (SwapCallbackData)
        );

        // verify sender
        address pool = PoolAddress.computeAddress(
            uniswapV3Factory,
            PoolAddress.getPoolKey(
                address(callbackData.tokenIn),
                address(callbackData.tokenOut),
                callbackData.fee
            )
        );
        if (msg.sender != address(pool)) {
            revert Error_NotUniswapV3Pool();
        }

        // pay tokens to the Uniswap V3 pool
        callbackData.tokenIn.safeTransfer(msg.sender, amountToPay);
    }

    /// -----------------------------------------------------------------------
    /// Internal utilities
    /// -----------------------------------------------------------------------

    
    
    
    
    
    
    function _swap(
        ERC20 tokenIn,
        uint256 tokenAmountIn,
        ERC20 tokenOut,
        uint24 fee,
        address recipient
    ) internal returns (uint256) {
        // get uniswap v3 pool
        IUniswapV3Pool uniPool = IUniswapV3Pool(
            PoolAddress.computeAddress(
                uniswapV3Factory,
                PoolAddress.getPoolKey(address(tokenIn), address(tokenOut), fee)
            )
        );

        // do swap
        bytes memory swapCallbackData = abi.encode(
            SwapCallbackData({tokenIn: tokenIn, tokenOut: tokenOut, fee: fee})
        );
        bool zeroForOne = address(tokenIn) < address(tokenOut);
        (int256 amount0, int256 amount1) = uniPool.swap(
            recipient,
            zeroForOne,
            tokenAmountIn.toInt256(),
            zeroForOne ? MIN_SQRT_RATIO_PLUS_ONE : MAX_SQRT_RATIO_MINUS_ONE,
            swapCallbackData
        );

        return uint256(-(zeroForOne ? amount1 : amount0));
    }
}