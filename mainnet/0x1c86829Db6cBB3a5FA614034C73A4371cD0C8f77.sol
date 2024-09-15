// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.0;

abstract contract VotingPowerFormula {
   function convertTokensToVotingPower(uint256 amount) external view virtual returns (uint256);
}
// 
pragma solidity ^0.8.0;



/**
 * @title SushiLPFormula
 * @dev Convert Sushi LP tokens to voting power
 */
contract SushiLPFormula is VotingPowerFormula {

    
    address public owner;

    
    uint32 public conversionRate;

    
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

    
    event ConversionRateChanged(uint32 oldRate, uint32 newRate);

    
    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    /**
     * @notice Construct a new voting power formula contract
     * @param _owner contract owner
     * @param _cvrRate the conversion rate in bips
     */
    constructor(address _owner, uint32 _cvrRate) {
        owner = _owner;
        emit ChangedOwner(address(0), owner);

        conversionRate = _cvrRate;
        emit ConversionRateChanged(uint32(0), conversionRate);
    }

    /**
     * @notice Convert token amount to voting power
     * @param amount token amount
     * @return voting power amount
     */
    function convertTokensToVotingPower(uint256 amount) external view override returns (uint256) {
        return amount * conversionRate / 1000000;
    }

    /**
     * @notice Set conversion rate of contract
     * @param newConversionRate New conversion rate
     */
    function setConversionRate(uint32 newConversionRate) external onlyOwner {
        emit ConversionRateChanged(conversionRate, newConversionRate);
        conversionRate = newConversionRate;
    }

    /**
     * @notice Change owner of contract
     * @param newOwner New owner address
     */
    function changeOwner(address newOwner) external onlyOwner {
        emit ChangedOwner(owner, newOwner);
        owner = newOwner;
    }
}
