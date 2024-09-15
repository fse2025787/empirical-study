// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2021-05-14
*/

// 
// @title NekoSushi....🐈_🍣_🍱
// @author Gatoshi Nyakamoto

pragma solidity 0.8.4;

// solhint-disable avoid-low-level-calls
// solhint-disable not-rely-on-time
// solhint-disable no-inline-assembly

// File @boringcrypto/boring-solidity/contracts/[email protected]
// License-Identifier: MIT


contract Domain {
    bytes32 private constant DOMAIN_SEPARATOR_SIGNATURE_HASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
    // See https://eips.ethereum.org/EIPS/eip-191
    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = "\x19\x01";

    // solhint-disable var-name-mixedcase
    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 private immutable DOMAIN_SEPARATOR_CHAIN_ID;

    
    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_SEPARATOR_SIGNATURE_HASH, chainId, address(this)));
    }

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = _calculateDomainSeparator(DOMAIN_SEPARATOR_CHAIN_ID = chainId);
    }

    
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId == DOMAIN_SEPARATOR_CHAIN_ID ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId);
    }

    function _getDigest(bytes32 dataHash) internal view returns (bytes32 digest) {
        digest = keccak256(abi.encodePacked(EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA, DOMAIN_SEPARATOR(), dataHash));
    }
}

// File @boringcrypto/boring-solidity/contracts/[email protected]
// License-Identifier: MIT


contract ERC20Data {
    
    mapping(address => uint256) public balanceOf;
    
    mapping(address => mapping(address => uint256)) public allowance;
    
    mapping(address => uint256) public nonces;
}


contract ERC20 is Domain, ERC20Data {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    
    
    
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount; 
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    
    
    
    
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        // @dev If allowance is infinite, don't decrease it to save on gas (breaks with ERC-20).
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= amount;
        }
        balanceOf[from] -= amount;
        balanceOf[to] += amount; 
        emit Transfer(from, to, amount);
        return true;
    }

    
    
    
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private constant PERMIT_SIGNATURE_HASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    
    
    
    
    
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(owner != address(0), "ERC20: Owner cannot be 0");
        require(block.timestamp < deadline, "ERC20: Expired");
        require(
            ecrecover(_getDigest(keccak256(abi.encode(PERMIT_SIGNATURE_HASH, owner, spender, amount, nonces[owner]++, deadline))), v, r, s) ==
                owner,
            "ERC20: Invalid Signature"
        );
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

// File @boringcrypto/boring-solidity/contracts/[email protected]
// License-Identifier: MIT


contract BaseBoringBatchable {
    
    /// If the returned data is malformed or not correctly abi encoded then this call can fail itself.
    function _getRevertMsg(bytes memory _returnData) private pure returns (string memory) {
        // @dev If the length is less than 68, the transaction failed silently (without a revert message).
        if (_returnData.length < 68) return "Transaction reverted silently";
        assembly {
            // @dev Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        // @dev All that remains is the revert string.
        return abi.decode(_returnData, (string));
    }

    
    
    
    function batch(bytes[] calldata calls, bool revertOnFail) external payable {
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            if (!success && revertOnFail) {
                revert(_getRevertMsg(result));
            }
        }
    }
}


interface IERC20{} interface IBentoBoxBasic {
    function deposit( 
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);
}


interface ISushiBar { 
    function balanceOf(address account) external view returns (uint256);
    function enter(uint256 amount) external;
    function leave(uint256 share) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


interface ISushiSwap {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


interface IWETH9 {
    function deposit() external payable;
    function transfer(address dst, uint wad) external returns (bool);
}


contract NekoSushi is ERC20, BaseBoringBatchable {
    IBentoBoxBasic private constant bentoBox = IBentoBoxBasic(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966); // BENTO vault contract
    ISushiBar private constant sushiToken = ISushiBar(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2); // SUSHI token contract
    address private constant sushiBar = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272; // xSUSHI token contract for staking SUSHI
    ISushiSwap private constant sushiSwapSushiETHpair = ISushiSwap(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0); // SUSHI/ETH pair on SushiSwap
    IWETH9 private constant wETH9 = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // ETH wrapper contract v9
    
    string public constant name = "Neko Sushi";
    string public constant symbol = "NEKO";
    uint8  public constant decimals = 18;
    uint256 private constant multiplier = 999; // 1 xSUSHI BENTO share = 999 NEKO
    uint256 public totalSupply;
    
    constructor() {
        sushiToken.approve(sushiBar, type(uint256).max); // max approve xSUSHI to draw SUSHI from this contract
        ISushiBar(sushiBar).approve(address(bentoBox), type(uint256).max); // max approve BENTO to draw xSUSHI from this contract
    }
    
    /// **** xSUSHI NYAN
    
    function nyan(address to, uint256 amount) external {
        ISushiBar(sushiBar).transferFrom(msg.sender, address(this), amount);
        (, uint256 shares) = bentoBox.deposit(IERC20(sushiBar), address(this), address(this), amount, 0);
        nyanMint(to, shares * multiplier);
    }

    
    function unNyan(address to, uint256 amount) external {
        nyanBurn(amount);
        (uint256 amountOut, ) = bentoBox.withdraw(IERC20(sushiBar), address(this), address(this), 0, amount / multiplier);
        ISushiBar(sushiBar).transfer(to, amountOut);
    }
    
    /// **** SUSHI NYAN
    
    function nyanSUSHI(address to, uint256 amount) external {
        sushiToken.transferFrom(msg.sender, address(this), amount);
        ISushiBar(sushiBar).enter(amount);
        (, uint256 shares) = bentoBox.deposit(IERC20(sushiBar), address(this), address(this), ISushiBar(sushiBar).balanceOf(address(this)), 0);
        nyanMint(to, shares * multiplier);
    }

    
    function unNyanSUSHI(address to, uint256 amount) external {
        nyanBurn(amount);
        (uint256 amountOut, ) = bentoBox.withdraw(IERC20(sushiBar), address(this), address(this), 0, amount / multiplier);
        ISushiBar(sushiBar).leave(amountOut);
        sushiToken.transfer(to, sushiToken.balanceOf(address(this))); 
    }
    
    /// **** ETH NYAN
    
    receive() external payable {
        nyanETHSwap(msg.sender);
    }
    
    
    function nyanETH(address to) external payable {
        nyanETHSwap(to);
    }
    
    /// **** HELPERS
    
    function nyanMint(address to, uint256 amount) private {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }
    
    
    function nyanBurn(uint256 amount) private {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
    
    
    function nyanETHSwap(address to) private {
        (uint256 reserve0, uint256 reserve1, ) = sushiSwapSushiETHpair.getReserves();
        uint256 amountInWithFee = msg.value * 997;
        uint256 out = (amountInWithFee * reserve0) / (reserve1 * 1000) + amountInWithFee;
        wETH9.deposit{value: msg.value}();
        wETH9.transfer(address(sushiSwapSushiETHpair), msg.value);
        sushiSwapSushiETHpair.swap(out, 0, address(this), "");
        ISushiBar(sushiBar).enter(sushiToken.balanceOf(address(this))); 
        (, uint256 shares) = bentoBox.deposit(IERC20(sushiBar), address(this), address(this), ISushiBar(sushiBar).balanceOf(address(this)), 0); 
        nyanMint(to, shares * multiplier);
    }
}