// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-04-16
*/

/// 
/*
▄▄█    ▄   ██   █▄▄▄▄ ▄█ 
██     █  █ █  █  ▄▀ ██ 
██ ██   █ █▄▄█ █▀▀▌  ██ 
▐█ █ █  █ █  █ █  █  ▐█ 
 ▐ █  █ █    █   █    ▐ 
   █   ██   █   ▀   
           ▀          */
/// Special thanks to Keno, Boring and Gonpachi for review and continued inspiration.
pragma solidity 0.6.12;


// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
/// License-Identifier: MIT


/// updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math).
library BoringMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function to128(uint256 a) internal pure returns (uint128 c) {
        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {
        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {
        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}


interface IAaveBridge {
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);

    function deposit( 
        address asset, 
        uint256 amount, 
        address onBehalfOf, 
        uint16 referralCode
    ) external;

    function withdraw( 
        address token, 
        uint256 amount, 
        address destination
    ) external;
}


interface IBentoBridge {
    function balanceOf(IERC20, address) external view returns (uint256);
    
    function registerProtocol() external;

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


interface ICompoundBridge {
    function underlying() external view returns (address);
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
}


interface IDaiPermit {
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}


interface ISushiBarBridge { 
    function enter(uint256 amount) external;
    function leave(uint256 share) external;
}


interface ISushiSwap {
    function deposit() external payable; // wETH helper
    function withdraw(uint wad) external; // wETH helper
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

// File @boringcrypto/boring-solidity/contracts/interfaces/[email protected]
/// License-Identifier: MIT

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
/// License-Identifier: MIT

library BoringERC20 {
    bytes4 private constant SIG_SYMBOL = 0x95d89b41; // symbol()
    bytes4 private constant SIG_NAME = 0x06fdde03; // name()
    bytes4 private constant SIG_DECIMALS = 0x313ce567; // decimals()
    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd; // transferFrom(address,address,uint256)

    
    /// Reverts on a failed transfer.
    
    
    
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
    }

    
    /// Reverts on a failed transfer.
    
    
    
    
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
    }
}

// File @boringcrypto/boring-solidity/contracts/[email protected]
/// License-Identifier: MIT

contract BaseBoringBatchable {
    
    /// If the returned data is malformed or not correctly abi encoded then this call can fail itself.
    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    
    
    
    
    
    // F1: External is ok here because this is the batch function, adding it to a batch makes no sense
    // F2: Calls in the batch may be payable, delegatecall operates in the same context, so each call in the batch has access to msg.value
    // C3: The length of the loop is fully under user control, so can't be exploited
    // C7: Delegatecall is only used on the same contract, so it's safe
    function batch(bytes[] calldata calls, bool revertOnFail) external payable returns (bool[] memory successes, bytes[] memory results) {
        successes = new bool[](calls.length);
        results = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            require(success || !revertOnFail, _getRevertMsg(result));
            successes[i] = success;
            results[i] = result;
        }
    }
}


contract BoringBatchableWithDai is BaseBoringBatchable {
    address constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI token contract
    
    
    /// Lookup `IDaiPermit.permit`.
    function permitDai(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        IDaiPermit(dai).permit(holder, spender, nonce, expiry, allowed, v, r, s);
    }
    
    
    /// Lookup `IERC20.permit`.
    // F6: Parameters can be used front-run the permit and the user's permit will fail (due to nonce or other revert)
    //     if part of a batch this could be used to grief once as the second call would not need the permit
    function permitToken(
        IERC20 token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        token.permit(from, to, amount, deadline, v, r, s);
    }
}


