// SPDX-License-Identifier: LGPL-3.0-or-later

// 
pragma solidity ^0.8;






/// target addresses that will be assigned a linear token allocation. Claims can be reedemed at any time by the target
/// addresses and can be stopped at any time by the team controller.


contract AllocationModule {
    
    struct VestingPosition {
        
        uint96 totalAmount;
        
        uint96 claimedAmount;
        
        uint32 start;
        
        uint32 duration;
    }

    
    ModuleController public immutable controller;
    
    CowProtocolToken public immutable cow;
    
    CowProtocolVirtualToken public immutable vcow;
    
    mapping(address => VestingPosition) public allocation;

    
    uint256 private constant MAX_UINT_32 = (1 << (32)) - 1;

    
    error DurationMustNotBeZero();
    
    error HasClaimAlready();
    
    error NoClaimAssigned();
    
    error NotAController();
    
    error NotEnoughVestedTokens();
    
    error RevertedCowTransfer();

    
    event ClaimAdded(
        address indexed beneficiary,
        uint32 start,
        uint32 duration,
        uint96 amount
    );
    
    event ClaimStopped(address indexed beneficiary);
    
    event ClaimRedeemed(address indexed beneficiary, uint96 amount);

    
    modifier onlyController() {
        if (msg.sender != address(controller)) {
            revert NotAController();
        }
        _;
    }

    constructor(address _controller, address _vcow) {
        controller = ModuleController(_controller);
        vcow = CowProtocolVirtualToken(_vcow);
        cow = CowProtocolToken(address(vcow.cowToken()));
    }

    
    
    
    
    function addClaim(
        address beneficiary,
        uint32 start,
        uint32 duration,
        uint96 amount
    ) external onlyController {
        if (duration == 0) {
            revert DurationMustNotBeZero();
        }
        if (allocation[beneficiary].totalAmount != 0) {
            revert HasClaimAlready();
        }
        allocation[beneficiary] = VestingPosition({
            totalAmount: amount,
            claimedAmount: 0,
            start: start,
            duration: duration
        });

        emit ClaimAdded(beneficiary, start, duration, amount);
    }

    
    /// former beneficiary.
    
    function stopClaim(address beneficiary) external onlyController {
        // Note: claiming COW might fail, therefore making it impossible to stop the claim. This is not considered an
        // issue as a claiming failure can only occur in the following cases:
        // 1. No claim is available: then nothing needs to be stopped.
        // 2. This module is no longer enabled in the controller.
        // 3. The COW transfer reverts. This means that there weren't enough vCOW tokens to swap for COW and that there
        // aren't enough COW tokens available in the controller. Sending COW tokens to pay out the remaining claim would
        // allow to stop the claim.
        // 4. Math failures (overflow/underflows). No untrusted value is provided to this function, so this is not
        // expected to happen.
        // solhint-disable-next-line not-rely-on-time
        _claimAllCow(beneficiary, block.timestamp);

        delete allocation[beneficiary];

        emit ClaimStopped(beneficiary);
    }

    
    
    function claimAllCow() external returns (uint96) {
        // solhint-disable-next-line not-rely-on-time
        return _claimAllCow(msg.sender, block.timestamp);
    }

    
    function claimCow(uint96 claimedAmount) external {
        address beneficiary = msg.sender;

        (uint96 alreadyClaimedAmount, uint96 fullVestedAmount) = retrieveClaimedAmounts(
            beneficiary,
            // solhint-disable-next-line not-rely-on-time
            block.timestamp
        );

        claimCowFromAmounts(
            beneficiary,
            claimedAmount,
            alreadyClaimedAmount,
            fullVestedAmount
        );
    }

    
    /// were already claimed by the user are not included in the output amount.
    
    
    function claimableCow(address beneficiary) external view returns (uint256) {
        if (allocation[beneficiary].totalAmount == 0) {
            return 0;
        }
        (uint96 alreadyClaimedAmount, uint96 fullVestedAmount) = retrieveClaimedAmounts(
            beneficiary,
            // solhint-disable-next-line not-rely-on-time
            block.timestamp
        );

        return fullVestedAmount - alreadyClaimedAmount;
    }

    
    
    
    
    function _claimAllCow(address beneficiary, uint256 timestampAtClaimingTime)
        internal
        returns (uint96 claimedAmount)
    {
        (
            uint96 alreadyClaimedAmount,
            uint96 fullVestedAmount
        ) = retrieveClaimedAmounts(beneficiary, timestampAtClaimingTime);

        claimedAmount = fullVestedAmount - alreadyClaimedAmount;
        claimCowFromAmounts(
            beneficiary,
            claimedAmount,
            alreadyClaimedAmount,
            fullVestedAmount
        );
    }

    
    /// and how much has already been claimed.
    
    
    
    
    /// amount does not exclude the amount that has already been claimed.
    function retrieveClaimedAmounts(
        address beneficiary,
        uint256 timestampAtClaimingTime
    )
        internal
        view
        returns (uint96 alreadyClaimedAmount, uint96 fullVestedAmount)
    {
        // Destructure caller position as gas efficiently as possible without assembly.
        VestingPosition memory position = allocation[beneficiary];
        uint96 totalAmount = position.totalAmount;
        alreadyClaimedAmount = position.claimedAmount;
        uint32 start = position.start;
        uint32 duration = position.duration;

        if (totalAmount == 0) {
            revert NoClaimAssigned();
        }

        fullVestedAmount = computeClaimableAmount(
            start,
            timestampAtClaimingTime,
            duration,
            totalAmount
        );
    }

    /// Given the parameters of a vesting position, computes how much of the total amount has been vested so far.
    
    
    
    
    
    function computeClaimableAmount(
        uint32 start,
        uint256 current,
        uint32 duration,
        uint96 totalAmount
    ) internal pure returns (uint96) {
        if (current <= start) {
            return 0;
        }
        uint256 elapsedTime = current - start;
        if (elapsedTime >= duration) {
            return totalAmount;
        }
        return uint96((uint256(totalAmount) * elapsedTime) / duration);
    }

    
    /// beneficiary, taking care of updating the claimed amount.
    
    
    
    
    /// was already claimed.
    function claimCowFromAmounts(
        address beneficiary,
        uint96 amount,
        uint96 alreadyClaimedAmount,
        uint96 fullVestedAmount
    ) internal {
        uint96 claimedAfterPayout = alreadyClaimedAmount + amount;
        if (claimedAfterPayout > fullVestedAmount) {
            revert NotEnoughVestedTokens();
        }

        allocation[beneficiary].claimedAmount = claimedAfterPayout;
        swapVcowIfAvailable(amount);
        transferCow(beneficiary, amount);

        emit ClaimRedeemed(beneficiary, amount);
    }

    
    /// COW tokens are left in the module controller. If swapping reverts (which means that not enough vCOW are
    /// available) then the failure is ignored.
    
    function swapVcowIfAvailable(uint256 amount) internal {
        // The success status is explicitely ignored. This means that the call to `swap` could revert without reverting
        // the execution of this function. Note that this function can still revert if the call to
        // `execTransactionFromModule` reverts, which could happen for example if this module is no longer enabled in
        // the controller.
        //bool success =
        controller.execTransactionFromModule(
            address(vcow),
            0,
            abi.encodeWithSelector(vcow.swap.selector, amount),
            Enum.Operation.Call
        );
    }

    
    
    
    function transferCow(address to, uint256 amount) internal {
        // Note: the COW token reverts on failed transfer, there is no need to check the return value.
        bool success = controller.execTransactionFromModule(
            address(cow),
            0,
            abi.encodeWithSelector(cow.transfer.selector, to, amount),
            Enum.Operation.Call
        );
        if (!success) {
            revert RevertedCowTransfer();
        }
    }
}

