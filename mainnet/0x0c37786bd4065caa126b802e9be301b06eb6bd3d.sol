
/**
 *Submitted for verification at Etherscan.io on 2019-07-11
*/

pragma solidity ^0.4.25;



/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */


/**
 * @title Modifiable
 * @notice A contract with basic modifiers
 */
contract Modifiable {
    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier notNullAddress(address _address) {
        require(_address != address(0));
        _;
    }

    modifier notThisAddress(address _address) {
        require(_address != address(this));
        _;
    }

    modifier notNullOrThisAddress(address _address) {
        require(_address != address(0));
        require(_address != address(this));
        _;
    }

    modifier notSameAddresses(address _address1, address _address2) {
        if (_address1 != _address2)
            _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */



/**
 * @title SelfDestructible
 * @notice Contract that allows for self-destruction
 */
contract SelfDestructible {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    bool public selfDestructionDisabled;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SelfDestructionDisabledEvent(address wallet);
    event TriggerSelfDestructionEvent(address wallet);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    
    function destructor()
    public
    view
    returns (address);

    
    
    function disableSelfDestruction()
    public
    {
        // Require that sender is the assigned destructor
        require(destructor() == msg.sender);

        // Disable self-destruction
        selfDestructionDisabled = true;

        // Emit event
        emit SelfDestructionDisabledEvent(msg.sender);
    }

    
    function triggerSelfDestruction()
    public
    {
        // Require that sender is the assigned destructor
        require(destructor() == msg.sender);

        // Require that self-destruction has not been disabled
        require(!selfDestructionDisabled);

        // Emit event
        emit TriggerSelfDestructionEvent(msg.sender);

        // Self-destruct and reward destructor
        selfdestruct(msg.sender);
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */






/**
 * @title Ownable
 * @notice A modifiable that has ownership roles
 */
contract Ownable is Modifiable, SelfDestructible {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    address public deployer;
    address public operator;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetDeployerEvent(address oldDeployer, address newDeployer);
    event SetOperatorEvent(address oldOperator, address newOperator);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address _deployer) internal notNullOrThisAddress(_deployer) {
        deployer = _deployer;
        operator = _deployer;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    
    function destructor()
    public
    view
    returns (address)
    {
        return deployer;
    }

    
    
    function setDeployer(address newDeployer)
    public
    onlyDeployer
    notNullOrThisAddress(newDeployer)
    {
        if (newDeployer != deployer) {
            // Set new deployer
            address oldDeployer = deployer;
            deployer = newDeployer;

            // Emit event
            emit SetDeployerEvent(oldDeployer, newDeployer);
        }
    }

    
    
    function setOperator(address newOperator)
    public
    onlyOperator
    notNullOrThisAddress(newOperator)
    {
        if (newOperator != operator) {
            // Set new operator
            address oldOperator = operator;
            operator = newOperator;

            // Emit event
            emit SetOperatorEvent(oldOperator, newOperator);
        }
    }

    
    
    function isDeployer()
    internal
    view
    returns (bool)
    {
        return msg.sender == deployer;
    }

    
    
    function isOperator()
    internal
    view
    returns (bool)
    {
        return msg.sender == operator;
    }

    
    /// on the other hand
    
    function isDeployerOrOperator()
    internal
    view
    returns (bool)
    {
        return isDeployer() || isOperator();
    }

    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier onlyDeployer() {
        require(isDeployer());
        _;
    }

    modifier notDeployer() {
        require(!isDeployer());
        _;
    }

    modifier onlyOperator() {
        require(isOperator());
        _;
    }

    modifier notOperator() {
        require(!isOperator());
        _;
    }

    modifier onlyDeployerOrOperator() {
        require(isDeployerOrOperator());
        _;
    }

    modifier notDeployerOrOperator() {
        require(!isDeployerOrOperator());
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */





/**
 * @title Community vote
 * @notice An oracle for relevant decisions made by the community.
 */
contract CommunityVote is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    mapping(address => bool) doubleSpenderByWallet;
    uint256 maxDriipNonce;
    uint256 maxNullNonce;
    bool dataAvailable;

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
        dataAvailable = true;
    }

    //
    // Results functions
    // -----------------------------------------------------------------------------------------------------------------
    
    
    
    function isDoubleSpenderWallet(address wallet)
    public
    view
    returns (bool)
    {
        return doubleSpenderByWallet[wallet];
    }

    
    
    function getMaxDriipNonce()
    public
    view
    returns (uint256)
    {
        return maxDriipNonce;
    }

    
    
    function getMaxNullNonce()
    public
    view
    returns (uint256)
    {
        return maxNullNonce;
    }

    
    
    function isDataAvailable()
    public
    view
    returns (bool)
    {
        return dataAvailable;
    }
}