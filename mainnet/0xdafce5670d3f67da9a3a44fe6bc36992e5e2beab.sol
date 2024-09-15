// SPDX-License-Identifier: No
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-02-18
*/

// 

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/v612/DELTA/Periphery/DELTA_Limited_Staking_Window.sol







interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address) external returns (uint256);
}

interface IRLP {
  function rebase() external;
  function wrap() external;
  function setBaseLPToken(address) external;
  function openRebasing() external;
  function balanceOf(address) external returns (uint256);
  function transfer(address, uint256) external returns (bool);
}

interface IDELTA_DEEP_FARMING_VAULT {
    function depositFor(address, uint256,uint256) external;
}

interface IRESERVE_VAULT {
    function setRatio(uint256) external;
}

contract DELTA_Limited_Staking_Window {
  using SafeMath for uint256;
  
  struct LiquidityContribution {
    address byWho;
    uint256 howMuchETHUnits;
    uint256 contributionTimestamp;
    uint256 creditsAdded;
  }


  //////////
  // STORAGE
  //////////

  ///////////
  // Unchanging variables and constants 
  

  // Constants
  address constant internal UNISWAP_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  address public DELTA_FINANCIAL_MULTISIG;
  
  // This person has no power over the contract only power to set the multisig wallet
  address immutable public INTERIM_ADMIN;
  IWETH constant public wETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  address public reserveVaultAddress;
  address public deltaDeepFarmingVaultAddress;
  uint256 public LSW_RUN_TIME = 10 days;
  uint256 public constant MAX_ETH_POOL_SEED = 1500 ether;

  // @notice periode after the LSW is ended to claim the LP and the bonuses
  uint256 public constant CLAIMING_PERIOD = 30 days;
  uint256 public constant MAX_TIME_BONUS_PERCENT = 30;

  IRLP public rebasingLP; // Wrapped LP
  address public deltaTokenAddress;

  ///////////

  ///////////
  // Referral handling variables
  

  
  uint256 public totalReferralIDs; 
  
  mapping(uint256 => address) public referralCodeMappingIndexedByID; 
  mapping(address => uint256) public referralCodeMappingIndexedByAddress;
  
  mapping(address => uint256) public referralBonusWETH;
  
  mapping(address => bool) public referralBonusWETHClaimed;
  uint256 public totalWETHEarmarkedForReferrers;

  ///////////


  ///////////
  // Liquidity contribution variables
  

  
  LiquidityContribution [] public liquidityContributionsArray;
  
  mapping(address => uint256) public liquidityContributedInETHUnitsMapping;  
  
  mapping(address => uint256) public liquidityCreditsMapping;
  
  mapping(address => bool) public claimedLP;
  
  
  uint256 public rlpPerCredit;
  
  uint256 public totalCreditValue;
  ///////////


  ///////////
  // Refund handling variables

  
  
  mapping(address => bool) public refundClaimed;
  
  
  bool public refundsOpen;
  ///////////

  ///////////
  // Handling LSW timing variables

  
  bool public liquidityGenerationHasStarted;
  bool public liquidityGenerationHasEnded;
  
  uint256 public liquidityGenerationStartTimestamp;
  uint256 public liquidityGenerationEndTimestamp;
  ///////////



  // constructor is only called by the token contract
  constructor() public {
      INTERIM_ADMIN = msg.sender;
  }


  
  receive() external payable {
    revertBecauseUserDidNotProvideAgreement();
  }

  function setMultisig(address multisig) public {
      onlyInterimAdmin();
    
      require(DELTA_FINANCIAL_MULTISIG == address(0), "only set once");
      DELTA_FINANCIAL_MULTISIG = multisig;
  }

  function onlyInterimAdmin() public view {
      require(INTERIM_ADMIN == msg.sender, "wrong");
  }

  function setReserveVault(address reserveVault) public {
      onlyMultisig();
      reserveVaultAddress = reserveVault;
  }

  /// Helper functions
  function setRLPWrap(address rlpAddress) public {
      onlyMultisig();
      rebasingLP = IRLP(rlpAddress);
  }

  function setDELTAToken(address deltaToken, bool delegateCall) public {
      onlyMultisig();
      if(delegateCall == false) {
        deltaTokenAddress = deltaToken;
      } else {
          bytes memory callData = abi.encodePacked(bytes4(keccak256(bytes("getTokenInfo()"))), "");
        (,bytes memory addressDelta)= deltaToken.delegatecall(callData);
        deltaTokenAddress = abi.decode(addressDelta, (address));
      }
  }

  function setFarmingVaultAddress(address farmingVault) public {
      onlyMultisig();
      deltaDeepFarmingVaultAddress = farmingVault;
      require(address(rebasingLP) != address(0), "Need rlp to be set");
      require(farmingVault != address(0), "Provide an address for farmingVault");
      IERC20(address(rebasingLP)).approve(farmingVault, uint(-1));
  }
  
  function extendLSWEndTime(uint256 numberSeconds) public {
      onlyMultisig();
      liquidityGenerationEndTimestamp = liquidityGenerationEndTimestamp.add(numberSeconds);
      LSW_RUN_TIME = LSW_RUN_TIME.add(numberSeconds);
  }



  
  function startLiquidityGeneration() public {
    onlyMultisig();

    // We check that this is called by the correct authorithy
    
    require(liquidityGenerationHasStarted == false, "startLiquidityGeneration() called when LSW had already started");

    // We start the LSW
    liquidityGenerationHasStarted = true;
    // Informational timestamp only written here
    // All calculations are based on the variable below end timestamp and run time which is used to bonus calculations
    liquidityGenerationStartTimestamp = block.timestamp;
    liquidityGenerationEndTimestamp = liquidityGenerationStartTimestamp + LSW_RUN_TIME;

  }
 
  
  function makeRefCode() public returns (uint256) {
    // If that address already has one, we dont make a new one
    if(referralCodeMappingIndexedByAddress[msg.sender] != 0){
       return referralCodeMappingIndexedByAddress[msg.sender];
     }
     else {
       return _makeRefCode(msg.sender);
     }
  }

  
  function _makeRefCode(address referrer) internal returns (uint256) {
      totalReferralIDs++; // lead to skip 0 code for the LSW 
      // Populate reverse as well for lookup above
      referralCodeMappingIndexedByID[totalReferralIDs] = referrer;
      referralCodeMappingIndexedByAddress[msg.sender] = totalReferralIDs;
      return totalReferralIDs;
  }

  
  function revertBecauseUserDidNotProvideAgreement() internal pure {
    revert("No agreement provided, please review the smart contract before interacting with it");
  }


  function adminEndLSWAndRefundEveryone() public {
    onlyMultisig();
    liquidityGenerationEndTimestamp = 0;
    openRefunds();
  }

  function onlyMultisig() public view {
    require(msg.sender == DELTA_FINANCIAL_MULTISIG, "FBI OPEN UP");
  }


  
  function endLiquidityDeployment() public {
    // Check if it already ended
    require(block.timestamp > liquidityGenerationEndTimestamp.add(5 minutes), "LSW Not over yet."); // Added few blocks here
    // Check if it was already run
    require(liquidityGenerationHasEnded == false, "LSW Already ended");
    require(refundsOpen == false, "Refunds Opened, no ending");

    // Check if all variable addresses are set
    // This includes the delta token
    // Rebasing lp wrap
    // Reserve vault which acts as options plunge insurance and floor price reserve 
    // And operating capital for loans
    // And the farming vault which is used to auto stake in it
    require(deltaTokenAddress != address(0), "Delta Token is not set");
    require(address(rebasingLP) != address(0), "Rlp is not set");
    require(address(reserveVaultAddress) != address(0), "Reserve Vault is not set");
    require(address(deltaDeepFarmingVaultAddress) != address(0), "Deep farming vault isn't set");

    // We wrap the delta token in the interface
    IERC20 deltaToken = IERC20(deltaTokenAddress);
    // Check the balance we have
    // Note : if the process wan't complete correctly, the balance here would be wrong
    // Because DELTA token returns a balanace 
    uint256 balanceOfDELTA = deltaToken.balanceOf(address(this)); 
    // We make sure we for sure have the total supply
    require(balanceOfDELTA == deltaToken.totalSupply(), "Did not get the whole supply of deltaToken");
    /// We mkake sure the supply is equal to the agreed on 45mln
    require(balanceOfDELTA == 45_000_000e18, "Did not get the whole supply of deltaToken");

    // Optimistically get pair
    address deltaWethUniswapPair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(deltaTokenAddress, address(wETH));
    if(deltaWethUniswapPair == address(0)) { // Pair doesn't exist yet 
      // create pair returns address
      deltaWethUniswapPair = IUniswapV2Factory(UNISWAP_FACTORY).createPair(
        deltaTokenAddress,
        address(wETH)
      );
    }

    // Split between DELTA financial and pool
    // intented outcome 50% split between pool and further fund for tokens and WETH
    uint256 balanceWETHPreSplit = wETH.balanceOf(address(this));
    require(balanceWETHPreSplit > 0, "Not enough WETH");
    wETH.transfer(DELTA_FINANCIAL_MULTISIG, balanceWETHPreSplit.div(2)); // send half
    uint256 balanceWETHPostSplit = wETH.balanceOf(address(this)); // requery
    // We remove the WETH we had earmarked for referals
    uint256 balanceWETHPostReferal = balanceWETHPostSplit.sub(totalWETHEarmarkedForReferrers);

    
    /// We just want refunds if that's the case cause it's not worth bothering
    uint256 balanceWETHForReserves = balanceWETHPostReferal.sub(MAX_ETH_POOL_SEED, "Not enough ETH");

    
    /// Anything else is a issue
    /// Note added 1ETH for possible change
    require(totalWETHEarmarkedForReferrers <= balanceWETHPreSplit.div(20).add(1e18), "Sanity check failure 3");
    wETH.transfer(reserveVaultAddress, balanceWETHForReserves);
    // We seed the pool with WETH
    wETH.transfer(deltaWethUniswapPair, MAX_ETH_POOL_SEED);
    require(wETH.balanceOf(address(this)) == totalWETHEarmarkedForReferrers, "Math Error");

    // Transfer DELTA
    
    uint256 deltaForPoolAndReserve = balanceOfDELTA.div(2);
    /// Smaller number / bigger number = float  with 1000 for precision
    uint256 percentOfBalanceToReserves = MAX_ETH_POOL_SEED.mul(1000).div(balanceWETHPostReferal);
    // We take the precision out here
    uint256 delfaForPool = deltaForPoolAndReserve.mul(percentOfBalanceToReserves).div(1000);

    // transfer to pool
    deltaToken.transfer(deltaWethUniswapPair, delfaForPool);
    // We check if we are not sending 10% by mistake not whitelisting this address for whole sends
    // Note we don't check the rest because it should not deviate 
    require(deltaToken.balanceOf(deltaWethUniswapPair) == delfaForPool, "LSW did not get permissions to send directly to balance");
    // Transfer to team vesting
    deltaToken.transfer(DELTA_FINANCIAL_MULTISIG, balanceOfDELTA.div(2));
    // transfer to floor/liqudation insurance reserves
    deltaToken.transfer(reserveVaultAddress, deltaToken.balanceOf(address(this))); // queried again in case of rounding problems
    
    /// This ratio is set as how much 1 whole eth buys
    /// Since eth is 1e18 and delta is same we can do this here
    /// Note that we don't expect 45mln eth so we dont really lose precision (delta supply is 45mln)
    IRESERVE_VAULT(reserveVaultAddress).setRatio(
        delfaForPool.div(MAX_ETH_POOL_SEED)
    );

    // just wrapping in the interface
    IUniswapV2Pair newPair = IUniswapV2Pair(deltaWethUniswapPair);
    // Add liquidity
    newPair.mint(address(this)); //transfer LP here
    // WE approve the rlp to spend because thats what the wrap function uses (transferFor)
    newPair.approve(address(rebasingLP), uint(-1));

    // We set the base token in a whitelist for rLP for LSW
    rebasingLP.setBaseLPToken(address(newPair));

    
    /// This switch is 1:1 1LP for 1 rebasingLP
    rebasingLP.wrap();

    // Rebase liquidity 
    
    /// So it just triggers a boolean flag to rebase and then trading is opened.
    
    /// Until its called that amount of times trading or transfering of DELTA token will not be opened. 
    /// This is done so price of RLP will be 3x that it was minted at instantly. Also will generate about 30bln in volume
    rebasingLP.openRebasing();
    // Split LP per Credit
    uint256 totalRLP = rebasingLP.balanceOf(address(this));
    require(totalRLP > 0, "Sanity check failure 1");
    // We store as 1e12 more for change
    rlpPerCredit = totalRLP.mul(1e12).div(totalCreditValue);
    require(rlpPerCredit > 0, "Sanity check failure 2");

    // Finalize to open claims (claimLP and ETH claiming for referal)
    liquidityGenerationHasEnded = true;
  }

  function claimOrStakeAndClaimLP(bool claimToWalletInstead) public {
    // Make sure the LSW ended ( this is set in fn endLiquidityDeployment() only)
    // And is only set when all checks have passed and we good
    require(liquidityGenerationHasEnded, "Liquidity Generation isn't over");

    // Make sure the claiming period isn't over
    // Note that we hav ea claiming period here so rLP doesnt get stuck or ETH doesnt get stuck in thsi contract
    // This is because of the referal system having wrong addresses in it possibly
    require(block.timestamp < liquidityGenerationEndTimestamp.add(CLAIMING_PERIOD), "Claiming period is over");
  
    // Make sure the person has something to claim
    require(liquidityContributedInETHUnitsMapping[msg.sender] > 0, "You have nothing to claim.");
    // Make sure the person hasnt already claimed
    require(claimedLP[msg.sender] == false, "You have already claimed.");
    // Set the already claimed flag
    claimedLP[msg.sender] = true;

    // We calculate the amount of rebasing LP due
    uint256 rlpDue = liquidityCreditsMapping[msg.sender].mul(rlpPerCredit).div(1e12);
    // And send it out
    // We check if the person wants to claim to the wallet, the default is to stake it for him in the vault
    if(claimToWalletInstead) {
        rebasingLP.transfer(msg.sender, rlpDue);
    }
    else {
        IDELTA_DEEP_FARMING_VAULT(deltaDeepFarmingVaultAddress).depositFor(msg.sender,rlpDue,0);
    }
  }



  
  /// Note this might suffer from gas limits on infura if there are enogh deposits and we are aware of that
  /// Its just a nice helper function that is not nessesary
  function allLiquidityContributionsOfAnAddress(address person) public view returns (LiquidityContribution  [] memory liquidityContributionsOfPerson) {

    uint256 j; // Index of the memory array

    
    for(uint256 i = 0; i < liquidityContributionsArray.length; i++) {
      LiquidityContribution memory currentContribution = liquidityContributionsArray[i];
      if(currentContribution.byWho == person) {
        liquidityContributionsOfPerson[j] = currentContribution;
        j++;
      }
    }
  }


  
  function getWETHBonusForReferrals() public {
    require(liquidityGenerationHasEnded == true, "LSW Not ended");

    // Make sure the claiming period isn't over
    // This is done in case ETH is stuck with malformed addresses
    require(block.timestamp < liquidityGenerationEndTimestamp.add(CLAIMING_PERIOD), "Claiming period is over");
    require(referralBonusWETHClaimed[msg.sender] == false, "Already claimed, check wETH balance not ETH");
    require(referralBonusWETH[msg.sender] > 0, "nothing to claim");
    
    /// Note that even if reentry was possible here we set it first before sending out weth
    referralBonusWETHClaimed[msg.sender] = true;
    
    wETH.transfer(msg.sender, referralBonusWETH[msg.sender]); 
  }

  
  /// This is done after the claiming period is over in case there are malformed not claimed referal amounts 
  function finalizeLSW(address _token) public {
    onlyMultisig();

    require(liquidityGenerationHasEnded == true, "LSW Not ended");
    require(block.timestamp >= liquidityGenerationEndTimestamp.add(CLAIMING_PERIOD), "Claiming period is not over");
    
    IERC20 token = IERC20(_token);

    
    /// unclaimed or transferred to the contract.
    token.transfer(DELTA_FINANCIAL_MULTISIG, token.balanceOf(address(this)));
  }

  
  /// This is a nessesary function because of the contrract not having admin controls
  /// And is only here as a safety pillow failure
  function getRefund() public {
    require(refundsOpen, "Refunds are not open");
    require(refundClaimed[msg.sender]  == false, "Already got a refund, check your wETH balance.");
    refundClaimed[msg.sender] = true;

    // We send wETH9 here so there is no callback
    wETH.transfer(msg.sender, liquidityContributedInETHUnitsMapping[msg.sender]);
  }

  // This function opens refunds,  if LSW didnt finish 2 days after it was supposed to. This means something went wrong.
  function openRefunds() public {

    require(liquidityGenerationHasEnded == false, "Liquidity generation has ended"); // We correctly ended the LSW
    require(liquidityGenerationHasStarted == true, "Liquidity generation has not started");
    // Liquidity genertion should had ended 2 days ago!
    require(block.timestamp > liquidityGenerationEndTimestamp.add(2 days), "Post LSW grace period isn't over");
    /// This can be set over and over again with no issue here
    refundsOpen = true;

  }


  
  
  function handleReferredDepositWithAddress(address referrerAddress) internal returns (uint256) {

    if(referrerAddress == msg.sender)  { return 0; } //We dont let self referrals and bail here without any bonuses.

    require(msg.value > 0, "Sanity check failure");
    uint256 wETHBonus = msg.value.div(20); // 5%
    uint256 creditBonus = wETHBonus; // Samesies
    totalWETHEarmarkedForReferrers = totalWETHEarmarkedForReferrers.add(wETHBonus);
    require(wETHBonus > 0 && creditBonus > 0 , "Sanity check failure 2");

    // We give 5% wETH of the deposit to the person
    referralBonusWETH[referrerAddress] = referralBonusWETH[referrerAddress].add(wETHBonus);

    //We add credit
    liquidityCreditsMapping[referrerAddress] = liquidityCreditsMapping[referrerAddress].add(creditBonus);
    // Update total credits
    totalCreditValue = totalCreditValue.add(creditBonus);
    
    // We return 10% bonus for the person who was refered
    return creditBonus.mul(2);
  }

  
  function handleReferredDepositWithReferralID(uint256 referralID) internal returns (uint256 personWhoGotReferedBonus) {
    address referrerAddress = referralCodeMappingIndexedByID[referralID];
    // We check if the referral number was registered, and if its not the same person.
    if(referrerAddress != address(0) && referrerAddress != msg.sender) {
      return handleReferredDepositWithAddress(referrerAddress);
    } else {
      return 0;
    }
  }

  function secondsLeftInLiquidityGenerationEvent() public view returns ( uint256 ) {

    if(block.timestamp >= liquidityGenerationEndTimestamp) { return 0; }
    return liquidityGenerationEndTimestamp - block.timestamp;

  }

  function liquidityGenerationParticipationAgreement() public pure returns (string memory) {
    return "I understand that I'm interacting with a smart contract. I understand that liquidity im providing is locked forever. I reviewed code of the smart contract and understand it fully. I agree to not hold developers or other people associated with the project to liable for any losses of misunderstandings";
  }

  // referrerAddress or referralID must be provided, the unused parameter should be left as 0
  function contributeLiquidity(bool readAndAgreedToLiquidityProviderAgreement, address referrerAddress, uint256 referralID) public payable {
    require(refundsOpen == false, "Refunds Opened, no deposit");
    // We check that LSW has already started
    require(liquidityGenerationHasStarted, "Liquidity generation did not start");
    // We check if liquidity generation didn't end
    require(liquidityGenerationHasEnded == false, "Liquidity generation has ended");
    // We check if liquidity genration still has time in it
    require(secondsLeftInLiquidityGenerationEvent() > 0, "Liquidity generation has ended 2");
    // We check if user agreed with the terms of the smart contract
    if(readAndAgreedToLiquidityProviderAgreement == false) {
      revertBecauseUserDidNotProvideAgreement();
    }
    require(msg.value > 0, "Ethereum needs to be provided");

    // We add credit bonus, which is 10% if user is referred
    // RefID takes precedence here
    uint256 creditBonus;
    if(referralID != 0) {
      creditBonus = handleReferredDepositWithReferralID(referralID); // TO REVIEW: handleReferredDepositWithReferralID returns the reward (referrer and referee)
    } else if (referrerAddress != address(0)){
      creditBonus = handleReferredDepositWithAddress(referrerAddress); // TO REVIEW: handleReferredDepositWithReferralID returns the reward (referrer and referee)
    } // Else bonus is 0

    // We add the time bonus to the credit 
    creditBonus = creditBonus.add(calculateCreditBonusBasedOnCurrentTime(msg.value));

    // Credit bonus should never be bigger than credit here. Max 30% + 10%. Aka 40% of msg.value
    // Note this is a magic number here, since we dont really want to read the max bonus again from storage
    require(msg.value.mul(41).div(100) > creditBonus, "Sanity check failure");

    // We update the global number of credit so we can distribute LP later
    uint256 creditValue = msg.value.add(creditBonus);
    totalCreditValue = totalCreditValue.add(creditValue);

    // Give the person credit and the bonus
    liquidityCreditsMapping[msg.sender] = liquidityCreditsMapping[msg.sender].add(creditValue);
    // Save the persons deposit for refunds in case
    liquidityContributedInETHUnitsMapping[msg.sender] = liquidityContributedInETHUnitsMapping[msg.sender].add(msg.value);

    // We add it to array of all deposits
    liquidityContributionsArray.push(LiquidityContribution({
      byWho : msg.sender,
      howMuchETHUnits : msg.value,
      contributionTimestamp : block.timestamp,
      creditsAdded : creditValue // Stores the deposit + the bonus
    }));

    // We turn ETH into WETH9
    wETH.deposit{value : msg.value}();
  }

  
  // At the start of LSW is 30%, ramping down to 0% in the last 12 hours of LSW.
  function calculateCreditBonusBasedOnCurrentTime(uint256 depositValue) internal view returns (uint256) {
    uint256 secondsLeft = secondsLeftInLiquidityGenerationEvent();
    uint256 totalSeconds = LSW_RUN_TIME;

    // We get percent left in the LSW
    uint256 percentLeft = secondsLeft.mul(100).div(totalSeconds); // 24 hours before LSW end, we get 7 for percentLeft - highest value for this possible is 100 (by a bot)

    // We calculate bonus based on percent left. Eg 100% of the time remaining, means a 30% bonus. 50% of the time remaining, means a 15% bonus.
    // MAX_TIME_BONUS_PERCENT is a constant set to 30 (double-check on review)
    // Max example with 1 ETH contribute: 30 * 100 * 1eth / 10000 = 0.3eth
    // Low end (towards the end of LSW) > 0 example MAX_TIME_BONUS_PERCENT == 7;
      // 30 * 7 * 1eth / 10000 = 0.021 eth
    // Min example MAX_TIME_BONUS_PERCENT == 0; returns 0
    /// 100 % bonus
    /// 30*100*1e18/10000 == 0.3 * 1e18
    /// Dust numbers
    /// 30*100*1/10000 == 0
    uint256 bonus = MAX_TIME_BONUS_PERCENT.mul(percentLeft).mul(depositValue).div(10000);
    require(depositValue.mul(31).div(100) > bonus , "Sanity check failure bonus");
    return bonus;
  }

}