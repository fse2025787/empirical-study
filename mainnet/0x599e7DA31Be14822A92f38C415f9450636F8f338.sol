// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
pragma solidity ^0.7.4;

interface IPolicyQuote {
    
    
    
    
    
    
    function getQuotePredefined(
        uint256 _durationSeconds,
        uint256 _tokens,
        uint256 _totalCoverTokens,
        uint256 _totalLiquidity,
        bool _safePolicyBook
    ) external view returns (uint256);

    
    
    
    
    
    function getQuote(
        uint256 _durationSeconds,
        uint256 _tokens,
        address _policyBookAddr
    ) external view returns (uint256);
}
// 
pragma solidity ^0.7.4;


uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS;

// 
pragma solidity ^0.7.4;









contract PolicyQuote is IPolicyQuote {
    using Math for uint256;
    using SafeMath for uint256;

    uint256 public constant RISKY_ASSET_THRESHOLD_PERCENTAGE = 80 * PRECISION;

    uint256 public constant MINIMUM_COST_PERCENTAGE = 2 * PRECISION;

    uint256 public constant MINIMUM_INSURANCE_COST = 10 * DECIMALS; // 10 DAI (10 * 10**18)

    uint256 public constant LOW_RISK_MAX_PERCENT_PREMIUM_COST = 10 * PRECISION;
    uint256 public constant LOW_RISK_MAX_PERCENT_PREMIUM_COST_100_UTILIZATION = 50 * PRECISION;

    uint256 public constant HIGH_RISK_MAX_PERCENT_PREMIUM_COST = 25 * PRECISION;
    uint256 public constant HIGH_RISK_MAX_PERCENT_PREMIUM_COST_100_UTILIZATION = 100 * PRECISION;

    function calculateWhenNotRisky(
        uint256 _utilizationRatioPercentage,
        uint256 _maxPercentPremiumCost
    ) private pure returns (uint256) {
        // % CoC = UR*URRp*TMCC
        return
            (_utilizationRatioPercentage.mul(_maxPercentPremiumCost)).div(
                RISKY_ASSET_THRESHOLD_PERCENTAGE
            );
    }

    function calculateWhenIsRisky(
        uint256 _utilizationRatioPercentage,
        uint256 _maxPercentPremiumCost,
        uint256 _maxPercentPremiumCost100Utilization
    ) private pure returns (uint256) {
        // %CoC =  TMCC+(UR-URRp100%-URRp)*(MCC-TMCC)
        uint256 riskyRelation =
            (PRECISION.mul(_utilizationRatioPercentage.sub(RISKY_ASSET_THRESHOLD_PERCENTAGE))).div(
                (PERCENTAGE_100.sub(RISKY_ASSET_THRESHOLD_PERCENTAGE))
            );

        // %CoC =  TMCC+(riskyRelation*(MCC-TMCC))
        return
            _maxPercentPremiumCost.add(
                (
                    riskyRelation.mul(
                        _maxPercentPremiumCost100Utilization.sub(_maxPercentPremiumCost)
                    )
                )
                    .div(PRECISION)
            );
    }

    function getQuotePredefined(
        uint256 _durationSeconds,
        uint256 _tokens,
        uint256 _totalCoverTokens,
        uint256 _totalLiquidity,
        bool _safePolicyBook
    ) external pure override returns (uint256) {
        return
            _getQuote(
                _durationSeconds,
                _tokens,
                _totalCoverTokens,
                _totalLiquidity,
                _safePolicyBook
            );
    }

    function getQuote(
        uint256 _durationSeconds,
        uint256 _tokens,
        address _policyBookAddr
    ) external view override returns (uint256) {
        return
            _getQuote(
                _durationSeconds,
                _tokens,
                IPolicyBook(_policyBookAddr).totalCoverTokens(),
                IPolicyBook(_policyBookAddr).totalLiquidity(),
                IPolicyBook(_policyBookAddr).whitelisted()
            );
    }

    function _getQuote(
        uint256 _durationSeconds,
        uint256 _tokens,
        uint256 _totalCoverTokens,
        uint256 _totalLiquidity,
        bool _safePolicyBook
    ) internal pure returns (uint256) {
        require(
            _durationSeconds > 0 && _durationSeconds <= SECONDS_IN_THE_YEAR,
            "PolicyQuote: Invalid duration"
        );
        require(_tokens > 0, "PolicyQuote: Invalid tokens amount");
        require(
            _totalCoverTokens.add(_tokens) <= _totalLiquidity,
            "PolicyQuote: Requiring more than there exists"
        );

        uint256 utilizationRatioPercentage =
            ((_totalCoverTokens.add(_tokens)).mul(PERCENTAGE_100)).div(_totalLiquidity);

        uint256 annualInsuranceCostPercentage;

        uint256 maxPercentPremiumCost = HIGH_RISK_MAX_PERCENT_PREMIUM_COST;
        uint256 maxPercentPremiumCost100Utilization =
            HIGH_RISK_MAX_PERCENT_PREMIUM_COST_100_UTILIZATION;

        if (_safePolicyBook) {
            maxPercentPremiumCost = LOW_RISK_MAX_PERCENT_PREMIUM_COST;
            maxPercentPremiumCost100Utilization = LOW_RISK_MAX_PERCENT_PREMIUM_COST_100_UTILIZATION;
        }

        if (utilizationRatioPercentage < RISKY_ASSET_THRESHOLD_PERCENTAGE) {
            annualInsuranceCostPercentage = calculateWhenNotRisky(
                utilizationRatioPercentage,
                maxPercentPremiumCost
            );
        } else {
            annualInsuranceCostPercentage = calculateWhenIsRisky(
                utilizationRatioPercentage,
                maxPercentPremiumCost,
                maxPercentPremiumCost100Utilization
            );
        }

        // %CoC  final =max{% Col, MC}
        annualInsuranceCostPercentage = Math.max(
            annualInsuranceCostPercentage,
            MINIMUM_COST_PERCENTAGE
        );

        // $PoC   = the size of the coverage *%CoC  final
        uint256 actualInsuranceCostPercentage =
            (_durationSeconds.mul(annualInsuranceCostPercentage)).div(SECONDS_IN_THE_YEAR);

        return
            Math.max(
                (_tokens.mul(actualInsuranceCostPercentage)).div(PERCENTAGE_100),
                MINIMUM_INSURANCE_COST
            );
    }
}

