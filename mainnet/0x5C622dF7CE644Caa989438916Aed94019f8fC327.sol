// SPDX-License-Identifier: GPL-3.0-or-later

// 
pragma solidity 0.8.6;









interface IMirrorDutchAuctionFactory {
    
    event MirrorDutchAuctionProxyDeployed(
        address proxy,
        address operator,
        address logic,
        bytes initializationData
    );

    function deploy(
        address operator,
        address tributary,
        IMirrorDutchAuctionLogic.AuctionConfig memory auctionConfig
    ) external returns (address proxy);
}

// 
pragma solidity 0.8.6;

interface IOwnableEvents {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

// 
pragma solidity 0.8.6;

interface IPausableEvents {
    
    event Paused(address account);

    
    event Unpaused(address account);
}

interface IPausable {
    function paused() external returns (bool);
}

/**
 * @title MirrorDutchAuctionFactory
 * @author MirrorXYZ
 * This contract implements a factory to deploy a simple Dutch Auction
 * proxies with a price reduction mechanism at fixed intervals.
 */
contract MirrorDutchAuctionFactory is
    IMirrorDutchAuctionFactory,
    IOwnableEvents,
    IPausableEvents
{
    
    address public logic;

    
    address public treasuryConfig;

    
    address public tributaryRegistry;

    constructor(
        address logic_,
        address treasuryConfig_,
        address tributaryRegistry_
    ) {
        logic = logic_;
        treasuryConfig = treasuryConfig_;
        tributaryRegistry = tributaryRegistry_;
    }

    function deploy(
        address operator,
        address tributary,
        IMirrorDutchAuctionLogic.AuctionConfig memory auctionConfig
    ) external override returns (address proxy) {
        bytes memory initializationData = abi.encodeWithSelector(
            IMirrorDutchAuctionLogic.initialize.selector,
            operator,
            treasuryConfig,
            auctionConfig
        );

        proxy = address(
            new MirrorDutchAuctionProxy{
                salt: keccak256(
                    abi.encode(
                        operator,
                        auctionConfig.recipient,
                        auctionConfig.nft
                    )
                )
            }(logic, initializationData)
        );

        emit MirrorDutchAuctionProxyDeployed(
            proxy,
            operator,
            logic,
            initializationData
        );

        ITributaryRegistry(tributaryRegistry).registerTributary(
            proxy,
            tributary
        );
    }
}

contract Ownable is IOwnableEvents {
    address public owner;
    address private nextOwner;

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
        _renounceOwnership();
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

    function _setOwner(address previousOwner, address newOwner) internal {
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, owner);
    }

    function _renounceOwnership() internal {
        owner = address(0);

        emit OwnershipTransferred(owner, address(0));
    }
}

contract Pausable is IPausable, IPausableEvents {
    bool public override paused;

    // Modifiers

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    
    constructor(bool paused_) {
        paused = paused_;
    }

    // ============ Internal Functions ============

    function _pause() internal whenNotPaused {
        paused = true;

        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {
        paused = false;

        emit Unpaused(msg.sender);
    }
}

// 
pragma solidity 0.8.6;

interface ITreasuryConfig {
    function treasury() external returns (address payable);

    function distributionModel() external returns (address);
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

interface IMirrorTreasury {
    function transferFunds(address payable to, uint256 value) external;

    function transferERC20(
        address token,
        address to,
        uint256 value
    ) external;

    function contributeWithTributary(address tributary) external payable;

    function contribute(uint256 amount) external payable;
}

// 
pragma solidity 0.8.6;

/**
 * @title MirrorDutchAuctionProxy
 * @author MirrorXYZ
 */
contract MirrorDutchAuctionProxy {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @notice Stores implementation logic.
     * @param implementation - the implementation holds the logic for all proxies
     * @param initializationData - initialization call
     */
    constructor(address implementation, bytes memory initializationData) {
        // Delegatecall into the relayer, supplying initialization calldata.
        (bool ok, ) = implementation.delegatecall(initializationData);

        // Revert and include revert data if delegatecall to implementation reverts.
        if (!ok) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        assembly {
            sstore(_IMPLEMENTATION_SLOT, implementation)
        }
    }

    /**
     * @notice When any function is called on this contract, we delegate to
     * the logic contract stored in the implementation storage slot.
     */
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

interface IMirrorDutchAuctionLogic {
    
    event AuctionStarted(uint256 blockNumber);

    
    event Withdrawal(address recipient, uint256 amount, uint256 fee);

    
    event Bid(address recipient, uint256 price, uint256 tokenId);

    struct AuctionConfig {
        uint256[] prices;
        uint256 interval;
        uint256 startTokenId;
        uint256 endTokenId;
        address recipient;
        address nft;
        address nftOwner;
    }

    
    function prices(uint256 index) external returns (uint256);

    
    function interval() external returns (uint256);

    
    function tokenId() external returns (uint256);

    
    function endTokenId() external returns (uint256);

    
    function globalTimeElapsed() external returns (uint256);

    
    function recipient() external returns (address);

    
    function purchased(address account) external returns (bool);

    
    function auctionStartBlock() external returns (uint256);

    
    function pauseBlock() external returns (uint256);

    
    function unpauseBlock() external returns (uint256);

    
    function nft() external returns (address);

    
    function nftOwner() external returns (address);

    
    function endingPrice() external returns (uint256);

    
    function changeRecipient(address newRecipient) external;

    
    function getAllPrices() external returns (uint256[] memory);

    /**
     * @dev This contract is used as the logic for proxies. Hence we include
     * the ability to call "initialize" when deploying a proxy to set initial
     * variables without having to define them and implement in the proxy's
     * constructor. This function reverts if called after deployment.
     */
    function initialize(
        address owner_,
        address treasuryConfig_,
        IMirrorDutchAuctionLogic.AuctionConfig memory auctionConfig_
    ) external;

    
    function pause() external;

    
    function unpause() external;

    
    function cancel() external;

    
    function price() external view returns (uint256);

    
    function time() external view returns (uint256);

    /**
     * @notice Bid for an NFT. If the price is met transfer NFT to sender.
     * If price drops before the transaction mines, refund value.
     */
    function bid() external payable;

    
    function withdraw() external;
}