contract Inari is BoringBatchableWithDai {
    using BoringMath for uint256;
    using BoringERC20 for IERC20;
    
    IERC20 constant sushiToken = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2); // SUSHI token contract
    address constant sushiBar = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272; // xSUSHI staking contract for SUSHI
    IAaveBridge constant aave = IAaveBridge(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9); // AAVE lending pool contract for xSUSHI staking into aXSUSHI
    IERC20 constant aaveSushiToken = IERC20(0xF256CC7847E919FAc9B808cC216cAc87CCF2f47a); // aXSUSHI staking contract for xSUSHI
    IBentoBridge constant bento = IBentoBridge(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966); // BENTO vault contract
    address constant crSushiToken = 0x338286C0BC081891A4Bda39C7667ae150bf5D206; // crSUSHI staking contract for SUSHI
    address constant crXSushiToken = 0x228619CCa194Fbe3Ebeb2f835eC1eA5080DaFbb2; // crXSUSHI staking contract for xSUSHI
    address constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // ETH wrapper contract (v9)
    address constant sushiSwapFactory = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac; // SushiSwap factory contract
    ISushiSwap constant sushiSwapSushiETHPair = ISushiSwap(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0); // SUSHI/ETH pair on SushiSwap
    bytes32 constant pairCodeHash = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303; // SushiSwap pair code hash

    
    constructor() public {
        bento.registerProtocol(); // register this contract with BENTO
        sushiToken.approve(address(sushiBar), type(uint256).max); // max approve `sushiBar` spender to stake SUSHI into xSUSHI from this contract
        sushiToken.approve(crSushiToken, type(uint256).max); // max approve `crSushiToken` spender to stake SUSHI into crSUSHI from this contract
        IERC20(sushiBar).approve(address(aave), type(uint256).max); // max approve `aave` spender to stake xSUSHI into aXSUSHI from this contract
        IERC20(sushiBar).approve(address(bento), type(uint256).max); // max approve `bento` spender to stake xSUSHI into BENTO from this contract
        IERC20(sushiBar).approve(crXSushiToken, type(uint256).max); // max approve `crXSushiToken` spender to stake xSUSHI into crXSUSHI from this contract
        IERC20(dai).approve(address(bento), type(uint256).max); // max approve `bento` spender to pull DAI into BENTO from this contract
    }

    
    function bridgeABC(IERC20[] calldata underlying, address[] calldata cToken) external {
        for (uint256 i = 0; i < underlying.length; i++) {
            underlying[i].approve(address(aave), type(uint256).max); // max approve `aave` spender to pull `underlying` from this contract
            underlying[i].approve(address(bento), type(uint256).max); // max approve `bento` spender to pull `underlying` from this contract
            underlying[i].approve(cToken[i], type(uint256).max); // max approve `cToken` spender to pull `underlying` from this contract (also serves as generalized approval bridge)
        }
    }

    /************
    SUSHI HELPERS 
    ************/
    
    function stakeSushi(address to, uint256 amount) external {
        sushiToken.safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` SUSHI `amount` into this contract
        ISushiBarBridge(sushiBar).enter(amount); // stake deposited SUSHI into `sushiBar` xSUSHI
        IERC20(sushiBar).safeTransfer(to, IERC20(sushiBar).balanceOf(address(this))); // transfer resulting xSUSHI to `to`
    }
    
    
    function stakeSushiBalance(address to) external {
        ISushiBarBridge(sushiBar).enter(sushiToken.balanceOf(address(this))); // stake local SUSHI into `sushiBar` xSUSHI
        IERC20(sushiBar).safeTransfer(to, IERC20(sushiBar).balanceOf(address(this))); // transfer resulting xSUSHI to `to`
    }
    
    /**********
    TKN HELPERS 
    **********/
    
    function depositToken(IERC20 token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount); 
    }

    
    function withdrawToken(IERC20 token, address to, uint256 amount) external {
        IERC20(token).safeTransfer(to, amount); 
    }
    
    
    function withdrawTokenBalance(IERC20 token, address to) external {
        IERC20(token).safeTransfer(to, token.balanceOf(address(this))); 
    }
/*
██   ██       ▄   ▄███▄   
█ █  █ █       █  █▀   ▀  
█▄▄█ █▄▄█ █     █ ██▄▄    
█  █ █  █  █    █ █▄   ▄▀ 
   █    █   █  █  ▀███▀   
  █    █     █▐           
 ▀    ▀      ▐         */
    
    /***********
    AAVE HELPERS 
    ***********/
    function toAave(address underlying, address to, uint256 amount) external {
        aave.deposit(underlying, amount, to, 0); 
    }

    function balanceToAave(address underlying, address to) external {
        aave.deposit(underlying, IERC20(underlying).balanceOf(address(this)), to, 0); 
    }
    
    function fromAave(address underlying, address to, uint256 amount) external {
        aave.withdraw(underlying, amount, to); 
    }
    
    function balanceFromAave(address aToken, address to) external {
        address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS(); // sanity check for `underlying` token
        aave.withdraw(underlying, IERC20(aToken).balanceOf(address(this)), to); 
    }
    
    /**************************
    AAVE -> UNDERLYING -> BENTO 
    **************************/
    
    function aaveToBento(address aToken, address to, uint256 amount) external {
        IERC20(aToken).safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` `aToken` `amount` into this contract
        address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS(); // sanity check for `underlying` token
        aave.withdraw(underlying, amount, address(this)); // burn deposited `aToken` from `aave` into `underlying`
        bento.deposit(IERC20(underlying), address(this), to, amount, 0); // stake `underlying` into BENTO for `to`
    }
    
    /**************************
    BENTO -> UNDERLYING -> AAVE 
    **************************/
    
    function bentoToAave(IERC20 underlying, address to, uint256 amount) external {
        bento.withdraw(underlying, msg.sender, address(this), amount, 0); // withdraw `amount` of `underlying` from BENTO into this contract
        aave.deposit(address(underlying), amount, to, 0); // stake `underlying` into `aave` for `to`
    }
    
    /*************************
    AAVE -> UNDERLYING -> COMP 
    *************************/
    
    function aaveToCompound(address aToken, address cToken, address to, uint256 amount) external {
        IERC20(aToken).safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` `aToken` `amount` into this contract
        address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS(); // sanity check for `underlying` token
        aave.withdraw(underlying, amount, address(this)); // burn deposited `aToken` from `aave` into `underlying`
        ICompoundBridge(cToken).mint(amount); // stake `underlying` into `cToken`
        IERC20(cToken).safeTransfer(to, IERC20(cToken).balanceOf(address(this))); // transfer resulting `cToken` to `to`
    }
    
    /*************************
    COMP -> UNDERLYING -> AAVE 
    *************************/
    
    function compoundToAave(address cToken, address to, uint256 amount) external {
        IERC20(cToken).safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` `cToken` `amount` into this contract
        ICompoundBridge(cToken).redeem(amount); // burn deposited `cToken` into `underlying`
        address underlying = ICompoundBridge(cToken).underlying(); // sanity check for `underlying` token
        aave.deposit(underlying, IERC20(underlying).balanceOf(address(this)), to, 0); // stake resulting `underlying` into `aave` for `to`
    }
    
    /**********************
    SUSHI -> XSUSHI -> AAVE 
    **********************/
    
    function stakeSushiToAave(address to, uint256 amount) external {
        sushiToken.safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` SUSHI `amount` into this contract
        ISushiBarBridge(sushiBar).enter(amount); // stake deposited SUSHI into `sushiBar` xSUSHI
        aave.deposit(sushiBar, IERC20(sushiBar).balanceOf(address(this)), to, 0); // stake resulting xSUSHI into `aave` aXSUSHI for `to`
    }
    
    /**********************
    AAVE -> XSUSHI -> SUSHI 
    **********************/
    
    function unstakeSushiFromAave(address to, uint256 amount) external {
        aaveSushiToken.safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` aXSUSHI `amount` into this contract
        aave.withdraw(sushiBar, amount, address(this)); // burn deposited aXSUSHI from `aave` into xSUSHI
        ISushiBarBridge(sushiBar).leave(amount); // burn resulting xSUSHI from `sushiBar` into SUSHI
        sushiToken.safeTransfer(to, sushiToken.balanceOf(address(this))); // transfer resulting SUSHI to `to`
    }
