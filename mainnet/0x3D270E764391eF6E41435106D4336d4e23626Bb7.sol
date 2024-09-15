// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

// 
pragma solidity 0.6.12;

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
// License-Identifier: MIT


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


library BoringMath128 {
    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}


library BoringMath64 {
    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}


library BoringMath32 {
    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

// File contracts/interfaces/IOracle.sol
// License-Identifier: MIT

interface IOracle {
    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    
    function get(bytes calldata data) external returns (bool success, uint256 rate);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    
    function peek(bytes calldata data) external view returns (bool success, uint256 rate);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    function peekSpot(bytes calldata data) external view returns (uint256 rate);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    function symbol(bytes calldata data) external view returns (string memory);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    function name(bytes calldata data) external view returns (string memory);
}


interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}





contract xSUSHIOracleV1 is IOracle {
    using BoringMath for uint256; // Keep everything in uint256

    IERC20 public immutable sushi;
    IERC20 public immutable bar;
    IAggregator public immutable sushiOracle;

    constructor (IERC20 sushi_, IERC20 bar_, IAggregator sushiOracle_) public {
        sushi = sushi_;
        bar = bar_;
        sushiOracle = sushiOracle_;
    }

    // Calculates the lastest exchange rate
    // Uses sushi rate and xSUSHI conversion and divide for any conversion other than from SUSHI to ETH
    function _get(
        address divide,
        uint256 decimals
    ) internal view returns (uint256) {
        uint256 price = uint256(1e36);
        price = (price.mul(uint256(sushiOracle.latestAnswer())) / bar.totalSupply()).mul(sushi.balanceOf(address(bar)));

        if (divide != address(0)) {
            price = price / uint256(IAggregator(divide).latestAnswer());
        }

        return price / decimals;
    }

    function getDataParameter(
        address divide,
        uint256 decimals
    ) public pure returns (bytes memory) {
        return abi.encode(divide, decimals);
    }

    // Get the latest exchange rate
    
    function get(bytes calldata data) public override returns (bool, uint256) {
        (address divide, uint256 decimals) = abi.decode(data, (address, uint256));
        return (true, _get(divide, decimals));
    }

    // Check the last exchange rate without any state changes
    
    function peek(bytes calldata data) public view override returns (bool, uint256) {
        (address divide, uint256 decimals) = abi.decode(data, (address, uint256));
        return (true, _get(divide, decimals));
    }

    // Check the current spot exchange rate without any state changes
    
    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {
        (, rate) = peek(data);
    }

    
    function name(bytes calldata) public view override returns (string memory) {
        return "xSUSHI Chainlink";
    }

    
    function symbol(bytes calldata) public view override returns (string memory) {
        return "xSUSHI-LINK";
    }
}