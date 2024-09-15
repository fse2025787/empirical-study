// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-11-07
*/

// File: contracts/IMultisigControl.sol

//
pragma solidity 0.8.8;





abstract contract IMultisigControl {

    /***************************EVENTS****************************/
    event SignerAdded(address new_signer, uint256 nonce);
    event SignerRemoved(address old_signer, uint256 nonce);
    event ThresholdSet(uint16 new_threshold, uint256 nonce);

    /**************************FUNCTIONS*********************/
    
    
    
    
    
    
    
    
    function set_threshold(uint16 new_threshold, uint nonce, bytes calldata signatures) public virtual;

    
    
    
    
    
    
    function add_signer(address new_signer, uint nonce, bytes calldata signatures) public virtual;

    
    
    
    
    
    
    function remove_signer(address old_signer, uint nonce, bytes calldata signatures) public virtual;

    
    
    
    
    
    
    
    
    function verify_signatures(bytes calldata signatures, bytes memory message, uint nonce) public virtual returns(bool);

    /**********************VIEWS*********************/
    
    function get_valid_signer_count() public virtual view returns(uint8);

    
    function get_current_threshold() public virtual view returns(uint16);

    
    
    function is_valid_signer(address signer_address) public virtual view returns(bool);

    
    
    function is_nonce_used(uint nonce) public virtual view returns(bool);
}

