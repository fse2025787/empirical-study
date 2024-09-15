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

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";








contract AnteOHMv2BackingTest is AnteTest("Olympus OHMv2 fully backed by treasury reserves") {
    IERC20 public ohm;
    IOlympusAuthority public authority;
    address[] public liquidityTokens;
    address[] public reserveTokens;

    
    
    
    /// currently only 0xb612c37688861f1f90761dc7f382c2af3a50cc39)
    
    /// currently 0x853d955acef822db058eb8505911ed77f175b99e and 0x6b175474e89094c44da98b954eedeac495271d0f
    constructor(
        address _authorityAddress,
        address _ohmAddress,
        address[] memory _liquidityTokens,
        address[] memory _reserveTokens
    ) {
        ohm = IERC20(_ohmAddress);
        authority = IOlympusAuthority(_authorityAddress);

        protocolName = "OlympusDAO";
        // treasury reserves being tested but treasury address is read through authority
        // and could change in future
        testedContracts = [_ohmAddress, _authorityAddress, authority.vault()];

        liquidityTokens = _liquidityTokens;
        reserveTokens = _reserveTokens;
    }

    
    
    function olympusVault() public view returns (ITreasury) {
        return ITreasury(authority.vault());
    }

    
    
    function checkTestPasses() external view override returns (bool) {
        uint256 reserves;
        ITreasury treasury = olympusVault();

        for (uint256 i = 0; i < reserveTokens.length; i++) {
            if (treasury.permissions(ITreasury.STATUS.RESERVETOKEN, reserveTokens[i])) {
                reserves += treasury.tokenValue(
                    reserveTokens[i],
                    IERC20(reserveTokens[i]).balanceOf(address(treasury))
                );
            }
        }

        for (uint256 i = 0; i < liquidityTokens.length; i++) {
            if (treasury.permissions(ITreasury.STATUS.LIQUIDITYTOKEN, liquidityTokens[i])) {
                reserves += treasury.tokenValue(
                    liquidityTokens[i],
                    IERC20(liquidityTokens[i]).balanceOf(address(treasury))
                );
            }
        }

        return reserves >= ohm.totalSupply();
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
pragma solidity >=0.7.5;

interface ITreasury {
    enum STATUS {
        RESERVEDEPOSITOR,
        RESERVESPENDER,
        RESERVETOKEN,
        RESERVEMANAGER,
        LIQUIDITYDEPOSITOR,
        LIQUIDITYTOKEN,
        LIQUIDITYMANAGER,
        RESERVEDEBTOR,
        REWARDMANAGER,
        SOHM,
        OHMDEBTOR
    }

    function enable(
        STATUS _status,
        address _address,
        address _calculator
    ) external;

    function registry(STATUS _status, uint256 _index) external view returns (address);

    function permissions(STATUS _status, address _token) external view returns (bool);

    function auditReserves() external;

    function totalReserves() external view returns (uint256);

    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256);

    function withdraw(uint256 _amount, address _token) external;

    function tokenValue(address _token, uint256 _amount) external view returns (uint256 value_);

    function mint(address _recipient, uint256 _amount) external;

    function manage(address _token, uint256 _amount) external;

    function incurDebt(uint256 amount_, address token_) external;

    function repayDebtWithReserve(uint256 amount_, address token_) external;

    function excessReserves() external view returns (uint256);

    function baseSupply() external view returns (uint256);
}

// 
pragma solidity >=0.7.5;

interface IOlympusAuthority {
    /* ========== EVENTS ========== */

    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */

    function governor() external view returns (address);

    function guardian() external view returns (address);

    function policy() external view returns (address);

    function vault() external view returns (address);
}