/*
███   ▄███▄      ▄     ▄▄▄▄▀ ████▄ 
█  █  █▀   ▀      █ ▀▀▀ █    █   █ 
█ ▀ ▄ ██▄▄    ██   █    █    █   █ 
█  ▄▀ █▄   ▄▀ █ █  █   █     ▀████ 
███   ▀███▀   █  █ █  ▀            
              █   ██            */ 
    
    function daiToBentoWithPermit(
        address to, uint256 amount, uint256 nonce, uint256 expiry,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        IDaiPermit(dai).permit(msg.sender, address(this), nonce, expiry, true, v, r, s); // `permit()` this contract to spend `msg.sender` `dai`
        IERC20(dai).safeTransferFrom(msg.sender, address(this), amount); // pull `dai` `amount` into this contract
        bento.deposit(IERC20(dai), address(this), to, amount, 0); // stake `dai` into BENTO for `to`
    }
    
    /************
    BENTO HELPERS 
    ************/
    function toBento(IERC20 token, address to, uint256 amount) external {
        bento.deposit(token, address(this), to, amount, 0); 
    }
    
    function balanceToBento(IERC20 token, address to) external {
        bento.deposit(token, address(this), to, token.balanceOf(address(this)), 0); 
    }
    
    function fromBento(IERC20 token, address to, uint256 amount) external {
        bento.withdraw(token, msg.sender, to, amount, 0); 
    }
    
    function balanceFromBento(IERC20 token, address to) external {
        bento.withdraw(token, msg.sender, to, bento.balanceOf(token, msg.sender), 0); 
    }
    
    function ethToBento(address to) external payable {
        ISushiSwap(wETH).deposit{value: msg.value}();
        bento.deposit(IERC20(wETH), address(this), to, msg.value, 0); 
    }

    /***********************
    SUSHI -> XSUSHI -> BENTO 
    ***********************/
    
    function stakeSushiToBento(address to, uint256 amount) external {
        sushiToken.safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` SUSHI `amount` into this contract
        ISushiBarBridge(sushiBar).enter(amount); // stake deposited SUSHI into `sushiBar` xSUSHI
        bento.deposit(IERC20(sushiBar), address(this), to, IERC20(sushiBar).balanceOf(address(this)), 0); // stake resulting xSUSHI into BENTO for `to`
    }
    
    /***********************
    BENTO -> XSUSHI -> SUSHI 
    ***********************/
    
    function unstakeSushiFromBento(address to, uint256 amount) external {
        bento.withdraw(IERC20(sushiBar), msg.sender, address(this), amount, 0); // withdraw `amount` of xSUSHI from BENTO into this contract
        ISushiBarBridge(sushiBar).leave(amount); // burn withdrawn xSUSHI from `sushiBar` into SUSHI
        sushiToken.safeTransfer(to, sushiToken.balanceOf(address(this))); // transfer resulting SUSHI to `to`
    }
/*    
▄█▄    █▄▄▄▄ ▄███▄   ██   █▀▄▀█ 
█▀ ▀▄  █  ▄▀ █▀   ▀  █ █  █ █ █ 
█   ▀  █▀▀▌  ██▄▄    █▄▄█ █ ▄ █ 
█▄  ▄▀ █  █  █▄   ▄▀ █  █ █   █ 
▀███▀    █   ▀███▀      █    █  
        ▀              █    ▀  
                      ▀      */
// - COMPOUND - //
    /***********
    COMP HELPERS 
    ***********/
    function toCompound(ICompoundBridge cToken, uint256 underlyingAmount) external {
        cToken.mint(underlyingAmount); 
    }

    function balanceToCompound(ICompoundBridge cToken) external {
        IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying()); // sanity check for `underlying` token
        cToken.mint(underlying.balanceOf(address(this)));
    }
    
    function fromCompound(ICompoundBridge cToken, uint256 cTokenAmount) external {
        ICompoundBridge(cToken).redeem(cTokenAmount);
    }
    
    function balanceFromCompound(address cToken) external {
        ICompoundBridge(cToken).redeem(IERC20(cToken).balanceOf(address(this)));
    }
    
    /**************************
    COMP -> UNDERLYING -> BENTO 
    **************************/
    
    function compoundToBento(address cToken, address to, uint256 cTokenAmount) external {
        IERC20(cToken).safeTransferFrom(msg.sender, address(this), cTokenAmount); // deposit `msg.sender` `cToken` `cTokenAmount` into this contract
        ICompoundBridge(cToken).redeem(cTokenAmount); // burn deposited `cToken` into `underlying`
        IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying()); // sanity check for `underlying` token
        bento.deposit(underlying, address(this), to, underlying.balanceOf(address(this)), 0); // stake resulting `underlying` into BENTO for `to`
    }
    
    /**************************
    BENTO -> UNDERLYING -> COMP 
    **************************/
    
    function bentoToCompound(address cToken, address to, uint256 underlyingAmount) external {
        IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying()); // sanity check for `underlying` token
        bento.withdraw(underlying, msg.sender, address(this), underlyingAmount, 0); // withdraw `underlyingAmount` of `underlying` from BENTO into this contract
        ICompoundBridge(cToken).mint(underlyingAmount); // stake `underlying` into `cToken`
        IERC20(cToken).safeTransfer(to, IERC20(cToken).balanceOf(address(this))); // transfer resulting `cToken` to `to`
    }
    
    /**********************
    SUSHI -> CREAM -> BENTO 
    **********************/
    
    function sushiToCreamToBento(address to, uint256 amount) external {
        sushiToken.safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` SUSHI `amount` into this contract
        ICompoundBridge(crSushiToken).mint(amount); // stake deposited SUSHI into crSUSHI
        bento.deposit(IERC20(crSushiToken), address(this), to, IERC20(crSushiToken).balanceOf(address(this)), 0); // stake resulting crSUSHI into BENTO for `to`
    }
    
    /**********************
    BENTO -> CREAM -> SUSHI 
    **********************/
    
    function sushiFromCreamFromBento(address to, uint256 cTokenAmount) external {
        bento.withdraw(IERC20(crSushiToken), msg.sender, address(this), cTokenAmount, 0); // withdraw `cTokenAmount` of `crSushiToken` from BENTO into this contract
        ICompoundBridge(crSushiToken).redeem(cTokenAmount); // burn deposited `crSushiToken` into SUSHI
        sushiToken.safeTransfer(to, sushiToken.balanceOf(address(this))); // transfer resulting SUSHI to `to`
    }
    
    /***********************
    SUSHI -> XSUSHI -> CREAM 
    ***********************/
    
    function stakeSushiToCream(address to, uint256 amount) external {
        sushiToken.safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` SUSHI `amount` into this contract
        ISushiBarBridge(sushiBar).enter(amount); // stake deposited SUSHI `amount` into `sushiBar` xSUSHI
        ICompoundBridge(crXSushiToken).mint(IERC20(sushiBar).balanceOf(address(this))); // stake resulting xSUSHI into crXSUSHI
        IERC20(crXSushiToken).safeTransfer(to, IERC20(crXSushiToken).balanceOf(address(this))); // transfer resulting crXSUSHI to `to`
    }
    
    /***********************
    CREAM -> XSUSHI -> SUSHI 
    ***********************/
    
    function unstakeSushiFromCream(address to, uint256 cTokenAmount) external {
        IERC20(crXSushiToken).safeTransferFrom(msg.sender, address(this), cTokenAmount); // deposit `msg.sender` `crXSushiToken` `cTokenAmount` into this contract
        ICompoundBridge(crXSushiToken).redeem(cTokenAmount); // burn deposited `crXSushiToken` `cTokenAmount` into xSUSHI
        ISushiBarBridge(sushiBar).leave(IERC20(sushiBar).balanceOf(address(this))); // burn resulting xSUSHI `amount` from `sushiBar` into SUSHI
        sushiToken.safeTransfer(to, sushiToken.balanceOf(address(this))); // transfer resulting SUSHI to `to`
    }
    
    /********************************
    SUSHI -> XSUSHI -> CREAM -> BENTO 
    ********************************/
    
    function stakeSushiToCreamToBento(address to, uint256 amount) external {
        sushiToken.safeTransferFrom(msg.sender, address(this), amount); // deposit `msg.sender` SUSHI `amount` into this contract
        ISushiBarBridge(sushiBar).enter(amount); // stake deposited SUSHI `amount` into `sushiBar` xSUSHI
        ICompoundBridge(crXSushiToken).mint(IERC20(sushiBar).balanceOf(address(this))); // stake resulting xSUSHI into crXSUSHI
        bento.deposit(IERC20(crXSushiToken), address(this), to, IERC20(crXSushiToken).balanceOf(address(this)), 0); // stake resulting crXSUSHI into BENTO for `to`
    }
    
    /********************************
    BENTO -> CREAM -> XSUSHI -> SUSHI 
    ********************************/
    
    function unstakeSushiFromCreamFromBento(address to, uint256 cTokenAmount) external {
        bento.withdraw(IERC20(crXSushiToken), msg.sender, address(this), cTokenAmount, 0); // withdraw `cTokenAmount` of `crXSushiToken` from BENTO into this contract
        ICompoundBridge(crXSushiToken).redeem(cTokenAmount); // burn deposited `crXSushiToken` `cTokenAmount` into xSUSHI
        ISushiBarBridge(sushiBar).leave(IERC20(sushiBar).balanceOf(address(this))); // burn resulting xSUSHI from `sushiBar` into SUSHI
        sushiToken.safeTransfer(to, sushiToken.balanceOf(address(this))); // transfer resulting SUSHI to `to`
    }
/*
   ▄▄▄▄▄    ▄ ▄   ██   █ ▄▄      
  █     ▀▄ █   █  █ █  █   █     
▄  ▀▀▀▀▄  █ ▄   █ █▄▄█ █▀▀▀      
 ▀▄▄▄▄▀   █  █  █ █  █ █         
           █ █ █     █  █        
            ▀ ▀     █    ▀       
                   ▀     */
    
    receive() external payable { // INARIZUSHI
        (uint256 reserve0, uint256 reserve1, ) = sushiSwapSushiETHPair.getReserves();
        uint256 amountInWithFee = msg.value.mul(997);
        uint256 amountOut =
            amountInWithFee.mul(reserve0) /
            reserve1.mul(1000).add(amountInWithFee);
        ISushiSwap(wETH).deposit{value: msg.value}();
        IERC20(wETH).safeTransfer(address(sushiSwapSushiETHPair), msg.value);
        sushiSwapSushiETHPair.swap(amountOut, 0, address(this), "");
        ISushiBarBridge(sushiBar).enter(sushiToken.balanceOf(address(this))); // stake resulting SUSHI into `sushiBar` xSUSHI
        bento.deposit(IERC20(sushiBar), address(this), msg.sender, IERC20(sushiBar).balanceOf(address(this)), 0); // stake resulting xSUSHI into BENTO for `msg.sender`
    }
    
    
    function ethStakeSushi(address to) external payable { // SWAP `N STAKE
        (uint256 reserve0, uint256 reserve1, ) = sushiSwapSushiETHPair.getReserves();
        uint256 amountInWithFee = msg.value.mul(997);
        uint256 amountOut =
            amountInWithFee.mul(reserve0) /
            reserve1.mul(1000).add(amountInWithFee);
        ISushiSwap(wETH).deposit{value: msg.value}();
        IERC20(wETH).safeTransfer(address(sushiSwapSushiETHPair), msg.value);
        sushiSwapSushiETHPair.swap(amountOut, 0, address(this), "");
        ISushiBarBridge(sushiBar).enter(sushiToken.balanceOf(address(this))); // stake resulting SUSHI into `sushiBar` xSUSHI
        IERC20(sushiBar).safeTransfer(to, IERC20(sushiBar).balanceOf(address(this))); // transfer resulting xSUSHI to `to`
    }

    
    function swap(address fromToken, address toToken, address to, uint256 amountIn) external returns (uint256 amountOut) {
        (address token0, address token1) = fromToken < toToken ? (fromToken, toToken) : (toToken, fromToken);
        ISushiSwap pair =
            ISushiSwap(
                uint256(
                    keccak256(abi.encodePacked(hex"ff", sushiSwapFactory, keccak256(abi.encodePacked(token0, token1)), pairCodeHash))
                )
            );
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amountInWithFee = amountIn.mul(997);
        IERC20(fromToken).safeTransferFrom(msg.sender, address(this), amountIn);
        if (toToken > fromToken) {
            amountOut =
                amountInWithFee.mul(reserve1) /
                reserve0.mul(1000).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(0, amountOut, to, "");
        } else {
            amountOut =
                amountInWithFee.mul(reserve0) /
                reserve1.mul(1000).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(amountOut, 0, to, "");
        }
    }
    
    
    function swapBalance(address fromToken, address toToken, address to) external returns (uint256 amountOut) {
        (address token0, address token1) = fromToken < toToken ? (fromToken, toToken) : (toToken, fromToken);
        ISushiSwap pair =
            ISushiSwap(
                uint256(
                    keccak256(abi.encodePacked(hex"ff", sushiSwapFactory, keccak256(abi.encodePacked(token0, token1)), pairCodeHash))
                )
            );
        uint256 amountIn = IERC20(fromToken).balanceOf(address(this));
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amountInWithFee = amountIn.mul(997);
        if (toToken > fromToken) {
            amountOut =
                amountInWithFee.mul(reserve1) /
                reserve0.mul(1000).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(0, amountOut, to, "");
        } else {
            amountOut =
                amountInWithFee.mul(reserve0) /
                reserve1.mul(1000).add(amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(amountOut, 0, to, "");
        }
    }
    
    
    function swapETH(address toToken, address to) external payable returns (uint256 amountOut) {
        (address token0, address token1) = wETH < toToken ? (wETH, toToken) : (toToken, wETH);
        ISushiSwap pair =
            ISushiSwap(
                uint256(
                    keccak256(abi.encodePacked(hex"ff", sushiSwapFactory, keccak256(abi.encodePacked(token0, token1)), pairCodeHash))
                )
            );
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amountInWithFee = msg.value.mul(997);
        ISushiSwap(wETH).deposit{value: msg.value}();
        if (toToken > wETH) {
            amountOut =
                amountInWithFee.mul(reserve1) /
                reserve0.mul(1000).add(amountInWithFee);
            IERC20(wETH).safeTransfer(address(pair), msg.value);
            pair.swap(0, amountOut, to, "");
        } else {
            amountOut =
                amountInWithFee.mul(reserve0) /
                reserve1.mul(1000).add(amountInWithFee);
            IERC20(wETH).safeTransfer(address(pair), msg.value);
            pair.swap(amountOut, 0, to, "");
        }
    }
}