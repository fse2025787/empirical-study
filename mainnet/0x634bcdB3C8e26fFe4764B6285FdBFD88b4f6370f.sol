// SPDX-License-Identifier: MIT

// 
pragma solidity 0.8.10;

contract BaseMath {

    
    uint256 constant internal DECIMAL_PRECISION = 1e18;

    
    uint256 constant internal ACR_DECIMAL_PRECISION = 1e4;

}

// 
pragma solidity =0.8.10;



contract DSAuthEvents {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

// 
pragma solidity 0.8.10;





contract LiquityMath is BaseMath {

    // Maximum protocol fee as defined in the Liquity contracts
    // https://github.com/liquity/dev/blob/cb583ddf5e7de6010e196cfe706bd0ca816ea40e/packages/contracts/contracts/TroveManager.sol#L48
    uint256 internal constant LIQUITY_PROTOCOL_MAX_BORROWING_FEE = DECIMAL_PRECISION / 100 * 5; // 5%

    // Amount of LUSD to be locked in Liquity's gas pool on opening troves
    // https://github.com/liquity/dev/blob/cb583ddf5e7de6010e196cfe706bd0ca816ea40e/packages/contracts/contracts/TroveManager.sol#L334
    uint256 internal constant LIQUITY_LUSD_GAS_COMPENSATION = 200e18;

	
    
    
    
    /* solhint-disable-next-line var-name-mixedcase */
    function calcNeededLiquityLUSDAmount(uint256 _LUSDRequestedAmount, uint256 _expectedLiquityProtocolRate, uint16 _adoptionContributionRate) internal pure returns (
        uint256 neededLiquityLUSDAmount
    ) {

        // Normalise ACR 1e4 -> 1e18
        uint256 acr = DECIMAL_PRECISION / ACR_DECIMAL_PRECISION * _adoptionContributionRate;

        // Apply Liquity protocol rate when ACR is lower
        acr = acr < _expectedLiquityProtocolRate ? _expectedLiquityProtocolRate : acr;

        // Includes requested debt and adoption contribution which covers also liquity protocol fee
        uint256 expectedDebtToRepay = _LUSDRequestedAmount * acr / DECIMAL_PRECISION + _LUSDRequestedAmount;

        // = x / ( 1 + fee rate<0.005 - 0.05> )
        neededLiquityLUSDAmount = DECIMAL_PRECISION * expectedDebtToRepay / ( DECIMAL_PRECISION + _expectedLiquityProtocolRate ); 

        require(neededLiquityLUSDAmount >= _LUSDRequestedAmount, "Cannot mint less than requested.");
    }

    
    
    
    function applyRccarOnAcr(uint16 _rccar, uint16 _adoptionContributionRate) internal pure returns (
        uint16 adjustedAcr
    ) {
        return (_adoptionContributionRate > _rccar ? _adoptionContributionRate - _rccar : 0);
    }
}

// 
// Adapted from OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)
// Using less gas and initiating the first owner to the provided multisig address

pragma solidity ^0.8.10;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one provided during the deployment of the contract. 
 * This can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {

    /**
     * @dev Address of the current owner. 
     */
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @param _firstOwner Initial owner
     * @dev Initializes the contract setting the initial owner.
     */
    constructor(address _firstOwner) {
        _transferOwnership(_firstOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
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
    function transferOwnership(address _newOwner) public virtual onlyOwner {
        require(_newOwner != address(0), "Ownable: cannot be zero address");
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address _newOwner) internal virtual {
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }
}

// 
pragma solidity 0.8.10;

contract SqrtMath {

    
    
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    
    
    // source: https://github.com/paulrberg/prb-math/blob/86c068e21f9ba229025a77b951bd3c4c4cf103da/contracts/PRBMath.sol#L591
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Set the initial guess to the least power of two that is greater than or equal to sqrt(x).
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }

}

abstract contract DSAuth is DSAuthEvents {
    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public virtual;

    function setAuthority(DSAuthority authority_) public virtual;

    function isAuthorized(address src, bytes4 sig) internal view virtual returns (bool);
}

// 

pragma solidity =0.8.10;



/** @dev Use like this:
*
* bytes32 internal constant CENTRAL_LOGGER_ID = keccak256("CentralLogger");
* CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
*
* Or directly:
*   CentralLogger logger = CentralLogger(0xDEPLOYEDADDRESS);
*
* logger.log(
*            address(this),
*            msg.sender,
*            "myGreatFunction",
*            abi.encode(msg.value, param1, param2)
*        );
*
* DO NOT USE delegateCall as it defies the centralisation purpose of this logger.
*/
contract CentralLogger {

    event LogEvent(
        address indexed contractAddress,
        address indexed caller,
        string indexed logName,
        bytes data
    );

	/* solhint-disable no-empty-blocks */
	constructor() {
	}

    
    
    
    function log(
        address _contract,
        address _caller,
        string memory _logName,
        bytes memory _data
    ) public {
        emit LogEvent(_contract, _caller, _logName, _data);
    }
}

// 
pragma solidity =0.8.10;



contract CommunityAcknowledgement is Ownable {

	
	
	mapping (bytes32 => uint16) public rccar;

	
	
	
	
	event ContributorRecognised(bytes32 indexed contributor, uint16 indexed previousAcknowledgementRate, uint16 indexed newAcknowledgementRate);

	/* solhint-disable-next-line no-empty-blocks */
	constructor(address _adoptionDAOAddress) Ownable(_adoptionDAOAddress) {

	}

	
	
	
	function getAcknowledgementRate(bytes32 _contributor) external view returns (uint16) {
		return rccar[_contributor];
	}

	
	
	function senderAcknowledgementRate() external view returns (uint16) {
		return rccar[keccak256(abi.encodePacked(msg.sender))];
	}

	
	
	
	
	
	function recogniseContributor(bytes32 _contributor, uint16 _acknowledgementRate) public onlyOwner {
		uint16 _previousAcknowledgementRate = rccar[_contributor];
		rccar[_contributor] = _acknowledgementRate;
		emit ContributorRecognised(_contributor, _previousAcknowledgementRate, _acknowledgementRate);
	}

	
	
	
	
	
	function batchRecogniseContributor(bytes32[] calldata _contributors, uint16[] calldata _acknowledgementRates) external onlyOwner {
		require(_contributors.length == _acknowledgementRates.length, "Lists do not match in length");

		for (uint256 i = 0; i < _contributors.length; i++) {
			recogniseContributor(_contributors[i], _acknowledgementRates[i]);
		}
	}

}

// 
pragma solidity =0.8.10;





contract Config is Ownable {

	
	
	
	uint16 public adoptionContributionRate;

	
	address payable public adoptionDAOAddress;

	
	
	
	
	event ACRChanged(address indexed caller, uint16 previousACR, uint16 newACR);

	
	
	
	
	event AdoptionDAOAddressChanged(address indexed caller, address previousAdoptionDAOAddress, address newAdoptionDAOAddress);

	/* solhint-disable-next-line func-visibility */
	constructor(address payable _adoptionDAOAddress, uint16 _initialACR) Ownable(_adoptionDAOAddress) {
		adoptionContributionRate = _initialACR;
		adoptionDAOAddress = _adoptionDAOAddress;
	}


	
	
	
	
	function setAdoptionContributionRate(uint16 _newACR) external onlyOwner {
		uint16 _previousACR = adoptionContributionRate;
		adoptionContributionRate = _newACR;
		emit ACRChanged(msg.sender, _previousACR, _newACR);
	}

	
	
	
	function setAdoptionDAOAddress(address payable _newAdoptionDAOAddress) external onlyOwner {
		address payable _previousAdoptionDAOAddress = adoptionDAOAddress;
		adoptionDAOAddress = _newAdoptionDAOAddress;
		emit AdoptionDAOAddressChanged(msg.sender, _previousAdoptionDAOAddress, _newAdoptionDAOAddress);
	}

}

// 
pragma solidity =0.8.10;





contract Registry is Ownable {

	
	
	mapping (bytes32 => address) public addresses;

	
	
	
	
	event AddressRegistered(bytes32 indexed id, address indexed previousAddress, address indexed newAddress);

	/* solhint-disable-next-line no-empty-blocks */
	constructor(address _initialOwner) Ownable(_initialOwner) {

	}


	
	
	
	function getAddress(bytes32 _id) external view returns(address) {
		return addresses[_id];
	}


	
	
	
	
	
	function registerAddress(bytes32 _id, address _address) public onlyOwner {
		require(_address != address(0), "Can't register 0x0 address");
		address _previousAddress = addresses[_id];
		addresses[_id] = _address;
		emit AddressRegistered(_id, _previousAddress, _address);
	}

	
	
	
	
	
	function batchRegisterAddresses(bytes32[] calldata _ids, address[] calldata _addresses) external onlyOwner {
		require(_ids.length == _addresses.length, "Lists do not match in length");

		for (uint256 i = 0; i < _ids.length; i++) {
			registerAddress(_ids[i], _addresses[i]);
		}
	}
}

// 
pragma solidity =0.8.10;

















/// and to chain common sequence of transactions thus saving gas.

contract Stargate is LiquityMath, SqrtMath {

	/* solhint-disable var-name-mixedcase */

	
	bytes32 private constant EXECUTOR_ID = keccak256("Executor");
	bytes32 private constant CONFIG_ID = keccak256("Config");
	bytes32 private constant AUTHORITY_ID = keccak256("Authority");
	bytes32 private constant COMMUNITY_ACKNOWLEDGEMENT_ID = keccak256("CommunityAcknowledgement");
	bytes32 private constant CENTRAL_LOGGER_ID = keccak256("CentralLogger");

	
	address public immutable registry;

	// MakerDAO's deployed contracts - Proxy Factory
	// see https://changelog.makerdao.com/
	DSProxyFactory public immutable ProxyFactory;

	// L1 Liquity deployed contracts addresses
	// see https://docs.liquity.org/documentation/resources#contract-addresses
	ITroveManager public immutable TroveManager;
	IHintHelpers public immutable HintHelpers;
	ISortedTroves public immutable SortedTroves;
	ICollSurplusPool public immutable CollSurplusPool;


	
	/// Corresponding event is also raised on the Central Logger
	event SmartAccountCreated(
		address indexed owner,
		address indexed smartAccountAddress
	);


	
	
	modifier onlyProxyOwner(address payable _proxy) {
		require(DSProxy(_proxy).owner() == msg.sender, "Sender has to be proxy owner");
		_;
	}

	/* solhint-disable-next-line func-visibility */
	constructor(
		address _registry,
		address _troveManager,
		address _hintHelpers,
		address _sortedTroves,
		address _collSurplusPool,
		address _proxyFactory
	) {
		registry = _registry;
		TroveManager = ITroveManager(_troveManager);
		HintHelpers = IHintHelpers(_hintHelpers);
		SortedTroves = ISortedTroves(_sortedTroves);
		CollSurplusPool = ICollSurplusPool(_collSurplusPool);
		ProxyFactory = DSProxyFactory(_proxyFactory);
	}

	
	
	
	
	
	function _execute(address payable _proxy, uint256 _value, bytes memory _data) internal onlyProxyOwner(_proxy) {
		DSProxy(_proxy).execute{ value: _value }(Registry(registry).getAddress(EXECUTOR_ID), _data);
	}

	
	/** 
	 * @dev Proxy delegates call to executor address which is obtained from registry contract
	 *
	 * This is the DANGEROUS version as it enables the proxy call to be performed by anyone!
	 *
	 * However suitable for cases when user wants to provide ETH from other (proxy non-owning) accounts.
	 */
	
	
	
	function _executeByAnyone(address payable _proxy, uint256 _value, bytes memory _data) internal {
		DSProxy(_proxy).execute{ value: _value }(Registry(registry).getAddress(EXECUTOR_ID), _data);
	}

	// Stargate MUST NOT be able to receive ETH from sender to itself
	// in 0.8.x function() is split to receive() and fallback(); if both are undefined -> tx reverts

	// ------------------------------------------ User functions ------------------------------------------


	
	/// It is cheaper to open Smart Account while opening Credit Line wihin 1 transaction.
	function openSmartAccount() external {
		_openSmartAccount();
	}

	
	function _openSmartAccount() internal returns (address payable) {
	
		// Deploy a new MakerDAO's proxy onto blockchain
		DSProxy smartAccount = ProxyFactory.build();

		// Enable Stargate's user functions to call the Smart Account	
		DSAuthority stargateAuthority = DSAuthority(Registry(registry).getAddress(AUTHORITY_ID));
		smartAccount.setAuthority(stargateAuthority); 

		// Set owner of MakerDAO's proxy aka Smart Account to be the user
		smartAccount.setOwner(msg.sender);

		// Emit centraly at this contract and the Central Logger
		emit SmartAccountCreated(msg.sender, address(smartAccount));
		CentralLogger logger = CentralLogger(Registry(registry).getAddress(CENTRAL_LOGGER_ID));
		logger.log(
			address(this), msg.sender, "openSmartAccount", abi.encode(smartAccount)
		);
				
		return payable(smartAccount);
	}

	
	
	
	/// 0..nonExistent,
	/// 1..active,
	/// 2..closedByOwner,
	/// 3..closedByLiquidation,
	/// 4..closedByRedemption
	
	
	
	function getCreditLineStatusLiquity(address payable _smartAccount) external view returns (
		uint8 status,
		uint256 collateral,
		uint256 debtToRepay, 
		uint256 debtComposite
	) {
		(debtComposite, collateral, , status, ) = TroveManager.Troves(_smartAccount);	
		debtToRepay = debtComposite > LIQUITY_LUSD_GAS_COMPENSATION ? debtComposite - LIQUITY_LUSD_GAS_COMPENSATION : 0;
	}

	
	function getLiquityHints(uint256 NICR) internal view returns (
		address upperHint,
		address lowerHint
	) {
		// Get an approximate address hint from the deployed HintHelper contract.
		uint256 numTroves = SortedTroves.getSize();
		uint256 numTrials = sqrt(numTroves) * 15;
		(address approxHint, , ) = HintHelpers.getApproxHint(NICR, numTrials, 0x41505553);

		// Use the approximate hint to get the exact upper and lower hints from the deployed SortedTroves contract
		(upperHint, lowerHint) = SortedTroves.findInsertPosition(NICR, approxHint, approxHint);
	}

	
	/// Includes _LUSDRequested, Adoption Contribution, Liquity protocol fee.
	/// Adoption Contribution reflects the Adoption Contribution Rate and Recognised Community Contributor Acknowledgement Rate if applicable.
	function getLiquityExpectedDebtToRepay(uint256 _LUSDRequested) internal view returns (uint256 expectedDebtToRepay) {
		uint16 applicableAcr;
		uint256 expectedLiquityProtocolRate;

		(applicableAcr, expectedLiquityProtocolRate) = getLiquityRates();

		uint256 neededLUSDAmount = calcNeededLiquityLUSDAmount(_LUSDRequested, expectedLiquityProtocolRate, applicableAcr);

		uint256 expectedLiquityProtocolFee = TroveManager.getBorrowingFeeWithDecay(neededLUSDAmount);

		expectedDebtToRepay = neededLUSDAmount + expectedLiquityProtocolFee;
	}

	
	
	
	function getLiquityRates() internal view returns (uint16 applicableAcr, uint256 expectedLiquityProtocolRate) {
		// Get and apply Recognised Community Contributor Acknowledgement Rate
		CommunityAcknowledgement ca = CommunityAcknowledgement(Registry(registry).getAddress(COMMUNITY_ACKNOWLEDGEMENT_ID));
		uint16 rccar = ca.getAcknowledgementRate(keccak256(abi.encodePacked(msg.sender)));

		Config config = Config(Registry(registry).getAddress(CONFIG_ID));

		applicableAcr = applyRccarOnAcr(rccar, config.adoptionContributionRate());

		expectedLiquityProtocolRate = TroveManager.getBorrowingRateWithDecay();
	}

	
	function userAdoptionRate() external view returns (uint256) {
		uint16 applicableAcr;
		uint256 expectedLiquityProtocolRate;

		(applicableAcr, expectedLiquityProtocolRate) = getLiquityRates();

		// Normalise applicable ACR 1e4 -> 1e18
        uint256 r = DECIMAL_PRECISION / ACR_DECIMAL_PRECISION * applicableAcr;

        // Apply Liquity protocol rate when applicable ACR is lower
        return r < expectedLiquityProtocolRate ? expectedLiquityProtocolRate : r;
	}

	
    
	///	  		Adoption Contribution including protocol's fees is applied in the form of additional debt.
    
	
	
	
	
	
	
    function calculateInitialLiquityParameters(uint256 _LUSDRequested, uint256 _collateralAmount) public view returns (
		uint256 expectedDebtToRepay,
		uint256 liquidationReserve,
		uint256 expectedCompositeDebtLiquity,
        uint256 NICR,
		address upperHint,
		address lowerHint
    ) {
		liquidationReserve = LIQUITY_LUSD_GAS_COMPENSATION;

		expectedDebtToRepay = getLiquityExpectedDebtToRepay(_LUSDRequested);

		expectedCompositeDebtLiquity = expectedDebtToRepay + LIQUITY_LUSD_GAS_COMPENSATION;

		// Get the nominal NICR of the new Liquity's trove
		NICR = _collateralAmount * 1e20 / expectedCompositeDebtLiquity;

		(upperHint, lowerHint) = getLiquityHints(NICR);
    }

	
	
	
	///			Adoption Contribution including protocol's fees is applied in the form of additional debt in case of requested debt increase.
	
	
	
	
	
	
	
	
	
	
	function calculateChangedLiquityParameters(
		bool _isDebtIncrease,
		uint256 _LUSDRequestedChange,
		bool _isCollateralIncrease,
		uint256 _collateralChange,
		address payable _smartAccount
	)  public view returns (
		uint256 newCollateral,
		uint256 expectedDebtToRepay,
		uint256 liquidationReserve,
		uint256 expectedCompositeDebtLiquity,
        uint256 NICR,
		address upperHint,
		address lowerHint
    ) {
		liquidationReserve = LIQUITY_LUSD_GAS_COMPENSATION;

		// Get the current LUSD debt and ETH collateral
		(uint256 currentCompositeDebt, uint256 currentCollateral, , ) = TroveManager.getEntireDebtAndColl(_smartAccount);

		uint256 currentDebtToRepay = currentCompositeDebt - LIQUITY_LUSD_GAS_COMPENSATION;

		if (_isCollateralIncrease) {
			newCollateral = currentCollateral + _collateralChange;
		} else {
			newCollateral = currentCollateral - _collateralChange;
		}

		if (_isDebtIncrease) {
			uint256 additionalDebtToRepay = getLiquityExpectedDebtToRepay(_LUSDRequestedChange);
			expectedDebtToRepay = currentDebtToRepay + additionalDebtToRepay;
		} else {
			expectedDebtToRepay = currentDebtToRepay - _LUSDRequestedChange;
		}

		expectedCompositeDebtLiquity = expectedDebtToRepay + LIQUITY_LUSD_GAS_COMPENSATION;

		// Get the nominal NICR of the new Liquity's trove
		NICR = newCollateral * 1e20 / expectedCompositeDebtLiquity;

		(upperHint, lowerHint) = getLiquityHints(NICR);

	}

	
	/// Creates the new Smart Account (MakerDAO's proxy) if requested.
	/// Use calculateInitialLiquityParameters for gasless calculation of proper Hints for _LUSDRequested.
	
	
	
	
	
	
	
	function openCreditLineLiquity(uint256 _LUSDRequested, address _LUSDTo, address _upperHint, address _lowerHint, address payable _smartAccount) external payable {

		// By submitting 0x00..0 as the smartAccount address the caller wants to open a new Smart Account during this 1 transaction and thus saving gas.
		_smartAccount = (_smartAccount == address(0)) ? _openSmartAccount() : _smartAccount;

		_execute(_smartAccount, msg.value, abi.encodeWithSignature(
			"openCreditLineLiquity(uint256,address,address,address,address)",
			_LUSDRequested, _LUSDTo, _upperHint, _lowerHint, msg.sender
		));

	}

	
	
	
	
	function closeCreditLineLiquity(address _LUSDFrom, address payable _collateralTo, address payable _smartAccount) public {

		_execute(_smartAccount, 0, 
			abi.encodeWithSignature(
				"closeCreditLineLiquity(address,address,address)",
				_LUSDFrom,
				_collateralTo, 
				msg.sender
		));

	}

	
	
	
	
	
	
	
	function closeCreditLineLiquityWithPermit(address _LUSDFrom, address payable _collateralTo, uint8 v, bytes32 r, bytes32 s, address payable _smartAccount) external {

		_execute(_smartAccount, 0, abi.encodeWithSignature(
			"closeCreditLineLiquityWithPermit(address,address,uint8,bytes32,bytes32,address)",
			_LUSDFrom, _collateralTo, v, r, s, msg.sender
		));

	}

	
	/// Use calculateChangedLiquityParameters for gasless calculation of proper Hints for _LUSDRequestedChange.
	
	
	///			The increase or decrease is indicated by _isDebtIncrease.
	///			Adoption Contribution and protocol's fees are applied in the form of additional debt in case of requested debt increase.
	
	/// Or address that will receive the generated LUSD in case of increasing debt.
	/// Approval of LUSD transfers for given Smart Account is required in case of repaying debt.
	
	
	
	
	
	
	
	
	function adjustCreditLineLiquity(
		bool _isDebtIncrease,
		uint256 _LUSDRequestedChange,
		address _LUSDAddress,
		uint256 _collWithdrawal,
		address payable _collateralTo,
		address _upperHint, address _lowerHint,
		address payable _smartAccount) external payable {

		_execute(_smartAccount, msg.value, abi.encodeWithSignature(
			"adjustCreditLineLiquity(bool,uint256,address,uint256,address,address,address,address)",
			_isDebtIncrease, _LUSDRequestedChange, _LUSDAddress, _collWithdrawal, _collateralTo, _upperHint, _lowerHint, msg.sender
		));

	}

	
	/// Use calculateChangedLiquityParameters for gasless calculation of proper Hints for _LUSDRequestedChange.
	/// It is useful only when the debt decrease is requested while working with collateral.
	/// In all other cases [adjustCreditLineLiquity()] MUST be used. It is cheaper on gas.
	
	
	/// Approval of LUSD transfers for given Smart Account is ensured by the offchain signature from that address.
	
	
	
	
	
	
	
	
	
	
	function adjustCreditLineLiquityWithPermit(
		uint256 _LUSDRequestedChange,
		address _LUSDFrom,
		uint256 _collWithdrawal,
		address payable _collateralTo,
		address _upperHint, address _lowerHint,
		uint8 v, bytes32 r, bytes32 s,
		address payable _smartAccount) external payable {

		_execute(_smartAccount, msg.value, abi.encodeWithSignature(
			"adjustCreditLineLiquityWithPermit(uint256,address,uint256,address,address,address,uint8,bytes32,bytes32,address)",
			_LUSDRequestedChange, _LUSDFrom, _collWithdrawal, _collateralTo, _upperHint, _lowerHint, v, r, s, msg.sender
		));

	}

	
	function checkClaimableCollateralLiquity(address _smartAccount) external view returns (uint256) {
		return CollSurplusPool.getCollateral(_smartAccount);
	}

	
	
	
	function claimRemainingCollateralLiquity(address payable _collateralTo, address payable _smartAccount) external {
		_execute(_smartAccount, 0, abi.encodeWithSignature(
			"claimRemainingCollateralLiquity(address,address)",
			_collateralTo,
			msg.sender
		));
	}


	
	
	
	
	
	function addCollateralLiquity(address _upperHint, address _lowerHint, address payable _smartAccount) external payable {

		// Must be executable by anyone in order to be able to provide ETH by addresses, which do not own smart account proxy
		_executeByAnyone(_smartAccount, msg.value, abi.encodeWithSignature(
			"addCollateralLiquity(address,address,address)",
			_upperHint, _lowerHint, msg.sender
		));
	}

	
	
	
	
	
	
	
	function withdrawCollateralLiquity(uint256 _collWithdrawal, address payable _collateralTo, address _upperHint, address _lowerHint, address payable _smartAccount) external {

		_execute(_smartAccount, 0, abi.encodeWithSignature(
			"withdrawCollateralLiquity(uint256,address,address,address,address)",
			_collWithdrawal, _collateralTo, _upperHint, _lowerHint, msg.sender
		));

	}

	
	/// This increases the debt on the Credit Line, decreases CR (increases LTV).
	
	
	
	
	
	
	
	
	function borrowLUSDLiquity(uint256 _LUSDRequestedChange, address _LUSDTo, address _upperHint, address _lowerHint, address payable _smartAccount) external {

		_execute(_smartAccount, 0, abi.encodeWithSignature(
			"adjustCreditLineLiquity(bool,uint256,address,uint256,address,address,address,address)",
			true, _LUSDRequestedChange, _LUSDTo, 0, msg.sender, _upperHint, _lowerHint, msg.sender
//			_isDebtIncrease, _LUSDRequestedChange, _LUSDAddress, _collWithdrawal, _collateralTo, _upperHint, _lowerHint, msg.sender
		));

	}

	
	/// Approval of LUSD transfers for given Smart Account is required.
	/// Cannot repay below 2000 LUSD composite debt. Use closeCreditLineLiquity to repay whole debt instead.
	
	
	
	
	
	
	function repayLUSDLiquity(uint256 _LUSDRequestedChange, address _LUSDFrom, address _upperHint, address _lowerHint, address payable _smartAccount) external {

		_execute(_smartAccount, 0, abi.encodeWithSignature(
			"repayLUSDLiquity(uint256,address,address,address,address)",
			_LUSDRequestedChange, _LUSDFrom, _upperHint, _lowerHint, msg.sender
		));

	}

	
	/// Approval of LUSD transfers for given Smart Account is ensured by the offchain signature.
	/// Cannot repay below 2000 LUSD composite debt. Use closeCreditLineLiquity to repay whole debt instead.
	
	
	
	
	
	
	
	
	
	function repayLUSDLiquityWithPermit(uint256 _LUSDRequestedChange, address _LUSDFrom, address _upperHint, address _lowerHint, uint8 v, bytes32 r, bytes32 s, address payable _smartAccount) external {

		_execute(_smartAccount, 0, abi.encodeWithSignature(
			"repayLUSDLiquityWithPermit(uint256,address,address,address,uint8,bytes32,bytes32,address)",
			_LUSDRequestedChange, _LUSDFrom, _upperHint, _lowerHint, v, r, s, msg.sender
		));

	}

}

// 
pragma solidity =0.8.10;

abstract contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view virtual returns (bool);
}

// 
pragma solidity =0.8.10;



abstract contract DSProxy is DSAuth {
    DSProxyCache public cache; // global cache for contracts

    constructor(address _cacheAddr) {
        require(setCache(_cacheAddr), "Cache not set");
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    // use the proxy to execute calldata _data on contract _code
    function execute(bytes memory _code, bytes memory _data)
        public
        payable
        virtual
        returns (address target, bytes32 response);

    function execute(address _target, bytes memory _data)
        public
        payable
        virtual
        returns (bytes32 response);

    //set new cache
    function setCache(address _cacheAddr) public payable virtual returns (bool);
}

abstract contract DSProxyCache {
    mapping(bytes32 => address) cache;

    function read(bytes memory _code) public view virtual returns (address);

    function write(bytes memory _code) public virtual returns (address target);
}

// 
pragma solidity =0.8.10;



abstract contract DSProxyFactory {
    function build(address owner) public virtual returns (DSProxy proxy);
    function build() public virtual returns (DSProxy proxy);
    function isProxy(address proxy) public virtual view returns (bool);
}

// 

pragma solidity =0.8.10;


interface ICollSurplusPool {

    // --- Events ---
    
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolAddressChanged(address _newActivePoolAddress);

    event CollBalanceUpdated(address indexed _account, uint _newBalance);
    event EtherSent(address _to, uint _amount);

    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _activePoolAddress
    ) external;

    function getETH() external view returns (uint);

    function getCollateral(address _account) external view returns (uint);

    function accountSurplus(address _account, uint _amount) external;

    function claimColl(address _account) external;
}

// 

pragma solidity =0.8.10;

interface IHintHelpers {

    function getRedemptionHints(
        uint _LUSDamount, 
        uint _price,
        uint _maxIterations
    )
        external
        view
        returns (
            address firstRedemptionHint,
            uint partialRedemptionHintNICR,
            uint truncatedLUSDamount
        );

    function getApproxHint(uint _CR, uint _numTrials, uint _inputRandomSeed)
        external
        view
        returns (address hintAddress, uint diff, uint latestRandomSeed);

    function computeNominalCR(uint _coll, uint _debt) external pure returns (uint);

    function computeCR(uint _coll, uint _debt, uint _price) external pure returns (uint);
}

// 

pragma solidity =0.8.10;

// Common interface for the SortedTroves Doubly Linked List.
interface ISortedTroves {

    // --- Events ---
    
    event SortedTrovesAddressChanged(address _sortedDoublyLLAddress);
    event BorrowerOperationsAddressChanged(address _borrowerOperationsAddress);
    event NodeAdded(address _id, uint _NICR);
    event NodeRemoved(address _id);

    // --- Functions ---
    
    function setParams(uint256 _size, address _TroveManagerAddress, address _borrowerOperationsAddress) external;

    function insert(address _id, uint256 _ICR, address _prevId, address _nextId) external;

    function remove(address _id) external;

    function reInsert(address _id, uint256 _newICR, address _prevId, address _nextId) external;

    function contains(address _id) external view returns (bool);

    function isFull() external view returns (bool);

    function isEmpty() external view returns (bool);

    function getSize() external view returns (uint256);

    function getMaxSize() external view returns (uint256);

    function getFirst() external view returns (address);

    function getLast() external view returns (address);

    function getNext(address _id) external view returns (address);

    function getPrev(address _id) external view returns (address);

    function validInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (bool);

    function findInsertPosition(uint256 _ICR, address _prevId, address _nextId) external view returns (address, address);
}

// 

pragma solidity =0.8.10;


// Common interface for the Trove Manager.
interface ITroveManager {
    
    // --- Events ---

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event PriceFeedAddressChanged(address _newPriceFeedAddress);
    event LUSDTokenAddressChanged(address _newLUSDTokenAddress);
    event ActivePoolAddressChanged(address _activePoolAddress);
    event DefaultPoolAddressChanged(address _defaultPoolAddress);
    event StabilityPoolAddressChanged(address _stabilityPoolAddress);
    event GasPoolAddressChanged(address _gasPoolAddress);
    event CollSurplusPoolAddressChanged(address _collSurplusPoolAddress);
    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event LQTYTokenAddressChanged(address _lqtyTokenAddress);
    event LQTYStakingAddressChanged(address _lqtyStakingAddress);

    event Liquidation(uint _liquidatedDebt, uint _liquidatedColl, uint _collGasCompensation, uint _LUSDGasCompensation);
    event Redemption(uint _attemptedLUSDAmount, uint _actualLUSDAmount, uint _ETHSent, uint _ETHFee);
    event TroveUpdated(address indexed _borrower, uint _debt, uint _coll, uint stake, uint8 operation);
    event TroveLiquidated(address indexed _borrower, uint _debt, uint _coll, uint8 operation);
    event BaseRateUpdated(uint _baseRate);
    event LastFeeOpTimeUpdated(uint _lastFeeOpTime);
    event TotalStakesUpdated(uint _newTotalStakes);
    event SystemSnapshotsUpdated(uint _totalStakesSnapshot, uint _totalCollateralSnapshot);
    event LTermsUpdated(uint _L_ETH, uint _L_LUSDDebt);
    event TroveSnapshotsUpdated(uint _L_ETH, uint _L_LUSDDebt);
    event TroveIndexUpdated(address _borrower, uint _newIndex);

    function getTroveOwnersCount() external view returns (uint);

    function getTroveFromTroveOwnersArray(uint _index) external view returns (address);

    function getNominalICR(address _borrower) external view returns (uint);
    function getCurrentICR(address _borrower, uint _price) external view returns (uint);

    function liquidate(address _borrower) external;

    function liquidateTroves(uint _n) external;

    function batchLiquidateTroves(address[] calldata _troveArray) external;

    function redeemCollateral(
        uint _LUSDAmount,
        address _firstRedemptionHint,
        address _upperPartialRedemptionHint,
        address _lowerPartialRedemptionHint,
        uint _partialRedemptionHintNICR,
        uint _maxIterations,
        uint _maxFee
    ) external; 

    function updateStakeAndTotalStakes(address _borrower) external returns (uint);

    function updateTroveRewardSnapshots(address _borrower) external;

    function addTroveOwnerToArray(address _borrower) external returns (uint index);

    function applyPendingRewards(address _borrower) external;

    function getPendingETHReward(address _borrower) external view returns (uint);

    function getPendingLUSDDebtReward(address _borrower) external view returns (uint);

     function hasPendingRewards(address _borrower) external view returns (bool);

    function getEntireDebtAndColl(address _borrower) external view returns (
        uint debt, 
        uint coll, 
        uint pendingLUSDDebtReward, 
        uint pendingETHReward
    );

    function closeTrove(address _borrower) external;

    function removeStake(address _borrower) external;

    function getRedemptionRate() external view returns (uint);
    function getRedemptionRateWithDecay() external view returns (uint);

    function getRedemptionFeeWithDecay(uint _ETHDrawn) external view returns (uint);

    function getBorrowingRate() external view returns (uint);
    function getBorrowingRateWithDecay() external view returns (uint);

    function getBorrowingFee(uint LUSDDebt) external view returns (uint);
    function getBorrowingFeeWithDecay(uint _LUSDDebt) external view returns (uint);

    function decayBaseRateFromBorrowing() external;

    function getTroveStatus(address _borrower) external view returns (uint);
    
    function getTroveStake(address _borrower) external view returns (uint);

    function getTroveDebt(address _borrower) external view returns (uint);

    function getTroveColl(address _borrower) external view returns (uint);

    function setTroveStatus(address _borrower, uint num) external;

    function increaseTroveColl(address _borrower, uint _collIncrease) external returns (uint);

    function decreaseTroveColl(address _borrower, uint _collDecrease) external returns (uint); 

    function increaseTroveDebt(address _borrower, uint _debtIncrease) external returns (uint); 

    function decreaseTroveDebt(address _borrower, uint _collDecrease) external returns (uint); 

    function getTCR(uint _price) external view returns (uint);

    function checkRecoveryMode(uint _price) external view returns (bool);

    function Troves(address) external view returns (uint256, uint256, uint256, uint8, uint128); 
}