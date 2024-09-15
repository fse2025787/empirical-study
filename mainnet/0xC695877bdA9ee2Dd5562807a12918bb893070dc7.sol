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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
pragma solidity ^0.8.15;







error InsufficientReward();



error InvalidActivity();



error InvalidActivityType();



error InactiveActivity();



error ActivityTimestampError();



error InvalidAddress();



error InvalidTimestamp();



error InsufficientTicket();



error InvalidInputLength();



error InvalidInput(string message);

contract GachaDraw is Ownable {
    
    
    
    
    
    
    event ActivityCreated(
        uint256 _activityId,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256[] _rewardTokenSupply
    );

    
    
    
    
    
    
    
    event DrawCompleted(
        uint256 _activityId,
        address _walletAddress,
        uint256 _ticketType,
        uint256 _ticketAmount,
        uint256 _drawIndex
    );

    modifier validActivity(uint256 _activityId) {
        if (_activityId > totalActivities || _activityId < 1) {
            revert InvalidActivity();
        }
        _;
    }

    modifier validActivityType(uint256 _activitType) {
        if (
            !(_activitType == FREE_ACTIVITY_TYPE ||
                _activitType == PREMIUM_ACTIVITY_TYPE)
        ) {
            revert InvalidActivityType();
        }
        _;
    }

    modifier validAddress(address _address) {
        if (_address == address(0) || _address == address(this)) {
            revert InvalidAddress();
        }
        _;
    }

    modifier validTimestamp(uint256 _startTimestamp, uint256 _endTimestamp) {
        if (_endTimestamp <= _startTimestamp) {
            revert InvalidTimestamp();
        }
        _;
    }

    uint256 public constant FREE_ACTIVITY_TYPE = 1;
    uint256 public constant PREMIUM_ACTIVITY_TYPE = 2;

    
    IAnimeMetaverseTicket public TicketContract;
    
    IAnimeMetaverseReward public RewardContract;

    
    struct Activity {
        uint256 activityId;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 activityType;
        bool isActive;
        uint256[] rewardTokenIds;
        uint256[] totalGivenRewardSupply;
        uint256[] maximumRewardSupply;
        uint256 remainingRewardSupply;
    }

    
    mapping(uint256 => Activity) public activities;

    uint256 public totalActivities;
    uint256 public totalRewardWon;
    uint256 public totalCompleteDraws;
    uint256 public maxRewardTokenId = 18;

    
    
    
    constructor(address _ticketContractAddress, address _rewardContractAddress)
    {
        TicketContract = IAnimeMetaverseTicket(_ticketContractAddress);
        RewardContract = IAnimeMetaverseReward(_rewardContractAddress);
    }

    
    
    
    function setTicketContract(address _ticketContractAddress)
        external
        onlyOwner
        validAddress(_ticketContractAddress)
    {
        TicketContract = IAnimeMetaverseTicket(_ticketContractAddress);
    }

    
    
    
    function setMaxRewardTokenId(uint256 _maxRewardTokenId) external onlyOwner {
        maxRewardTokenId = _maxRewardTokenId;
    }

    
    
    
    function setRewardContract(address _rewardContractAddress)
        external
        onlyOwner
        validAddress(_rewardContractAddress)
    {
        RewardContract = IAnimeMetaverseReward(_rewardContractAddress);
    }

    
    
    
    
    
    
    
    function createActivity(
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _activityType,
        uint256[] calldata _rewardTokenIds,
        uint256[] calldata _maxRewardSupply
    )
        external
        onlyOwner
        validActivityType(_activityType)
        validTimestamp(_startTimestamp, _endTimestamp)
    {
        if (_rewardTokenIds.length != _maxRewardSupply.length) {
            revert InvalidInputLength();
        }

        uint256 remainingRewardSupply;
        for (uint256 index = 0; index < _rewardTokenIds.length; index++) {
            remainingRewardSupply =
                remainingRewardSupply +
                _maxRewardSupply[index];
            if (
                _rewardTokenIds[index] > maxRewardTokenId ||
                _rewardTokenIds[index] < 1
            ) {
                revert InvalidInput("Invalid reward tokenId.");
            }
        }

        
        if (remainingRewardSupply < 1) {
            revert InsufficientReward();
        }

        totalActivities++;

        
        activities[totalActivities] = Activity({
            activityId: totalActivities,
            startTimestamp: _startTimestamp,
            endTimestamp: _endTimestamp,
            activityType: _activityType,
            isActive: true,
            totalGivenRewardSupply: new uint256[](_maxRewardSupply.length),
            maximumRewardSupply: _maxRewardSupply,
            remainingRewardSupply: remainingRewardSupply,
            rewardTokenIds: _rewardTokenIds
        });

        
        emit ActivityCreated(
            totalActivities,
            _startTimestamp,
            _endTimestamp,
            _maxRewardSupply
        );
    }

    
    
    
    
    function setActivityStatus(uint256 _activityId, bool _flag)
        external
        onlyOwner
        validActivity(_activityId)
    {
        activities[_activityId].isActive = _flag;
    }

    
    
    
    
    
    function setActivityTimestamp(
        uint256 _activityId,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    )
        external
        onlyOwner
        validActivity(_activityId)
        validTimestamp(_startTimestamp, _endTimestamp)
    {
        activities[_activityId].startTimestamp = _startTimestamp;
        activities[_activityId].endTimestamp = _endTimestamp;
    }

    
    
    
    
    function updateMaximumRewardSupply(
        uint256 _activityId,
        uint256[] calldata _maxRewardSupply
    ) external onlyOwner validActivity(_activityId) {
        if (
            _maxRewardSupply.length !=
            activities[_activityId].rewardTokenIds.length
        ) {
            revert InvalidInputLength();
        }

        uint256 newMaxRewardSupply;
        uint256 totalSupplyInCirculation;

        for (uint256 index = 0; index < _maxRewardSupply.length; index++) {
            if (
                _maxRewardSupply[index] <
                activities[_activityId].totalGivenRewardSupply[index]
            ) {
                revert InvalidInput(
                    "Maximum Supply Can Not Be Lower Than Total Supply."
                );
            }

            totalSupplyInCirculation += activities[_activityId]
                .totalGivenRewardSupply[index];
            newMaxRewardSupply = newMaxRewardSupply + _maxRewardSupply[index];
            activities[_activityId].maximumRewardSupply[
                index
            ] = _maxRewardSupply[index];
        }

        activities[_activityId].remainingRewardSupply =
            newMaxRewardSupply -
            totalSupplyInCirculation;
    }

    
    
    
    
    function drawTicket(uint256 _activityId, uint256 _ticketAmount)
        external
        validActivity(_activityId)
    {
        
        
        if (!activities[_activityId].isActive) {
            revert InactiveActivity();
        }

        
        
        if (
            block.timestamp < activities[_activityId].startTimestamp ||
            block.timestamp > activities[_activityId].endTimestamp
        ) {
            revert ActivityTimestampError();
        }

        if (_ticketAmount < 1) {
            revert InsufficientTicket();
        }

        
        
        if (activities[_activityId].remainingRewardSupply < _ticketAmount) {
            revert InsufficientReward();
        }

        
        TicketContract.burn(
            activities[_activityId].activityType,
            msg.sender,
            _ticketAmount
        );
        unchecked {
            totalCompleteDraws++;
        }

        
        for (
            uint256 ticketAmountIndex = 0;
            ticketAmountIndex < _ticketAmount;
            ticketAmountIndex = _uncheckedIncOne(ticketAmountIndex)
        ) {
            uint256 randomIndex = getRandomNumber(
                activities[_activityId].remainingRewardSupply
            );

            uint256 selectedTokenId;
            uint256 indexCount;

            
            for (
                uint256 rewardTokenIndex = 0;
                rewardTokenIndex <
                activities[_activityId].rewardTokenIds.length;
                rewardTokenIndex = _uncheckedIncOne(rewardTokenIndex)
            ) {
                uint256 toBeMintedId = activities[_activityId]
                    .maximumRewardSupply[rewardTokenIndex] -
                    activities[_activityId].totalGivenRewardSupply[
                        rewardTokenIndex
                    ];
                indexCount = _uncheckedIncDelta(indexCount, toBeMintedId);
                if (toBeMintedId > 0 && indexCount >= randomIndex) {
                    selectedTokenId = activities[_activityId].rewardTokenIds[
                        rewardTokenIndex
                    ];
                    activities[_activityId].totalGivenRewardSupply[rewardTokenIndex] = 
                    _uncheckedIncOne(
                        activities[_activityId].totalGivenRewardSupply[rewardTokenIndex]
                    );
                    break;
                }
            }

            
            RewardContract.mint(
                ticketAmountIndex + 1,
                totalCompleteDraws,
                _activityId,
                msg.sender,
                selectedTokenId,
                1,
                ""
            );

            unchecked {
                activities[_activityId].remainingRewardSupply--;
                totalRewardWon++;
            }
        }

        emit DrawCompleted(
            _activityId,
            msg.sender,
            activities[_activityId].activityType,
            _ticketAmount,
            totalCompleteDraws
        );
    }

    
    
    
    function getRandomNumber(uint256 _moduler) internal view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number +
                        totalRewardWon
                )
            )
        );

        return (seed - ((seed / _moduler) * _moduler));
    }

    
    
    
    function getTotalRewardSupply(uint256 _activityId)
        external
        view
        returns (uint256[] memory)
    {
        return activities[_activityId].totalGivenRewardSupply;
    }

    
    
    
    function getMaximumRewardSupply(uint256 _activityId)
        external
        view
        returns (uint256[] memory)
    {
        return activities[_activityId].maximumRewardSupply;
    }

    
    
    
    function getRewardTokenIds(uint256 _activityId)
        external
        view
        returns (uint256[] memory)
    {
        return activities[_activityId].rewardTokenIds;
    }

    
    
    
    
    
    function _uncheckedIncOne(uint256 val) internal pure returns (uint256) {
        return _uncheckedIncDelta(val, 1);
    }

    
    
    
    
    
    function _uncheckedIncDelta(uint256 val, uint256 delta)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return val + delta;
        }
    }
}

// 

pragma solidity ^0.8.15;

interface IAnimeMetaverseTicket {
    function burn(
        uint256 tokenId,
        address _account,
        uint256 _numberofTickets
    ) external;
}

// 

pragma solidity ^0.8.15;

interface IAnimeMetaverseReward {
    function mintBatch(
        uint256 ticket,
        uint256 _drawIndex,
        uint256 _activityId,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) external;

    function mint(
        uint256 ticket,
        uint256 _drawIndex,
        uint256 _activityId,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) external;

    function forceBurn(
        address _account,
        uint256 _id,
        uint256 _amount
    ) external;
}
