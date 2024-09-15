// SPDX-License-Identifier: BUSL-1.1


// 
pragma solidity 0.8.7;

interface IPoolDelegateCover {

    /**
     *  @dev    Gets the address of the funds asset.
     *  @return asset_ The address of the funds asset.
     */
    function asset() external view returns(address asset_);

    /**
     *  @dev    Gets the address of the pool manager.
     *  @return poolManager_ The address of the pool manager.
     */
    function poolManager() external view returns(address poolManager_);

    /**
     *  @dev   Move funds from this address to another.
     *  @param amount_    The amount to move.
     *  @param recipient_ The address of the recipient.
     */
    function moveFunds(uint256 amount_, address recipient_) external;

}
// 
pragma solidity 0.8.7;





/*

    ██████╗ ██████╗      ██████╗ ██████╗ ██╗   ██╗███████╗██████╗
    ██╔══██╗██╔══██╗    ██╔════╝██╔═══██╗██║   ██║██╔════╝██╔══██╗
    ██████╔╝██║  ██║    ██║     ██║   ██║██║   ██║█████╗  ██████╔╝
    ██╔═══╝ ██║  ██║    ██║     ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗
    ██║     ██████╔╝    ╚██████╗╚██████╔╝ ╚████╔╝ ███████╗██║  ██║
    ╚═╝     ╚═════╝      ╚═════╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝

*/

contract PoolDelegateCover is IPoolDelegateCover {

    address public override asset;
    address public override poolManager;

    constructor(address poolManager_, address asset_) {
        require((poolManager = poolManager_) != address(0), "PDC:C:ZERO_PM_ADDRESS");
        require((asset       = asset_)       != address(0), "PDC:C:ZERO_A_ADDRESS");
    }

    function moveFunds(uint256 amount_, address recipient_) external override {
        require(msg.sender == poolManager,                        "PDC:MF:NOT_MANAGER");
        require(ERC20Helper.transfer(asset, recipient_, amount_), "PDC:MF:TRANSFER_FAILED");
    }

}

// 
pragma solidity ^0.8.7;



/**
 * @title Small Library to standardize erc20 token interactions.
 */
library ERC20Helper {

    /**************************/
    /*** Internal Functions ***/
    /**************************/

    function transfer(address token_, address to_, uint256 amount_) internal returns (bool success_) {
        return _call(token_, abi.encodeWithSelector(IERC20Like.transfer.selector, to_, amount_));
    }

    function transferFrom(address token_, address from_, address to_, uint256 amount_) internal returns (bool success_) {
        return _call(token_, abi.encodeWithSelector(IERC20Like.transferFrom.selector, from_, to_, amount_));
    }

    function approve(address token_, address spender_, uint256 amount_) internal returns (bool success_) {
        // If setting approval to zero fails, return false.
        if (!_call(token_, abi.encodeWithSelector(IERC20Like.approve.selector, spender_, uint256(0)))) return false;

        // If `amount_` is zero, return true as the previous step already did this.
        if (amount_ == uint256(0)) return true;

        // Return the result of setting the approval to `amount_`.
        return _call(token_, abi.encodeWithSelector(IERC20Like.approve.selector, spender_, amount_));
    }

    function _call(address token_, bytes memory data_) private returns (bool success_) {
        if (token_.code.length == uint256(0)) return false;

        bytes memory returnData;
        ( success_, returnData ) = token_.call(data_);

        return success_ && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));
    }

}

// 
pragma solidity ^0.8.7;


interface IERC20Like {

    function approve(address spender_, uint256 amount_) external returns (bool success_);

    function transfer(address recipient_, uint256 amount_) external returns (bool success_);

    function transferFrom(address owner_, address recipient_, uint256 amount_) external returns (bool success_);

}