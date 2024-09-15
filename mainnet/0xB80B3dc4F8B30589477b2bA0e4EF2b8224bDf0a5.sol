
/**
 *Submitted for verification at Etherscan.io on 2022-03-11
*/

pragma solidity ^0.8.4;

interface IPCVDepositBalances {
    // ----------- Getters -----------
    
    
    function balance() external view returns (uint256);

    
    function balanceReportedIn() external view returns (address);

    
    function resistantBalanceAndFei() external view returns (uint256, uint256);
}

/**
  @notice a lightweight contract to wrap old PCV deposits to use the new interface 
  @author Fei Protocol
  When upgrading the PCVDeposit interface, there are many old contracts which do not support it.
  The main use case for the new interface is to add read methods for the Collateralization Oracle.
  Most PCVDeposits resistant balance method is simply returning the balance as a pass-through
  If the PCVDeposit holds FEI it may be considered as protocol FEI

  This wrapper can be used in the CR oracle which reduces the number of contract upgrades and reduces the complexity and risk of the upgrade
*/
contract PCVDepositWrapper is IPCVDepositBalances {
   
    
    IPCVDepositBalances public immutable pcvDeposit;

    
    address public immutable token;

    
    bool public immutable isProtocolFeiDeposit;

    address public constant fei = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;

    constructor(IPCVDepositBalances _pcvDeposit) {
        pcvDeposit = _pcvDeposit;
        token = _pcvDeposit.balanceReportedIn();
        isProtocolFeiDeposit = token == fei;
    }

    
    function balance() public view override returns (uint256) {
        return pcvDeposit.balance();
    }

    
    function resistantBalanceAndFei() public view override returns (uint256, uint256) {
        uint256 resistantBalance = balance();
        uint256 reistantFei = isProtocolFeiDeposit ? resistantBalance : 0;
        return (resistantBalance, reistantFei);
    }

    
    function balanceReportedIn() public view override returns (address) {
        return token;
    }
}