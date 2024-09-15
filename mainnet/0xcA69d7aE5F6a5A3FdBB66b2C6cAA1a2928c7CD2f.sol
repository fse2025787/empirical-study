// SPDX-License-Identifier: GPL-3.0-or-later


interface IERC20Events {
    
    event Mint(address indexed to, uint256 amount);

    
    event Approval(
        address indexed from,
        address indexed spender,
        uint256 value
    );

    
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// 
pragma solidity 0.8.6;

interface IERC20 {
    
    function name() external returns (string calldata);

    
    function symbol() external returns (string calldata);

    
    function decimals() external returns (uint8);

    
    function totalSupply() external returns (uint256);

    
    function balanceOf(address account) external returns (uint256);

    
    function allowance(address owner, address spender)
        external
        returns (uint256);

    
    function approve(address spender, uint256 value) external returns (bool);

    
    function transfer(address to, uint256 value) external returns (bool);

    
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// 
pragma solidity 0.8.6;

contract Ownable {
    address public owner;
    address private nextOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // modifiers

    modifier onlyOwner() {
        require(isOwner(), "caller is not the owner.");
        _;
    }

    modifier onlyNextOwner() {
        require(isNextOwner(), "current owner must set caller as next owner.");
        _;
    }

    /**
     * @dev Initialize contract by setting transaction submitter as initial owner.
     */
    constructor(address owner_) {
        owner = owner_;
        emit OwnershipTransferred(address(0), owner);
    }

    /**
     * @dev Initiate ownership transfer by setting nextOwner.
     */
    function transferOwnership(address nextOwner_) external onlyOwner {
        require(nextOwner_ != address(0), "Next owner is the zero address.");

        nextOwner = nextOwner_;
    }

    /**
     * @dev Cancel ownership transfer by deleting nextOwner.
     */
    function cancelOwnershipTransfer() external onlyOwner {
        delete nextOwner;
    }

    /**
     * @dev Accepts ownership transfer by setting owner.
     */
    function acceptOwnership() external onlyNextOwner {
        delete nextOwner;

        owner = msg.sender;

        emit OwnershipTransferred(owner, msg.sender);
    }

    /**
     * @dev Renounce ownership by setting owner to zero address.
     */
    function renounceOwnership() external onlyOwner {
        owner = address(0);

        emit OwnershipTransferred(owner, address(0));
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    /**
     * @dev Returns true if the caller is the next owner.
     */
    function isNextOwner() public view returns (bool) {
        return msg.sender == nextOwner;
    }
}

// 
pragma solidity 0.8.6;

interface IGovernable {
    function changeGovernor(address governor_) external;

    function isGovernor() external view returns (bool);

    function governor() external view returns (address);
}

// 
pragma solidity 0.8.6;




contract Governable is Ownable, IGovernable {
    // ============ Mutable Storage ============

    // Mirror governance contract.
    address public override governor;

    // ============ Modifiers ============

    modifier onlyGovernance() {
        require(isOwner() || isGovernor(), "caller is not governance");
        _;
    }

    modifier onlyGovernor() {
        require(isGovernor(), "caller is not governor");
        _;
    }

    // ============ Constructor ============

    constructor(address owner_) Ownable(owner_) {}

    // ============ Administration ============

    function changeGovernor(address governor_) public override onlyGovernance {
        governor = governor_;
    }

    // ============ Utility Functions ============

    function isGovernor() public view override returns (bool) {
        return msg.sender == governor;
    }
}

// 
pragma solidity 0.8.6;

/**
 * @title CrowdfundStorage
 * @author MirrorXYZ
 */
contract CrowdfundStorage {
    /**
     * @notice The two states that this contract can exist in.
     * "FUNDING" allows contributors to add funds.
     */
    enum Status {
        FUNDING,
        TRADING
    }

    // ============ Constants ============

    
    uint16 internal constant TOKEN_SCALE = 1000;

    // ============ Reentrancy ============

    
    uint256 internal constant REENTRANCY_NOT_ENTERED = 1;
    uint256 internal constant REENTRANCY_ENTERED = 2;

    
    uint256 internal reentrancy_status;

    
    address payable public operator;

    
    address payable public fundingRecipient;

    
    address public treasuryConfig;

    
    uint256 public fundingCap;

    
    uint256 public feePercentage;

    
    uint256 public operatorPercent;

    // ============ Mutable Storage ============

    
    Status public status;
}

// 
pragma solidity 0.8.6;

/**
 * @title ERC20Storage
 * @author MirrorXYZ
 */
contract ERC20Storage {
    
    string public name;

    
    string public symbol;

    
    uint256 public totalSupply;

    
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        totalSupply = 0;
    }
}

// 
pragma solidity 0.8.6;

// import {ERC20Storage} from "./ERC20Storage.sol";


/**
 * @title ERC20 Implementation.
 * @author MirrorXYZ
 */
contract ERC20 is IERC20, IERC20Events {
    // ============ ERC20 Attributes ============
    
    string public override name;

    
    string public override symbol;

    
    uint8 public constant override decimals = 18;

    // ============ Mutable ERC20 Storage ============
    
    uint256 public override totalSupply;

    
    mapping(address => uint256) public override balanceOf;

    
    mapping(address => mapping(address => uint256)) public override allowance;

    /**
     * @notice Initialize and assign total supply when using
     * proxy pattern. Only callable during contract deployment.
     * @param totalSupply_ is the initial token supply
     * @param to_ is the address that will hold the initial token supply
     */
    function initialize(uint256 totalSupply_, address to_) external {
        // Ensure that this function is only callable during contract construction.
        assembly {
            if extcodesize(address()) {
                revert(0, 0)
            }
        }

        totalSupply = totalSupply_;
        balanceOf[to_] = totalSupply_;
        emit Transfer(address(0), to_, totalSupply_);
    }

    // ============ ERC20 Spec ============

    /**
     * @dev Function to increase allowance of tokens.
     * @param spender The address that will receive an allowance increase.
     * @param value The amount of tokens to increase allowance.
     */
    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Function to transfer tokens.
     * @param to The address that will receive the tokens.
     * @param value The amount of tokens to transfer.
     */
    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Function to transfer an accounts tokens. Sender of txn must be approved.
     * @param from The address that will transfer tokens.
     * @param to The address that will receive the tokens.
     * @param value The amount of tokens to transfer.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        require(
            allowance[from][msg.sender] >= value,
            "transfer amount exceeds spender allowance"
        );

        allowance[from][msg.sender] = allowance[from][msg.sender] - value;
        _transfer(from, to, value);
        return true;
    }

