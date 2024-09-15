// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 

pragma solidity >=0.8.13;



interface IPriceOracle {
    
    
    function refreshedAssetPerBaseInUQ(address _asset) external returns (uint);

    
    
    function lastAssetPerBaseInUQ(address _asset) external view returns (uint);
}
// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// 

pragma solidity >=0.8.13;





interface IUniswapV2PathPriceOracle is IPriceOracle {
    
    
    
    function anatomy() external view returns (address[] calldata _path, address[] calldata _oracles);
}
// 

pragma solidity 0.8.13;










contract UniswapV2PathPriceOracle is IUniswapV2PathPriceOracle, ERC165 {
    using FullMath for uint;

    
    address[] internal path;
    
    address[] internal oracles;

    constructor(address[] memory _path, address[] memory _oracles) {
        uint pathsCount = _path.length;
        require(pathsCount >= 2, "UniswapV2PathPriceOracle: PATH");
        require(_oracles.length == pathsCount - 1, "UniswapV2PathPriceOracle: ORACLES");

        path = _path;
        oracles = _oracles;
    }

    
    function refreshedAssetPerBaseInUQ(address _asset) external override returns (uint currentAssetPerBaseInUQ) {
        currentAssetPerBaseInUQ = FixedPoint112.Q112;

        uint oraclesCount = oracles.length;
        for (uint i; i < oraclesCount; ) {
            address asset = path[i + 1];
            currentAssetPerBaseInUQ = currentAssetPerBaseInUQ.mulDiv(
                IPriceOracle(oracles[i]).refreshedAssetPerBaseInUQ(asset),
                FixedPoint112.Q112
            );
            if (_asset == asset) {
                break;
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    function anatomy() external view override returns (address[] memory _path, address[] memory _oracles) {
        _path = path;
        _oracles = oracles;
    }

    
    function lastAssetPerBaseInUQ(address _asset) external view override returns (uint currentAssetPerBaseInUQ) {
        currentAssetPerBaseInUQ = FixedPoint112.Q112;

        uint oraclesCount = oracles.length;
        for (uint i; i < oraclesCount; ) {
            address asset = path[i + 1];
            currentAssetPerBaseInUQ = currentAssetPerBaseInUQ.mulDiv(
                IPriceOracle(oracles[i]).lastAssetPerBaseInUQ(asset),
                FixedPoint112.Q112
            );
            if (_asset == asset) {
                break;
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return
            _interfaceId == type(IUniswapV2PathPriceOracle).interfaceId ||
            _interfaceId == type(IPriceOracle).interfaceId ||
            super.supportsInterface(_interfaceId);
    }
}

// 
pragma solidity 0.8.13;




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
            uint256 twos = (~denominator + 1) & denominator;
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

    
    
    
    
    
}

// 

pragma solidity 0.8.13;



library FixedPoint112 {
    uint8 internal constant RESOLUTION = 112;
    
    uint256 internal constant Q112 = 0x10000000000000000000000000000;
}
