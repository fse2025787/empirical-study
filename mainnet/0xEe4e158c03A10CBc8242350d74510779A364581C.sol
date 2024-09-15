// SPDX-License-Identifier: Apache-2.0


// 
pragma solidity ^0.8.0;

interface IERC20 {
    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    // Note this is non standard but nearly all ERC20 have exposed decimal functions
    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Forked from openzepplin
// 

pragma solidity ^0.8.0;



/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit is IERC20 {
    /**
     * @dev Sets `value` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for `permit`, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// 
pragma solidity >=0.7.0;

contract Authorizable {
    // This contract allows a flexible authorization scheme

    // The owner who can change authorization status
    address public owner;
    // A mapping from an address to its authorization status
    mapping(address => bool) public authorized;

    
    constructor() {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not owner");
        _;
    }

    
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    
    
    
    function isAuthorized(address who) public view returns (bool) {
        return authorized[who];
    }

    
    
    function authorize(address who) external onlyOwner() {
        _authorize(who);
    }

    
    
    function deauthorize(address who) external onlyOwner() {
        authorized[who] = false;
    }

    
    
    function setOwner(address who) public onlyOwner() {
        owner = who;
    }

    
    
    function _authorize(address who) internal {
        authorized[who] = true;
    }
}
// 
pragma solidity ^0.8.0;










contract UserProxy is Authorizable {
    // This contract is a convenience library to consolidate
    // the actions needed to create interest or principal tokens to one call.
    // It will hold user allowances, and can be disabled by authorized addresses
    // for security.
    // If frozen users still control their own tokens so can manually redeem them.

    // Store the accessibility state of the contract
    bool public isFrozen = false;
    // Constant wrapped ether address
    IWETH public immutable weth;
    // Tranche factory address for Tranche contract address derivation
    address internal immutable _trancheFactory;
    // Tranche bytecode hash for Tranche contract address derivation.
    // This is constant as long as Tranche does not implement non-constant constructor arguments.
    bytes32 internal immutable _trancheBytecodeHash;
    // A constant which represents ether
    address internal constant _ETH_CONSTANT = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );

    
    ///      as the owner in authorization library
    
    
    
    constructor(
        IWETH _weth,
        address __trancheFactory,
        bytes32 __trancheBytecodeHash
    ) Authorizable() {
        _authorize(msg.sender);
        weth = _weth;
        _trancheFactory = __trancheFactory;
        _trancheBytecodeHash = __trancheBytecodeHash;
    }

    
    modifier notFrozen() {
        require(!isFrozen, "Contract frozen");
        _;
    }

    
    
    function setIsFrozen(bool _newState) external onlyAuthorized() {
        isFrozen = _newState;
    }

    // Memory encoding of the permit data
    struct PermitData {
        IERC20Permit tokenContract;
        address who;
        uint256 amount;
        uint256 expiration;
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    
    
    modifier preApproval(PermitData[] memory data) {
        // If permit calls are provided we make try to make them
        if (data.length != 0) {
            // We make permit calls for each indicated call
            for (uint256 i = 0; i < data.length; i++) {
                _permitCall(data[i]);
            }
        }
        _;
    }

    
    
    function _permitCall(PermitData memory data) internal {
        // Make the permit call to the token in the data field using
        // the fields provided.
        // Security note - This fairly open call is safe because it cannot
        // call 'transferFrom' or other sensitive methods despite the open
        // scope. Do not make more general without security review.
        data.tokenContract.permit(
            msg.sender,
            data.who,
            data.amount,
            data.expiration,
            data.v,
            data.r,
            data.s
        );
    }

    
    ///      then returns the tokens to the caller.
    
    
    
    ///                   or (2) the _ETH_CONSTANT to indicate the user has sent eth.
    ///                   This token should revert in the event of a transfer failure.
    
    
    
    ///                        the data should be encoded with abi.encode(data, "PermitData[]")
    ///                        each PermitData struct provided will be executed as a call.
    ///                        An example use of this is if using a token with permit like USDC
    ///                        to encode a permit which gives this contract allowance before minting.
    
    // NOTE - It is critical that the notFrozen modifier is listed first so it gets called first.
    function mint(
        uint256 _amount,
        IERC20 _underlying,
        uint256 _expiration,
        address _position,
        PermitData[] calldata _permitCallData
    )
        external
        payable
        notFrozen()
        preApproval(_permitCallData)
        returns (uint256, uint256)
    {
        // If the underlying token matches this predefined 'ETH token'
        // then we create weth for the user and go from there
        if (address(_underlying) == _ETH_CONSTANT) {
            // Check that the amount matches the amount provided
            require(msg.value == _amount, "Incorrect amount provided");
            // Create weth from the provided eth
            weth.deposit{ value: msg.value }();
            weth.transfer(address(_position), _amount);
        } else {
            // Check for the fact that this branch should not be payable
            require(msg.value == 0, "Non payable");
            // Move the user's funds to the wrapped position contract
            _underlying.transferFrom(msg.sender, address(_position), _amount);
        }

        // Proceed to internal minting steps
        (uint256 ptMinted, uint256 ytMinted) = _mint(_expiration, _position);
        // This sanity check ensure that at least as much was minted as was transferred
        require(ytMinted >= _amount, "Not enough minted");
        return (ptMinted, ytMinted);
    }

    
    ///      likely quite a bit more expensive than direct unwrapping but useful
    ///      for those who want to do one tx instead of two
    
    
    
    
    
    ///                        should be used to get allowances for PT and YT
    // NOTE - It is critical that the notFrozen modifier is listed first so it gets called first.
    function withdrawWeth(
        uint256 _expiration,
        address _position,
        uint256 _amountPT,
        uint256 _amountYT,
        PermitData[] calldata _permitCallData
    ) external notFrozen() preApproval(_permitCallData) {
        // Post the Berlin hardfork this call warms the address so only cost ~100 gas overall
        require(IWrappedPosition(_position).token() == weth, "Non weth token");
        // Only allow access if the user is actually attempting to withdraw
        require(((_amountPT != 0) || (_amountYT != 0)), "Invalid withdraw");
        // Because of create2 we know this code is exactly what is expected.
        ITranche derivedTranche = _deriveTranche(_position, _expiration);

        uint256 wethReceivedPt = 0;
        uint256 wethReceivedYt = 0;
        // Check if we need to withdraw principal token
        if (_amountPT != 0) {
            // If we have to withdraw PT first transfer it to this contract
            derivedTranche.transferFrom(msg.sender, address(this), _amountPT);
            // Then we withdraw that PT with the resulting weth going to this address
            wethReceivedPt = derivedTranche.withdrawPrincipal(
                _amountPT,
                address(this)
            );
        }
        // Check if we need to withdraw yield token
        if (_amountYT != 0) {
            // Post Berlin this lookup only costs 100 gas overall as well
            IERC20Permit yieldToken = derivedTranche.interestToken();
            // Transfer the YT to this contract
            yieldToken.transferFrom(msg.sender, address(this), _amountYT);
            // Withdraw that YT
            wethReceivedYt = derivedTranche.withdrawInterest(
                _amountYT,
                address(this)
            );
        }

        // A sanity check that some value was withdrawn
        if (_amountPT != 0) {
            require((wethReceivedPt != 0), "Rugged");
        }
        if (_amountYT != 0) {
            require((wethReceivedYt != 0), "No yield accrued");
        }
        // Withdraw the ether from weth
        weth.withdraw(wethReceivedPt + wethReceivedYt);
        // Send the withdrawn eth to the caller
        payable(msg.sender).transfer(wethReceivedPt + wethReceivedYt);
    }

    
    ///      eth directly to this contract. Note - It Cannot be assumed
    ///      that this will prevent this contract from having an ETH balance
    receive() external payable {
        require(msg.sender == address(weth));
    }

    
    ///      the contract has already transferred to WrappedPosition contract
    
    
    
    function _mint(uint256 _expiration, address _position)
        internal
        returns (uint256, uint256)
    {
        // Use create2 to derive the tranche contract
        ITranche tranche = _deriveTranche(address(_position), _expiration);
        // Move funds into the Tranche contract
        // it will credit the msg.sender with the new tokens
        return tranche.prefundedDeposit(msg.sender);
    }

    
    ///      address of the Tranche contract from a wrapped position contract and expiration
    
    
    
    function _deriveTranche(address _position, uint256 _expiration)
        internal
        virtual
        view
        returns (ITranche)
    {
        bytes32 salt = keccak256(abi.encodePacked(_position, _expiration));
        bytes32 addressBytes = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                _trancheFactory,
                salt,
                _trancheBytecodeHash
            )
        );
        return ITranche(address(uint160(uint256(addressBytes))));
    }

    
    ///      it should be removed so that users do not have to remove allowances.
    ///      Note - onlyOwner is a stronger check than onlyAuthorized, many addresses can be
    ///      authorized to freeze or unfreeze the contract but only the owner address can kill
    function deprecate() external onlyOwner() {
        selfdestruct(payable(msg.sender));
    }
}

// 
pragma solidity ^0.8.0;




interface ITranche is IERC20Permit {
    function deposit(uint256 _shares, address destination)
        external
        returns (uint256, uint256);

    function prefundedDeposit(address _destination)
        external
        returns (uint256, uint256);

    function withdrawPrincipal(uint256 _amount, address _destination)
        external
        returns (uint256);

    function withdrawInterest(uint256 _amount, address _destination)
        external
        returns (uint256);

    function interestToken() external view returns (IInterestToken);

    function interestSupply() external view returns (uint128);
}

// 
pragma solidity ^0.8.0;



interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}

// 
pragma solidity ^0.8.0;




interface IWrappedPosition is IERC20Permit {
    function token() external view returns (IERC20);

    function balanceOfUnderlying(address who) external view returns (uint256);

    function getSharesToUnderlying(uint256 shares)
        external
        view
        returns (uint256);

    function deposit(address sender, uint256 amount) external returns (uint256);

    function withdraw(
        address sender,
        uint256 _shares,
        uint256 _minUnderlying
    ) external returns (uint256);

    function withdrawUnderlying(
        address _destination,
        uint256 _amount,
        uint256 _minUnderlying
    ) external returns (uint256, uint256);

    function prefundedDeposit(address _destination)
        external
        returns (
            uint256,
            uint256,
            uint256
        );
}

// 
pragma solidity ^0.8.0;



interface IInterestToken is IERC20Permit {
    function mint(address _account, uint256 _amount) external;

    function burn(address _account, uint256 _amount) external;
}