// 
pragma solidity ^0.7.4;




interface IClaimingRegistry {
    enum ClaimStatus {
        CAN_CLAIM,
        UNCLAIMABLE,
        PENDING,
        AWAITING_CALCULATION,
        REJECTED_CAN_APPEAL,
        REJECTED,
        ACCEPTED
    }

    struct ClaimInfo {
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        uint256 dateSubmitted;
        uint256 dateEnded;
        bool appeal;
        ClaimStatus status;
        uint256 claimAmount;
    }

    
    function anonymousVotingDuration(uint256 index) external view returns (uint256);

    
    function votingDuration(uint256 index) external view returns (uint256);

    
    function anyoneCanCalculateClaimResultAfter(uint256 index) external view returns (uint256);

    
    function canBuyNewPolicy(address buyer, address policyBookAddress)
        external
        view
        returns (bool);

    
    function submitClaim(
        address user,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external returns (uint256);

    
    function claimExists(uint256 index) external view returns (bool);

    
    function claimSubmittedTime(uint256 index) external view returns (uint256);

    
    function claimEndTime(uint256 index) external view returns (uint256);

    
    function isClaimAnonymouslyVotable(uint256 index) external view returns (bool);

    
    function isClaimExposablyVotable(uint256 index) external view returns (bool);

    
    function isClaimVotable(uint256 index) external view returns (bool);

    
    function canClaimBeCalculatedByAnyone(uint256 index) external view returns (bool);

    
    function isClaimPending(uint256 index) external view returns (bool);

    
    function countPolicyClaimerClaims(address user) external view returns (uint256);

    
    function countPendingClaims() external view returns (uint256);

    
    function countClaims() external view returns (uint256);

    
    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        returns (uint256);

    
    function pendingClaimIndexAt(uint256 orderIndex) external view returns (uint256);

    
    function claimIndexAt(uint256 orderIndex) external view returns (uint256);

    
    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        returns (uint256);

    
    function isClaimAppeal(uint256 index) external view returns (bool);

    
    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        returns (ClaimStatus);

    
    function claimStatus(uint256 index) external view returns (ClaimStatus);

    
    function claimOwner(uint256 index) external view returns (address);

    
    function claimPolicyBook(uint256 index) external view returns (address);

    
    function claimInfo(uint256 index) external view returns (ClaimInfo memory _claimInfo);

    
    function acceptClaim(uint256 index) external;

    
    function rejectClaim(uint256 index) external;
}

// 
pragma solidity ^0.7.4;





interface IPolicyBook {
    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct PolicyHolder {
        uint256 coverTokens;
        uint256 startEpochNumber;
        uint256 endEpochNumber;
        uint256 paid;
    }

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    function EPOCH_DURATION() external view returns (uint256);

    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);

    function whitelisted() external view returns (bool);

    function epochStartTime() external view returns (uint256);

    // @TODO: should we let DAO to change contract address?
    
    
    function insuranceContractAddress() external view returns (address _contract);

    
    
    function contractType() external view returns (IPolicyBookFabric.ContractType _type);

    function totalLiquidity() external view returns (uint256);

    function totalCoverTokens() external view returns (uint256);

    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );

    function __PolicyBook_init(
        address _insuranceContract,
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;

    function whitelist(bool _whitelisted) external;

    function getEpoch(uint256 time) external view returns (uint256);

    
    function convertDAIXToDAI(uint256 _amount) external view returns (uint256);

    
    function convertDAIToDAIX(uint256 _amount) external view returns (uint256);

    
    function getClaimApprovalAmount(address user) external view returns (uint256);

    
    function submitClaimAndInitializeVoting(string calldata evidenceURI) external;

    
    function submitAppealAndInitializeVoting(string calldata evidenceURI) external;

    
    function commitClaim(
        address claimer,
        uint256 claimAmount,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external;

    
    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);

    
    function getPolicyPrice(uint256 _epochsNumber, uint256 _coverTokens)
        external
        view
        returns (uint256 totalSeconds, uint256 totalPrice);

    function buyPolicyFor(
        address _buyer,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;

    
    
    
    function buyPolicy(uint256 _durationSeconds, uint256 _coverTokens) external;

    function updateEpochsInfo() external;

    function secondsToEndCurrentEpoch() external view returns (uint256);

    
    
    function addLiquidity(uint256 _liqudityAmount) external;

    
    
    
    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;

    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _bmiDAIxAmount) external;

    function getAvailableDAIXWithdrawableAmount(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw) external;

    function requestWithdrawalWithPermit(
        uint256 _tokensToWithdraw,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function unlockTokens() external;

    
    function withdrawLiquidity() external;

    function getAPY() external view returns (uint256);

    
    function userStats(address _user) external view returns (PolicyHolder memory);

    
    
    
    
    
    
    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _totalDaiLiquidity,
            uint256 _stakedDAI,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiDaiRatio
        );

    
    
    
    
    
    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );
}

// 
pragma solidity ^0.7.4;

interface IPolicyBookFabric {
    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE}

    
    
    
    
    
    
    
    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit
    ) external returns (address);
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