    // ============ Private Utils ============

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply + value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from] - value;
        totalSupply = totalSupply - value;
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(balanceOf[from] >= value, "transfer amount exceeds balance");

        balanceOf[from] = balanceOf[from] - value;
        balanceOf[to] = balanceOf[to] + value;

        emit Transfer(from, to, value);
    }
}
// 
pragma solidity 0.8.6;







/**
 * @title CrowdfundFactory
 * @author MirrorXYZ
 */
contract CrowdfundFactory is Governable {
    //======== Structs ========

    struct Parameters {
        address payable fundingRecipient;
        uint256 fundingCap;
        uint256 operatorPercent;
        uint256 feePercentage;
    }

    //======== Events ========

    event CrowdfundDeployed(
        address crowdfundProxy,
        string name,
        string symbol,
        address operator
    );

    event Upgraded(address indexed implementation);

    //======== Configuration storage =========

    /*
        Updatable via governance
    */

    address public logic;
    address public tributaryRegistry;
    address public treasuryConfig;
    uint256 public minFeePercentage = 250;

    //======== Runtime mutable storage =========

    // Gets set within the block, and then deleted.
    Parameters public parameters;

    //======== Constructor =========

    constructor(
        address owner_,
        address logic_,
        address tributaryRegistry_,
        address treasuryConfig_
    ) Governable(owner_) {
        logic = logic_;
        tributaryRegistry = tributaryRegistry_;
        treasuryConfig = treasuryConfig_;
    }

    //======== Configuration =========

    function setMinimumFeePercentage(uint256 newMinFeePercentage)
        public
        onlyGovernance
    {
        minFeePercentage = newMinFeePercentage;
    }

    function setLogic(address newLogic) public onlyGovernance {
        logic = newLogic;
    }

    function setTreasuryConfig(address newTreasuryConfig)
        public
        onlyGovernance
    {
        treasuryConfig = newTreasuryConfig;
    }

    function setTributaryRegistry(address newTributaryRegistry)
        public
        onlyGovernance
    {
        tributaryRegistry = newTributaryRegistry;
    }

    //======== Deploy function =========
    struct TributaryConfig {
        address tributary;
        uint256 feePercentage;
    }

    function createCrowdfund(
        TributaryConfig calldata tributaryConfig,
        string calldata name_,
        string calldata symbol_,
        address payable operator_,
        address payable fundingRecipient_,
        uint256 fundingCap_,
        uint256 operatorPercent_
    ) external returns (address crowdfundProxy) {
        require(
            tributaryConfig.feePercentage >= minFeePercentage,
            "fee is too low"
        );

        parameters = Parameters({
            fundingRecipient: fundingRecipient_,
            fundingCap: fundingCap_,
            operatorPercent: operatorPercent_,
            feePercentage: tributaryConfig.feePercentage
        });

        crowdfundProxy = address(
            new CrowdfundProxy{salt: keccak256(abi.encode(symbol_, operator_))}(
                treasuryConfig,
                operator_,
                name_,
                symbol_
            )
        );

        delete parameters;

        emit CrowdfundDeployed(crowdfundProxy, name_, symbol_, operator_);

        ITributaryRegistry(tributaryRegistry).registerTributary(
            crowdfundProxy,
            tributaryConfig.tributary
        );
    }
}

