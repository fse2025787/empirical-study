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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
pragma solidity ^0.8.4;





contract NFTVaultSetter is Ownable {

    
    
    function setBorrowAmountCap(INFTVault _vault, uint256 _borrowAmountCap)
        external
        onlyOwner
    {
        INFTVault.VaultSettings memory settings = _vault.settings();
        settings.borrowAmountCap = _borrowAmountCap;
        _vault.setSettings(settings);
    }

    
    
    function setDebtInterestApr(INFTVault _vault, INFTVault.Rate calldata _debtInterestApr)
        external
        onlyOwner
    {
        _validateRateBelowOne(_debtInterestApr);
        _vault.accrue();
        INFTVault.VaultSettings memory settings = _vault.settings();
        settings.debtInterestApr = _debtInterestApr;
        _vault.setSettings(settings);
    }

    
    
    function setValueIncreaseLockRate(INFTVault _vault, INFTVault.Rate calldata _valueIncreaseLockRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_valueIncreaseLockRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        settings.valueIncreaseLockRate = _valueIncreaseLockRate;
        _vault.setSettings(settings);
    }

    
    
    function setCreditLimitRate(INFTVault _vault, INFTVault.Rate calldata _creditLimitRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_creditLimitRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        require(
            _greaterThan(settings.liquidationLimitRate, _creditLimitRate),
            "invalid_credit_limit"
        );
        require(
            _greaterThan(settings.cigStakedCreditLimitRate, _creditLimitRate),
            "invalid_credit_limit"
        );

        settings.creditLimitRate = _creditLimitRate;
        _vault.setSettings(settings);
    }

    
    
    function setLiquidationLimitRate(INFTVault _vault, INFTVault.Rate calldata _liquidationLimitRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_liquidationLimitRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        require(
            _greaterThan(_liquidationLimitRate, settings.creditLimitRate),
            "invalid_liquidation_limit"
        );
        require(
            _greaterThan(
                settings.cigStakedLiquidationLimitRate,
                _liquidationLimitRate
            ),
            "invalid_liquidation_limit"
        );

        settings.liquidationLimitRate = _liquidationLimitRate;
        _vault.setSettings(settings);
    }

    
    
    function setStakedCigLiquidationLimitRate(
        INFTVault _vault, INFTVault.Rate calldata _cigLiquidationLimitRate
    ) external onlyOwner {
        _validateRateBelowOne(_cigLiquidationLimitRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        require(
            _greaterThan(
                _cigLiquidationLimitRate,
                settings.cigStakedCreditLimitRate
            ),
            "invalid_cig_liquidation_limit"
        );
        require(
            _greaterThan(
                _cigLiquidationLimitRate,
                settings.liquidationLimitRate
            ),
            "invalid_cig_liquidation_limit"
        );

        settings.cigStakedLiquidationLimitRate = _cigLiquidationLimitRate;
        _vault.setSettings(settings);
    }

    
    
    function setStakedCigCreditLimitRate(INFTVault _vault, INFTVault.Rate calldata _cigCreditLimitRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_cigCreditLimitRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        require(
            _greaterThan(
                settings.cigStakedLiquidationLimitRate,
                _cigCreditLimitRate
            ),
            "invalid_cig_credit_limit"
        );
        require(
            _greaterThan(_cigCreditLimitRate, settings.creditLimitRate),
            "invalid_cig_credit_limit"
        );

        settings.cigStakedCreditLimitRate = _cigCreditLimitRate;
        _vault.setSettings(settings);
    }

    
    
    function setInsuranceRepurchaseTimeLimit(INFTVault _vault, uint256 _newLimit)
        external
        onlyOwner
    {
        require(_newLimit != 0, "invalid_limit");
        INFTVault.VaultSettings memory settings = _vault.settings();
        settings.insuranceRepurchaseTimeLimit = _newLimit;
        _vault.setSettings(settings);
    }

    
    
    function setOrganizationFeeRate(INFTVault _vault, INFTVault.Rate calldata _organizationFeeRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_organizationFeeRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        settings.organizationFeeRate = _organizationFeeRate;
        _vault.setSettings(settings);
    }

    
    
    function setInsurancePurchaseRate(INFTVault _vault, INFTVault.Rate calldata _insurancePurchaseRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_insurancePurchaseRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        settings.insurancePurchaseRate = _insurancePurchaseRate;
        _vault.setSettings(settings);
    }

    
    
    function setInsuranceLiquidationPenaltyRate(
        INFTVault _vault, INFTVault.Rate calldata _insuranceLiquidationPenaltyRate
    ) external onlyOwner {
        _validateRateBelowOne(_insuranceLiquidationPenaltyRate);
        INFTVault.VaultSettings memory settings = _vault.settings();
        settings
            .insuranceLiquidationPenaltyRate = _insuranceLiquidationPenaltyRate;
        _vault.setSettings(settings);
    }

    
    function _greaterThan(INFTVault.Rate memory _r1, INFTVault.Rate memory _r2)
        internal
        pure
        returns (bool)
    {
        return
            _r1.numerator * _r2.denominator > _r2.numerator * _r1.denominator;
    }

    
    
    function _validateRateBelowOne(INFTVault.Rate memory rate) internal pure {
        require(
            rate.denominator != 0 && rate.denominator >= rate.numerator,
            "invalid_rate"
        );
    }

}

// 
pragma solidity ^0.8.4;

interface INFTVault {

    struct Rate {
        uint128 numerator;
        uint128 denominator;
    }

    struct VaultSettings {
        Rate debtInterestApr;
        Rate creditLimitRate;
        Rate liquidationLimitRate;
        Rate cigStakedCreditLimitRate;
        Rate cigStakedLiquidationLimitRate;
        Rate valueIncreaseLockRate;
        Rate organizationFeeRate;
        Rate insurancePurchaseRate;
        Rate insuranceLiquidationPenaltyRate;
        uint256 insuranceRepurchaseTimeLimit;
        uint256 borrowAmountCap;
    }

    function settings() external view returns (VaultSettings memory);

    function accrue() external;

    function setSettings(VaultSettings calldata _settings) external;

}
