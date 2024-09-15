// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-09-14
*/

// 

pragma solidity 0.8.11;

// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol
// Simplified by BoringCrypto

contract BoringOwnableData {
    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    
    /// Can only be invoked by the current `owner`.
    
    
    
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

contract PoWD is BoringOwnable {
    error Error_NotETHPoS();
    error Error_TooLateMergeAboutToHappen();
    error Error_LetTheMergeHappenProperly();
    error Error_RewardsNotActiveYet();
    error Error_AlreadyRugged();
    error Error_NoRugOnETHPoS();
    error Error_AlreadyActivatedRewards();
    error Error_AsExpectedFatFinger();

    uint72 private constant DIFFICULTY_THRESHOLD = 2**64;
    uint128 public rewardValue;
    uint128 public totalRewardPosition;
    bool public isRugged;
    bool public rewardsActive;
    mapping(address => uint128) public rewardPosition;
    mapping(address => uint128) public userPosition;

    modifier onlyETHPoS() {
        if (block.chainid != 1) revert Error_NotETHPoS();
        _;
    }

    function deposit() external payable onlyETHPoS {
        if (merged()) revert Error_TooLateMergeAboutToHappen();

        uint128 amount = uint128(msg.value);

        userPosition[msg.sender] += amount;
        rewardPosition[msg.sender] += amount;
        totalRewardPosition += amount;
    }

    function withdraw() external onlyETHPoS {
        if (!merged()) revert Error_LetTheMergeHappenProperly();

        if (rewardPosition[msg.sender] > 0 && rewardsActive == true)
            claimRewards();

        uint256 amount = userPosition[msg.sender];
        userPosition[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }

    function claimRewards() public onlyETHPoS {
        if (rewardsActive != true) revert Error_RewardsNotActiveYet();

        uint128 amount = rewardPosition[msg.sender];
        uint128 what = (amount * rewardValue) / totalRewardPosition;

        rewardPosition[msg.sender] = 0;
        rewardValue -= what;
        totalRewardPosition -= amount;
        payable(msg.sender).transfer(what);
    }

    function rug() external onlyOwner {
        if (isRugged != false) revert Error_AlreadyRugged();
        if (block.chainid == 1) revert Error_NoRugOnETHPoS();
        isRugged = true;
        payable(msg.sender).transfer(address(this).balance);
    }

    function addReward(uint128 amount) external payable onlyETHPoS onlyOwner {
        if (rewardsActive != false) revert Error_AlreadyActivatedRewards();
        if (amount != msg.value) revert Error_AsExpectedFatFinger();
        rewardsActive = true;
        rewardValue = amount;
    }

    function merged() public view returns (bool) {
        return block.difficulty > DIFFICULTY_THRESHOLD;
    }
}