// 
pragma solidity 0.8.6;





interface ICrowdfundFactory {
    function mediaAddress() external returns (address);

    function logic() external returns (address);

    // ERC20 data.
    function parameters()
        external
        returns (
            address payable fundingRecipient,
            uint256 fundingCap,
            uint256 operatorPercent,
            uint256 feePercentage
        );
}

/**
 * @title CrowdfundProxy
 * @author MirrorXYZ
 */
contract CrowdfundProxy is CrowdfundStorage, ERC20Storage, IERC20Events {
    event Upgraded(address indexed implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(
        address treasuryConfig_,
        address payable operator_,
        string memory name_,
        string memory symbol_
    ) ERC20Storage(name_, symbol_) {
        address logic = ICrowdfundFactory(msg.sender).logic();

        assembly {
            sstore(_IMPLEMENTATION_SLOT, logic)
        }

        emit Upgraded(logic);

        // Crowdfund-specific data.
        (
            fundingRecipient,
            fundingCap,
            operatorPercent,
            feePercentage
        ) = ICrowdfundFactory(msg.sender).parameters();

        operator = operator_;
        treasuryConfig = treasuryConfig_;
        // Initialize mutable storage.
        status = Status.FUNDING;
    }

    
    function logic() external view returns (address logic_) {
        assembly {
            logic_ := sload(_IMPLEMENTATION_SLOT)
        }
    }

    fallback() external payable {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(
                gas(),
                sload(_IMPLEMENTATION_SLOT),
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    receive() external payable {}
}

// 
pragma solidity 0.8.6;






/**
 * @title CrowdfundLogic
 * @author MirrorXYZ
 *
 * Crowdfund issuing ERC20 tokens that can be redeemed for
 * the Ether in the contract once funding closes.
 */
contract CrowdfundLogic is CrowdfundStorage, ERC20 {
    // ============ Events ============

    event Contribution(address contributor, uint256 amount);

    event FundingClosed(uint256 amountRaised, uint256 creatorAllocation);
    event BidAccepted(uint256 amount);
    event Redeemed(address contributor, uint256 amount);
    event Withdrawal(uint256 amount, uint256 fee);

    // ============ Modifiers ============

    /**
     * @dev Modifier to check whether the `msg.sender` is the operator.
     * If it is, it will run the function. Otherwise, it will revert.
     */
    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(reentrancy_status != REENTRANCY_ENTERED, "Reentrant call");

        // Any calls to nonReentrant after this point will fail
        reentrancy_status = REENTRANCY_ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        reentrancy_status = REENTRANCY_NOT_ENTERED;
    }

    // ============ Crowdfunding Methods ============

    /**
     * @notice Mints tokens for the sender propotional to the
     *  amount of ETH sent in the transaction.
     * @dev Emits the Contribution event.
     */
    function contribute(address payable backer, uint256 amount)
        external
        payable
        nonReentrant
    {
        _contribute(backer, amount);
    }

    /**
     * @notice Burns the sender's tokens and redeems underlying ETH.
     * @dev Emits the Redeemed event.
     */
    function redeem(uint256 tokenAmount) external nonReentrant {
        // Prevent backers from accidently redeeming when balance is 0.
        require(
            address(this).balance > 0,
            "Crowdfund: No ETH available to redeem"
        );
        // Check
        require(
            balanceOf[msg.sender] >= tokenAmount,
            "Crowdfund: Insufficient balance"
        );
        require(status == Status.TRADING, "Crowdfund: Funding must be trading");
        // Effect
        uint256 redeemable = redeemableFromTokens(tokenAmount);
        _burn(msg.sender, tokenAmount);
        // Safe version of transfer.
        sendValue(payable(msg.sender), redeemable);
        emit Redeemed(msg.sender, redeemable);
    }

    /**
     * @notice Returns the amount of ETH that is redeemable for tokenAmount.
     */
    function redeemableFromTokens(uint256 tokenAmount)
        public
        view
        returns (uint256)
    {
        return (tokenAmount * address(this).balance) / totalSupply;
    }

    function valueToTokens(uint256 value) public pure returns (uint256 tokens) {
        tokens = value * TOKEN_SCALE;
    }

    function tokensToValue(uint256 tokenAmount)
        internal
        pure
        returns (uint256 value)
    {
        value = tokenAmount / TOKEN_SCALE;
    }

    // ============ Operator Methods ============

    /**
     * @notice Transfers all funds to operator, and mints tokens for the operator.
     *  Updates status to TRADING.
     * @dev Emits the FundingClosed event.
     */
    function closeFunding() external onlyOperator nonReentrant {
        require(status == Status.FUNDING, "Crowdfund: Funding must be open");
        // Close funding status, move to tradable.
        status = Status.TRADING;
        // Mint the operator a percent of the total supply.
        uint256 operatorTokens = (operatorPercent * totalSupply) /
            (100 - operatorPercent);
        _mint(operator, operatorTokens);
        // Announce that funding has been closed.
        emit FundingClosed(address(this).balance, operatorTokens);

        _withdraw();
    }

    /**
     * @notice Operator can change the funding recipient.
     */
    function changeFundingRecipient(address payable newFundingRecipient)
        public
        onlyOperator
    {
        fundingRecipient = newFundingRecipient;
    }

    function withdraw() public {
        _withdraw();
    }

    function computeFee(uint256 amount, uint256 feePercentage_)
        public
        pure
        returns (uint256 fee)
    {
        fee = (feePercentage_ * amount) / (100 * 100);
    }

    // ============ Utility Methods ============

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    // ============ Internal Methods  ============
    function _contribute(address payable backer, uint256 amount) private {
        require(status == Status.FUNDING, "Crowdfund: Funding must be open");
        require(amount == msg.value, "Crowdfund: Amount is not value sent");
        // This first case is the happy path, so we will keep it efficient.
        // The balance, which includes the current contribution, is less than or equal to cap.
        if (address(this).balance <= fundingCap) {
            // Mint equity for the contributor.
            _mint(backer, valueToTokens(amount));

            emit Contribution(backer, amount);
        } else {
            // Compute the balance of the crowdfund before the contribution was made.
            uint256 startAmount = address(this).balance - amount;
            // If that amount was already greater than the funding cap, then we should revert immediately.
            require(
                startAmount < fundingCap,
                "Crowdfund: Funding cap already reached"
            );
            // Otherwise, the contribution helped us reach the funding cap. We should
            // take what we can until the funding cap is reached, and refund the rest.
            uint256 eligibleAmount = fundingCap - startAmount;
            // Otherwise, we process the contribution as if it were the minimal amount.
            _mint(backer, valueToTokens(eligibleAmount));

            emit Contribution(backer, eligibleAmount);
            // Refund the sender with their contribution (e.g. 2.5 minus the diff - e.g. 1.5 = 1 ETH)
            sendValue(backer, amount - eligibleAmount);
        }
    }

    function _withdraw() internal {
        uint256 fee = feePercentage;

        emit Withdrawal(
            address(this).balance,
            computeFee(address(this).balance, fee)
        );

        // Transfer the fee to the treasury.
        sendValue(
            ITreasuryConfig(treasuryConfig).treasury(),
            computeFee(address(this).balance, fee)
        );
        // Transfer available balance to the fundingRecipient.
        sendValue(fundingRecipient, address(this).balance);
    }
}

// 
pragma solidity 0.8.6;

interface ICrowdfund {
    struct Edition {
        // The maximum number of tokens that can be sold.
        uint256 quantity;
        // The price at which each token will be sold, in ETH.
        uint256 price;
        // The account that will receive sales revenue.
        address payable fundingRecipient;
        // The number of tokens sold so far.
        uint256 numSold;
        bytes32 contentHash;
    }

    struct EditionTier {
        // The maximum number of tokens that can be sold.
        uint256 quantity;
        // The price at which each token will be sold, in ETH.
        uint256 price;
        bytes32 contentHash;
    }

    function buyEdition(uint256 editionId, address recipient)
        external
        payable
        returns (uint256 tokenId);

    function editionPrice(uint256 editionId) external view returns (uint256);

    function createEditions(
        EditionTier[] memory tier,
        // The account that should receive the revenue.
        address payable fundingRecipient,
        address minter
    ) external;

    function contractURI() external view returns (string memory);
}

// 
pragma solidity 0.8.6;

interface ITributaryRegistry {
    function addRegistrar(address registrar) external;

    function removeRegistrar(address registrar) external;

    function addSingletonProducer(address producer) external;

    function removeSingletonProducer(address producer) external;

    function registerTributary(address producer, address tributary) external;

    function producerToTributary(address producer)
        external
        returns (address tributary);

    function singletonProducer(address producer) external returns (bool);

    function changeTributary(address producer, address newTributary) external;
}

// 
pragma solidity 0.8.6;

interface ITreasuryConfig {
    function treasury() external returns (address payable);

    function distributionModel() external returns (address);
}
