// SPDX-License-Identifier: GPL-3.0-only


// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity >=0.7.0;



interface IAnteTest {
    
    
    
    function testAuthor() external view returns (address);

    
    
    
    function protocolName() external view returns (string memory);

    
    
    
    
    function testedContracts(uint256 i) external view returns (address);

    
    
    
    function testName() external view returns (string memory);

    
    
    
    function checkTestPasses() external returns (bool);
}
// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity >=0.7.0;






abstract contract AnteTest is IAnteTest {
    
    address public override testAuthor;
    
    string public override testName;
    
    string public override protocolName;
    
    address[] public override testedContracts;

    
    /// be set in the constructor of your AnteTest
    
    constructor(string memory _testName) {
        testAuthor = msg.sender;
        testName = _testName;
    }

    
    
    function getTestedContracts() external view returns (address[] memory) {
        return testedContracts;
    }

    
    function checkTestPasses() external virtual override returns (bool) {}
}
// 

pragma solidity >=0.8.0;






// Ante Test that the top 5 assets do not get rugged. (lose 90% of value.)
contract AnteMultichainBridgeRugTest is AnteTest("Top 5 assets do not lose 90% value.") {
    // Externally Owned Account - https://etherscan.io/address/0x13B432914A996b0A48695dF9B2d701edA45FF264
    address public constant eoaAnyswapBSCBridgeAddr = 0x13B432914A996b0A48695dF9B2d701edA45FF264;

    // Selecting the top 4 ERC-20 Tokens + ETH on Anyway Bridge

    //TRVL - https://etherscan.io/address/0xd47bDF574B4F76210ed503e0EFe81B58Aa061F3d
    address public constant trvlAddr = 0xd47bDF574B4F76210ed503e0EFe81B58Aa061F3d;

    //Super - https://etherscan.io/address/0xe53EC727dbDEB9E2d5456c3be40cFF031AB40A55
    address public constant superAddr = 0xe53EC727dbDEB9E2d5456c3be40cFF031AB40A55;

    //mtlx - https://etherscan.io/address/0x2e1E15C44Ffe4Df6a0cb7371CD00d5028e571d14
    address public constant mtlxAddr = 0x2e1E15C44Ffe4Df6a0cb7371CD00d5028e571d14;

    //TetherUSD - https://etherscan.io/address/0xdAC17F958D2ee523a2206206994597C13D831ec7
    address public constant tetherAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    IERC20 public trvlToken;
    IERC20 public superToken;
    IERC20 public mtlxToken;
    IERC20 public tetherToken;

    uint256 public immutable trvlBalanceAtDeploy;
    uint256 public immutable superBalanceAtDeploly;
    uint256 public immutable mtlxBalanceAtDeploy;
    uint256 public immutable tetherBalanceAtDeploy;
    uint256 public immutable ethBalanceAtDeploy;

    constructor() {
        protocolName = "Anyswap: BSC Bridge";
        testedContracts = [eoaAnyswapBSCBridgeAddr];

        trvlToken = IERC20(trvlAddr);
        superToken = IERC20(superAddr);
        mtlxToken = IERC20(mtlxAddr);
        tetherToken = IERC20(tetherAddr);

        trvlBalanceAtDeploy = trvlToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        superBalanceAtDeploly = superToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        mtlxBalanceAtDeploy = mtlxToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        tetherBalanceAtDeploy = tetherToken.balanceOf(eoaAnyswapBSCBridgeAddr);
        ethBalanceAtDeploy = address(eoaAnyswapBSCBridgeAddr).balance;
    }

    function checkTestPasses() public view override returns (bool) {
        return
            trvlBalanceAtDeploy <= trvlToken.balanceOf(eoaAnyswapBSCBridgeAddr) * 10 &&
            superBalanceAtDeploly <= superToken.balanceOf(eoaAnyswapBSCBridgeAddr) * 10 &&
            mtlxBalanceAtDeploy <= mtlxToken.balanceOf(eoaAnyswapBSCBridgeAddr) * 10 &&
            tetherBalanceAtDeploy <= tetherToken.balanceOf(eoaAnyswapBSCBridgeAddr) * 10 &&
            ethBalanceAtDeploy <= address(eoaAnyswapBSCBridgeAddr).balance * 10;
    }
}

// 

pragma solidity >=0.6.0 <0.9.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Return decimals of token
     */
    function decimals() external view returns (uint8);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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
