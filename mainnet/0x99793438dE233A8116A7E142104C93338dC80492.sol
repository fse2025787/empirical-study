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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

pragma solidity 0.8.10;

// import './StructDeclaration.sol';








contract NFTMarketInfo is ReentrancyGuard, Ownable {
	using SafeMath for uint256;

	uint256 public platformFee;
	address public platformAddress;

	uint256 public DECIMALS;

	uint256 public MAX_FEE = 1500;

	using TokenStructLib for TokenStructLib.TokenInfo;

	mapping(address => bool) public isManager;
	mapping(uint256 => TokenStructLib.TokenInfo) public TokenMarketInfo;
	INFT public nft;

	AggregatorV3Interface public priceFeed;

	constructor(
		address _nft,
		address _platformFeeAddress,
		address _priceFeed,
		uint256 decimals
	) checkAddress(_nft) checkAddress(_platformFeeAddress) checkAddress(_priceFeed) {
		nft = INFT(_nft);
		priceFeed = AggregatorV3Interface(_priceFeed);
		platformFee = 450; // 4.5%
		platformAddress = _platformFeeAddress;
		DECIMALS = decimals;
	}

	modifier onlyManager() {
		require(isManager[msg.sender], 'NFTInfo:access-denied');
		_;
	}

	
	modifier checkAddress(address _contractaddress) {
		require(_contractaddress != address(0), 'Zero address');
		_;
	}

	modifier onlyManagerOrOwner() {
		require(isManager[msg.sender] || owner() == msg.sender, 'NFTInfo:access-denied');
		_;
	}

	
	
	
	function addTokenInfo(TokenStructLib.TokenInfo calldata tokeninfo) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[tokeninfo.tokenId];
		tokenInfo.tokenId = tokeninfo.tokenId;
		tokenInfo.totalSell = tokeninfo.totalSell;
		tokenInfo.minPrice = tokeninfo.minPrice;
		tokenInfo.thirdPartyFee = tokeninfo.thirdPartyFee;
		tokenInfo.galleryOwnerFee = tokeninfo.galleryOwnerFee;
		tokenInfo.artistFee = tokeninfo.artistFee;
		tokenInfo.thirdPartyFeeExpiryTime = tokeninfo.thirdPartyFeeExpiryTime;
		tokenInfo.gallery = tokeninfo.gallery;
		tokenInfo.thirdParty = tokeninfo.thirdParty;
		tokenInfo.nftOwner = tokeninfo.nftOwner;
		tokenInfo.onSell = tokeninfo.onSell;
		tokenInfo.USD = tokeninfo.USD;
		tokenInfo.galleryOwner = tokeninfo.galleryOwner;
		tokenInfo.onAuction = tokeninfo.onAuction;
	}

	
	
	
	
	function updateForSell(
		uint256 _tokenId,
		uint256 _minPrice,
		bool USD
	) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[_tokenId];
		tokenInfo.tokenId = _tokenId;
		tokenInfo.minPrice = _minPrice;
		tokenInfo.USD = USD;
		tokenInfo.onSell = true;
	}

	
	
	
	
	function updateForBuy(uint256 _tokenId, address _owner) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[_tokenId];
		tokenInfo.tokenId = _tokenId;
		tokenInfo.minPrice = 0;
		tokenInfo.totalSell += 1;
		tokenInfo.onSell = false;
		tokenInfo.nftOwner = _owner;
	}

	
	
	
	function updateForCancelSell(uint256 _tokenId) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[_tokenId];
		tokenInfo.minPrice = 0;
		tokenInfo.onSell = false;
		tokenInfo.USD = false;
	}

	
	
	
	
	function updateForAuction(uint256 _tokenId, address _owner) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[_tokenId];
		tokenInfo.minPrice = 0;
		tokenInfo.USD = false;
		tokenInfo.onAuction = false;
		tokenInfo.totalSell += 1;
		tokenInfo.nftOwner = _owner;
	}

	
	
	
	function updateForAuctionCancel(uint256 _tokenId) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[_tokenId];
		tokenInfo.minPrice = 0;
		tokenInfo.USD = false;
		tokenInfo.onAuction = false;
	}

	
	
	
	function getTokenData(uint256 _tokenId)
		public
		view
		returns (
			TokenStructLib.TokenInfo memory tokenInfo // uint256 _minPrice,
		)
	{
		return TokenMarketInfo[_tokenId];
	}

	
	
	
	
	function updateGalleryFee(uint256 _tokenId, uint256 _galleryFee) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[_tokenId];
		tokenInfo.galleryOwnerFee = _galleryFee;
	}

	
	
	
	
	function updateArtistFee(uint256 _tokenId, uint256 _artistFee) public onlyManager {
		TokenStructLib.TokenInfo storage tokenInfo = TokenMarketInfo[_tokenId];
		tokenInfo.galleryOwnerFee = _artistFee;
	}

	function addManagers(address _manager) public onlyOwner {
		isManager[_manager] = true;
	}

	
	
	
	function changeAggregatorAddress(address _newaggregator) public checkAddress(_newaggregator) onlyOwner {
		priceFeed = AggregatorV3Interface(_newaggregator);
	}

	
	
	
	function calculateCommissions(uint256 tokenId)
		public
		view
		returns (
			uint256 _galleryOwnerCommission,
			uint256 artistCommssion,
			uint256 platformCommission,
			uint256 thirdPartyCommission,
			uint256 _remainingAmount,
			address artist
		)
	{
		TokenStructLib.TokenInfo memory tokenmarketInfo = TokenMarketInfo[tokenId];

		uint256 sellingPrice = tokenmarketInfo.minPrice;

		if (tokenmarketInfo.USD) {
			sellingPrice = view_nft_price_native(tokenmarketInfo.minPrice);
		}
		platformCommission = cutPer10000(platformFee, sellingPrice);
		uint256 newSellingPrice = sellingPrice.sub(platformCommission);
		thirdPartyCommission;
		artistCommssion;
		uint256 _rate;
		address receiver;
		artist = receiver;
		(receiver, _rate) = nft.getRoyaltyInfo(uint256(tokenId), newSellingPrice);

		if (tokenmarketInfo.totalSell == 0) {
			artistCommssion = cutPer10000(tokenmarketInfo.artistFee, newSellingPrice);
			_galleryOwnerCommission = cutPer10000(tokenmarketInfo.galleryOwnerFee, newSellingPrice);
			_remainingAmount = newSellingPrice.sub(artistCommssion).sub(_galleryOwnerCommission);
		} else {
			artistCommssion = _rate;
			if (block.timestamp <= tokenmarketInfo.thirdPartyFeeExpiryTime) {
				thirdPartyCommission = cutPer10000(tokenmarketInfo.thirdPartyFee, newSellingPrice);
			} else thirdPartyCommission = 0;

			_remainingAmount = newSellingPrice.sub(_rate).sub(thirdPartyCommission);
		}

		return (
			_galleryOwnerCommission,
			artistCommssion,
			platformCommission,
			thirdPartyCommission,
			_remainingAmount,
			artist
		);
	}

	
	
	
	function changePlatformAddress(address _platform) public onlyOwner checkAddress(_platform) {
		platformAddress = _platform;
	}

	
	
	
	function changePlatformFee(uint256 _amount) public onlyOwner {
		require(_amount < MAX_FEE, 'Exceeded max platformfee');
		platformFee = _amount;
	}

	
	
	
	function getLatestPrice() public view returns (int256) {
		(, int256 price, , , ) = priceFeed.latestRoundData();
		return price;
	}

	
	
	
	
	function view_nft_price_native(uint256 priceindollar) public view returns (uint256) {
		uint8 priceFeedDecimals = priceFeed.decimals();
		uint256 precision = 1 * 10**18;
		uint256 price = uint256(getLatestPrice());
		uint256 requiredWei = (priceindollar * 10**priceFeedDecimals * precision) / price;
		requiredWei = requiredWei / 10**DECIMALS;
		return requiredWei;
	}

	
	
	
	
	
	
	function cutPer10000(uint256 _cut, uint256 _total) internal pure returns (uint256 cutAmount) {
		if (_cut == 0) return 0;
		cutAmount = _total.mul(_cut).div(10000);
		return cutAmount;
	}
}