/**
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMWEMMMMMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMLOVEMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMMMMMHIXELMMMMMMMMMMMM....................MMMMMNNMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMM....................MMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMM88=........................+MMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMM.........................MM+..MMM....+MMMMMMMMMM
MMMMMMMMMNMM...................... ..MM?..MMM.. .+MMMMMMMMMM
MMMMNDDMM+........................+MM........MM..+MMMMMMMMMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................DDD
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MM..............................MMZ....ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM......................ZMMMMM.......MMMMMMMMMMMMMMMMMMMMMMM
MM............... ......ZMMMMM.... ..MMMMMMMMMMMMMMMMMMMMMMM
MM...............MMMMM88~.........+MM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......ZMMMMMMM.......ZMMMMM..MMMMM..ZMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

// File: contracts/IERC20_Bridge_Logic.sol





// @notice All funds deposited/withdrawn are to/from the ERC20_Asset_Pool
abstract contract IERC20_Bridge_Logic {

    /***************************EVENTS****************************/
    event Asset_Withdrawn(address indexed user_address, address indexed asset_source, uint256 amount, uint256 nonce);
    event Asset_Deposited(address indexed user_address, address indexed asset_source, uint256 amount, bytes32 vega_public_key);
    event Asset_Deposit_Minimum_Set(address indexed asset_source,  uint256 new_minimum, uint256 nonce);
    event Asset_Deposit_Maximum_Set(address indexed asset_source,  uint256 new_maximum, uint256 nonce);
    event Asset_Listed(address indexed asset_source,  bytes32 indexed vega_asset_id, uint256 nonce);
    event Asset_Removed(address indexed asset_source,  uint256 nonce);

    /***************************FUNCTIONS*************************/
    
    
    
    
    
    
    
    function list_asset(address asset_source, bytes32 vega_asset_id, uint256 nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    function remove_asset(address asset_source, uint256 nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    
    function set_deposit_minimum(address asset_source, uint256 minimum_amount, uint256 nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    
    function set_deposit_maximum(address asset_source, uint256 maximum_amount, uint256 nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    
    
    function withdraw_asset(address asset_source, uint256 amount, address target, uint256 nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    
    function deposit_asset(address asset_source, uint256 amount, bytes32 vega_public_key) public virtual;

    /***************************VIEWS*****************************/
    
    
    
    function is_asset_listed(address asset_source) public virtual view returns(bool);

    
    
    
    function get_deposit_minimum(address asset_source) public virtual view returns(uint256);

    
    
    
    function get_deposit_maximum(address asset_source) public virtual view returns(uint256);

    
    function get_multisig_control_address() public virtual view returns(address);

    
    
    function get_vega_asset_id(address asset_source) public virtual view returns(bytes32);

    
    
    function get_asset_source(bytes32 vega_asset_id) public virtual view returns(address);

}

/**
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMWEMMMMMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMLOVEMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMMMMMHIXELMMMMMMMMMMMM....................MMMMMNNMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMM....................MMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMM88=........................+MMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMM.........................MM+..MMM....+MMMMMMMMMM
MMMMMMMMMNMM...................... ..MM?..MMM.. .+MMMMMMMMMM
MMMMNDDMM+........................+MM........MM..+MMMMMMMMMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................DDD
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MM..............................MMZ....ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM......................ZMMMMM.......MMMMMMMMMMMMMMMMMMMMMMM
MM............... ......ZMMMMM.... ..MMMMMMMMMMMMMMMMMMMMMMM
MM...............MMMMM88~.........+MM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......ZMMMMMMM.......ZMMMMM..MMMMM..ZMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

// File: contracts/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/ERC20_Asset_Pool.sol





contract ERC20_Asset_Pool {

    event Multisig_Control_Set(address indexed new_address);
    event Bridge_Address_Set(address indexed new_address);

    
    address public multisig_control_address;

    
    address public erc20_bridge_address;

    
    
    constructor(address multisig_control) {
        multisig_control_address = multisig_control;
        emit Multisig_Control_Set(multisig_control);
    }

    
    receive() external payable {
      revert("this contract does not accept ETH");
    }

    
    
    
    
    
    function set_multisig_control(address new_address, uint256 nonce, bytes memory signatures) public {
        require(new_address != address(0));
        bytes memory message = abi.encode(new_address, nonce, 'set_multisig_control');
        require(IMultisigControl(multisig_control_address).verify_signatures(signatures, message, nonce), "bad signatures");
        multisig_control_address = new_address;
        emit Multisig_Control_Set(new_address);
    }

    
    
    
    
    
    function set_bridge_address(address new_address, uint256 nonce, bytes memory signatures) public {
        bytes memory message = abi.encode(new_address, nonce, 'set_bridge_address');
        require(IMultisigControl(multisig_control_address).verify_signatures(signatures, message, nonce), "bad signatures");
        erc20_bridge_address = new_address;
        emit Bridge_Address_Set(new_address);
    }

    
    
    
    
    
    
    function withdraw(address token_address, address target, uint256 amount) public returns(bool) {
        require(msg.sender == erc20_bridge_address, "msg.sender not authorized bridge");

        IERC20(token_address).transfer(target, amount);
        
        bool result;
        assembly {
           switch returndatasize()
               case 0 {                      // no return value but didn't revert
                   result := true
               }
               case 32 {                     // standard ERC20, has return value
                   returndatacopy(0, 0, 32)
                   result := mload(0)        // result is result of transfer call
               }
               default {}
       }
       require(result, "token transfer failed"); // revert() if result is false

      return true;
    }
}

/**
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMWEMMMMMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMLOVEMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMMMMMHIXELMMMMMMMMMMMM....................MMMMMNNMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMM....................MMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMM88=........................+MMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMM.........................MM+..MMM....+MMMMMMMMMM
MMMMMMMMMNMM...................... ..MM?..MMM.. .+MMMMMMMMMM
MMMMNDDMM+........................+MM........MM..+MMMMMMMMMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................DDD
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MM..............................MMZ....ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM......................ZMMMMM.......MMMMMMMMMMMMMMMMMMMMMMM
MM............... ......ZMMMMM.... ..MMMMMMMMMMMMMMMMMMMMMMM
MM...............MMMMM88~.........+MM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......ZMMMMMMM.......ZMMMMM..MMMMM..ZMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/

// File: contracts/ERC20_Bridge_Logic.sol






// @notice All funds deposited/withdrawn are to/from the assigned ERC20_Asset_Pool
contract ERC20_Bridge_Logic is IERC20_Bridge_Logic {

    address multisig_control_address;
    address payable erc20_asset_pool_address;
    // asset address => is listed
    mapping(address => bool) listed_tokens;
    // asset address => minimum deposit amt
    mapping(address => uint256) minimum_deposits;
    // asset address => maximum deposit amt
    mapping(address => uint256) maximum_deposits;
    // Vega asset ID => asset_source
    mapping(bytes32 => address) vega_asset_ids_to_source;
    // asset_source => Vega asset ID
    mapping(address => bytes32) asset_source_to_vega_asset_id;

    
    
    constructor(address payable erc20_asset_pool, address multisig_control) {
        erc20_asset_pool_address = erc20_asset_pool;
        multisig_control_address = multisig_control;
    }

    /***************************FUNCTIONS*************************/
    
    
    
    
    
    
    
    function list_asset(address asset_source, bytes32 vega_asset_id, uint256 nonce, bytes memory signatures) public override {
        require(!listed_tokens[asset_source], "asset already listed");
        bytes memory message = abi.encode(asset_source, vega_asset_id, nonce, 'list_asset');
        require(IMultisigControl(multisig_control_address).verify_signatures(signatures, message, nonce), "bad signatures");
        listed_tokens[asset_source] = true;
        vega_asset_ids_to_source[vega_asset_id] = asset_source;
        asset_source_to_vega_asset_id[asset_source] = vega_asset_id;
        emit Asset_Listed(asset_source, vega_asset_id, nonce);
    }

    
    
    
    
    
    
    function remove_asset(address asset_source, uint256 nonce, bytes memory signatures) public override {
        require(listed_tokens[asset_source], "asset not listed");
        bytes memory message = abi.encode(asset_source, nonce, 'remove_asset');
        require(IMultisigControl(multisig_control_address).verify_signatures(signatures, message, nonce), "bad signatures");
        listed_tokens[asset_source] = false;
        emit Asset_Removed(asset_source, nonce);
    }

    
    
    
    
    
    
    
    function set_deposit_minimum(address asset_source, uint256 minimum_amount, uint256 nonce, bytes memory signatures) public override{
        require(listed_tokens[asset_source], "asset not listed");
        bytes memory message = abi.encode(asset_source, minimum_amount, nonce, 'set_deposit_minimum');
        require(IMultisigControl(multisig_control_address).verify_signatures(signatures, message, nonce), "bad signatures");
        minimum_deposits[asset_source] = minimum_amount;
        emit Asset_Deposit_Minimum_Set(asset_source, minimum_amount, nonce);
    }

    
    
    
    
    
    
    
    function set_deposit_maximum(address asset_source, uint256 maximum_amount, uint256 nonce, bytes memory signatures) public override {
        require(listed_tokens[asset_source], "asset not listed");
        bytes memory message = abi.encode(asset_source, maximum_amount, nonce, 'set_deposit_maximum');
        require(IMultisigControl(multisig_control_address).verify_signatures(signatures, message, nonce), "bad signatures");
        maximum_deposits[asset_source] = maximum_amount;
        emit Asset_Deposit_Maximum_Set(asset_source, maximum_amount, nonce);
    }

    
    
    
    
    
    
    
    
    function withdraw_asset(address asset_source, uint256 amount, address target, uint256 nonce, bytes memory signatures) public  override{
        bytes memory message = abi.encode(asset_source, amount, target,  nonce, 'withdraw_asset');
        require(IMultisigControl(multisig_control_address).verify_signatures(signatures, message, nonce), "bad signatures");
        require(ERC20_Asset_Pool(erc20_asset_pool_address).withdraw(asset_source, target, amount), "token didn't transfer, rejected by asset pool.");
        emit Asset_Withdrawn(target, asset_source, amount, nonce);
    }

    
    
    
    
    
    
    
    function deposit_asset(address asset_source, uint256 amount, bytes32 vega_public_key) public override {
        require(listed_tokens[asset_source], "asset not listed");
        //User must run approve before deposit
        require(maximum_deposits[asset_source] == 0 || amount <= maximum_deposits[asset_source], "deposit above maximum");
        require(amount >= minimum_deposits[asset_source], "deposit below minimum");
        require(IERC20(asset_source).transferFrom(msg.sender, erc20_asset_pool_address, amount), "transfer failed in deposit");
        emit Asset_Deposited(msg.sender, asset_source, amount, vega_public_key);
    }

    /***************************VIEWS*****************************/
    
    
    
    function is_asset_listed(address asset_source) public override view returns(bool){
        return listed_tokens[asset_source];
    }

    
    
    
    function get_deposit_minimum(address asset_source) public override view returns(uint256){
        return minimum_deposits[asset_source];
    }

    
    
    
    function get_deposit_maximum(address asset_source) public override view returns(uint256){
        return maximum_deposits[asset_source];
    }

    
    function get_multisig_control_address() public override view returns(address) {
        return multisig_control_address;
    }

    
    
    function get_vega_asset_id(address asset_source) public override view returns(bytes32){
        return asset_source_to_vega_asset_id[asset_source];
    }

    
    
    function get_asset_source(bytes32 vega_asset_id) public override view returns(address){
        return vega_asset_ids_to_source[vega_asset_id];
    }
}

/**
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMWEMMMMMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMLOVEMMMMMMMMMMMMMMMMMMMMMM...............MMMMMMMMMMMMM
MMMMMMMMMMHIXELMMMMMMMMMMMM....................MMMMMNNMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMM....................MMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMM88=........................+MMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMM....................MMMMM...MMMMMMMMMMMMMMM
MMMMMMMMMMMM.........................MM+..MMM....+MMMMMMMMMM
MMMMMMMMMNMM...................... ..MM?..MMM.. .+MMMMMMMMMM
MMMMNDDMM+........................+MM........MM..+MMMMMMMMMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................MMM
MMMMZ.............................+MM....................DDD
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MMMMZ.............................+MM..ZMMMMMMMMMMMMMMMMMMMM
MM..............................MMZ....ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM............................MM.......ZMMMMMMMMMMMMMMMMMMMM
MM......................ZMMMMM.......MMMMMMMMMMMMMMMMMMMMMMM
MM............... ......ZMMMMM.... ..MMMMMMMMMMMMMMMMMMMMMMM
MM...............MMMMM88~.........+MM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......$DDDDDDD.......$DDDDD..DDNMM..ZMMMMMMMMMMMMMMMMMMMM
MM.......ZMMMMMMM.......ZMMMMM..MMMMM..ZMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMM+.......MMMMM88NMMMMM..MMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/