// 
pragma solidity ^0.8;




interface CowProtocolToken {
    
    /// Returns true. Reverts if the operation didn't succeed.
    function transfer(address to, uint256 amount) external returns (bool);
}




interface CowProtocolVirtualToken {
    
    /// tokens based on the claims previously performed by the caller.
    
    function swap(uint256 amount) external;

    
    /// be converted to this token if this contract stores some balance of it.
    function cowToken() external view returns (address);
}

// 

// Vendored from @gnosis.pm/safe-contracts v1.3.0, see:
// <https://raw.githubusercontent.com/gnosis/safe-contracts/v1.3.0/contracts/common/Enum.sol>

pragma solidity >=0.7.0 <0.9.0;



contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

// 

// A contract interface listing the functions that are exposed by a Gnosis Safe v1.3 to work with modules.
// Vendored from @gnosis.pm/zodiac v1.0.6, see:
// <https://raw.githubusercontent.com/gnosis/zodiac/d9b1180436609f6c0a1fc93009d9c28d214fd971/contracts/interfaces/IAvatar.sol>
// Changes:
// - Renamed contract to `ModuleController` to make the interface purpose clearer when imported.
// - Vendored imports.


pragma solidity >=0.7.0 <0.9.0;



interface ModuleController {
    
    
    
    
    
    function enableModule(address module) external;

    
    
    
    
    
    function disableModule(address prevModule, address module) external;

    
    
    
    
    
    
    
    
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);

    
    
    
    
    
    
    
    
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success, bytes memory returnData);

    
    
    function isModuleEnabled(address module) external view returns (bool);

    
    
    
    
    
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);
}