//

pragma solidity 0.8.10;

library TokenStructLib {
	using TokenStructLib for TokenInfo;

	struct TokenInfo {
		uint256 tokenId;
		uint256 totalSell;
		uint256 minPrice;
		uint256 thirdPartyFee;
		uint256 galleryOwnerFee;
		uint256 artistFee;
		uint256 thirdPartyFeeExpiryTime;
		address payable gallery;
		address payable thirdParty;
		// address payable artist;
		address nftOwner;
		bool onSell;
		bool USD;
		bool onAuction;
		address payable galleryOwner;
	}
}

//

pragma solidity 0.8.10;

interface INFT {
	function mint(string calldata _tokenURI, address _to) external returns (uint256);

	function burn(uint256 _tokenId) external;

	function safeTransferFrom(
		address from,
		address to,
		uint256 tokenId
	) external;

	function ownerOf(uint256 tokenId) external view returns (address);

	function tokenURI(uint256 tokenId) external view returns (string memory);

	function approve(address to, uint256 tokenId) external;

	function setApprovalForAll(address operator, bool approved) external;

	function addManagers(address _manager) external;

	function getRoyaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address reciever, uint256 _rate);

	function setArtistRoyalty(
		uint256 _tokenId,
		address _receiver,
		uint96 _feeNumerator
	) external;

	function checkNft(uint256 _tokenId) external returns (bool);
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}