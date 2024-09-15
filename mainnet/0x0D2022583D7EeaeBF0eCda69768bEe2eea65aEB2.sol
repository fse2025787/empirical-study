// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-07-15
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-14
*/

//
pragma solidity 0.8.1;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


/**
 * @dev Interface contains all of the events necessary for staking Vega token
 */
interface IStake {
  event Stake_Deposited(address indexed user, uint256 amount, bytes32 indexed vega_public_key);
  event Stake_Removed(address indexed user, uint256 amount, bytes32 indexed vega_public_key);
  event Stake_Transferred(address indexed from, uint256 amount, address indexed to, bytes32 indexed vega_public_key);

  
  function staking_token() external view returns (address);

  
  
  
  function stake_balance(address target, bytes32 vega_public_key) external view returns (uint256);


  
  function total_staked() external view returns (uint256);
}





contract ERC20_Vesting is IStake {

  event Tranche_Created(uint8 indexed tranche_id, uint256 cliff_start, uint256 duration);
  event Tranche_Balance_Added(address indexed user, uint8 indexed tranche_id, uint256 amount);
  event Tranche_Balance_Removed(address indexed user, uint8 indexed tranche_id, uint256 amount);
  event Issuer_Permitted(address indexed issuer, uint256 amount);
  event Issuer_Revoked(address indexed issuer);
  event Controller_Set(address indexed new_controller);

  
  address public controller;
  
  uint8 public tranche_count = 1;
  
  mapping(address => bool) public v1_migrated;
  
  mapping(address=> user_stat) public user_stats;

  
  uint256 public total_locked;
  
  address public v1_address; // mainnet = 0xD249B16f61cB9489Fe0Bb046119A48025545b58a;
  
  address public v2_address;
  
  uint256 constant public accuracy_scale = 100000000000;
  
  uint8 constant public default_tranche_id = 0;
  
  uint256 total_staked_tokens;

  /****ADDRESS MIGRATION**/
  
  mapping(address => address) public address_migration;
  /*****/

  
  
  
  constructor(address token_v1_address, address token_v2_address, address[] memory old_addresses, address[] memory new_addresses) {
    require(old_addresses.length == new_addresses.length, "array length mismatch");

    for(uint8 map_idx = 0; map_idx < old_addresses.length; map_idx++) {
      
      require(!v1_migrated[old_addresses[map_idx]]);
      v1_migrated[old_addresses[map_idx]] = true;
      address_migration[new_addresses[map_idx]] = old_addresses[map_idx];
    }

    v1_address = token_v1_address;
    
    total_locked = IERC20(token_v1_address).totalSupply() - IERC20(token_v1_address).balanceOf(token_v1_address);
    v2_address = token_v2_address;
    controller = msg.sender;
    emit Controller_Set(controller);
  }

  
  
  
  struct tranche_balance {
      uint256 total_deposited;
      uint256 total_claimed;
  }

  
  
  
  
  struct user_stat {
    uint256 total_in_all_tranches;
    uint256 lien;
    mapping (uint8 => tranche_balance) tranche_balances;
    mapping(bytes32 => uint256) stake;
  }

  
  
  
  struct tranche {
    uint256 cliff_start;
    uint256 duration;
  }

  
  mapping(uint8 => tranche) public tranches;
  
  mapping(address => uint256) public permitted_issuance;

  
  
  
  
  function create_tranche(uint256 cliff_start, uint256 duration) public only_controller {
    tranches[tranche_count] = tranche(cliff_start, duration);
    emit Tranche_Created(tranche_count, cliff_start, duration);
    
    tranche_count++;
  }

  
  
  
  
  
  
  
  function issue_into_tranche(address user, uint8 tranche_id, uint256 amount) public controller_or_issuer {
    require(tranche_id < tranche_count, "tranche_id out of bounds");
    if(permitted_issuance[msg.sender] > 0){
      
      require(permitted_issuance[msg.sender] >= amount, "not enough permitted balance");
      require(user != msg.sender, "cannot issue to self");
      permitted_issuance[msg.sender] -= amount;
    }
    require( IERC20(v2_address).balanceOf(address(this)) - (total_locked + amount) >= 0, "contract token balance low" );

    
    if(!v1_migrated[user]){
      uint256 bal = v1_bal(user);
      user_stats[user].tranche_balances[0].total_deposited += bal;
      user_stats[user].total_in_all_tranches += bal;
      v1_migrated[user] = true;
    }
    user_stats[user].tranche_balances[tranche_id].total_deposited += amount;
    user_stats[user].total_in_all_tranches += amount;
    total_locked += amount;
    emit Tranche_Balance_Added(user, tranche_id, amount);
  }


  
  
  
  
  
  
  
  function move_into_tranche(address user, uint8 tranche_id, uint256 amount) public only_controller {
    require(tranche_id > 0 && tranche_id < tranche_count);

    
    if(!v1_migrated[user]){
      uint256 bal = v1_bal(user);
      user_stats[user].tranche_balances[default_tranche_id].total_deposited += bal;
      user_stats[user].total_in_all_tranches += bal;
      v1_migrated[user] = true;
    }
    require(user_stats[user].tranche_balances[default_tranche_id].total_deposited >= amount);
    user_stats[user].tranche_balances[default_tranche_id].total_deposited -= amount;
    user_stats[user].tranche_balances[tranche_id].total_deposited += amount;
    emit Tranche_Balance_Removed(user, default_tranche_id, amount);
    emit Tranche_Balance_Added(user, tranche_id, amount);
  }

  
  
  
  
  
  function get_tranche_balance(address user, uint8 tranche_id) public view returns(uint256) {
    if(tranche_id == default_tranche_id && !v1_migrated[user]){
      return v1_bal(user);
    } else {
      return user_stats[user].tranche_balances[tranche_id].total_deposited - user_stats[user].tranche_balances[tranche_id].total_claimed;
    }
  }

  
  
  
  
  
  function get_vested_for_tranche(address user, uint8 tranche_id) public view returns(uint256) {
    if(block.timestamp < tranches[tranche_id].cliff_start){
      return 0;
    }
    else if(block.timestamp > tranches[tranche_id].cliff_start + tranches[tranche_id].duration || tranches[tranche_id].duration == 0){
      return user_stats[user].tranche_balances[tranche_id].total_deposited -  user_stats[user].tranche_balances[tranche_id].total_claimed;
    } else {
      return (((( accuracy_scale * (block.timestamp - tranches[tranche_id].cliff_start) )  / tranches[tranche_id].duration
          ) * user_stats[user].tranche_balances[tranche_id].total_deposited
        ) / accuracy_scale ) - user_stats[user].tranche_balances[tranche_id].total_claimed;
    }
  }

  
  
  
  
  function v1_bal(address user) internal view returns(uint256) {
    if(!v1_migrated[user]){
      if(address_migration[user] != address(0)){
        return IERC20(v1_address).balanceOf(user) + IERC20(v1_address).balanceOf(address_migration[user]);
      } else {
        return IERC20(v1_address).balanceOf(user);
      }
    } else {
      return 0;
    }
  }

  
  
  
  
  function user_total_all_tranches(address user) public view returns(uint256){
    return user_stats[user].total_in_all_tranches + v1_bal(user);
  }

  
  
  
  
  function withdraw_from_tranche(uint8 tranche_id) public {
    require(tranche_id != default_tranche_id);
    uint256 to_withdraw = get_vested_for_tranche(msg.sender, tranche_id);
    require(user_stats[msg.sender].total_in_all_tranches - to_withdraw >=  user_stats[msg.sender].lien);
    user_stats[msg.sender].tranche_balances[tranche_id].total_claimed += to_withdraw;
    
    user_stats[msg.sender].total_in_all_tranches -= to_withdraw;
    
    total_locked -= to_withdraw;
    require(IERC20(v2_address).transfer(msg.sender, to_withdraw));
    emit Tranche_Balance_Removed(msg.sender, tranche_id, to_withdraw);
  }

  
  
  
  
  
  
  
  
  function assisted_withdraw_from_tranche(uint8 tranche_id, address target) public only_controller {
    require(tranche_id != default_tranche_id);
    uint256 to_withdraw = get_vested_for_tranche(target, tranche_id);
    require(user_stats[target].total_in_all_tranches - to_withdraw >=  user_stats[target].lien);
    user_stats[target].tranche_balances[tranche_id].total_claimed += to_withdraw;
    
    user_stats[target].total_in_all_tranches -= to_withdraw;
    
    total_locked -= to_withdraw;
    require(IERC20(v2_address).transfer(target, to_withdraw));
    emit Tranche_Balance_Removed(target, tranche_id, to_withdraw);
  }


  
  
  
  
  function stake_tokens(uint256 amount, bytes32 vega_public_key) public {
    require(user_stats[msg.sender].lien + amount > user_stats[msg.sender].lien);
    require(user_total_all_tranches(msg.sender) >= user_stats[msg.sender].lien + amount);
    
    user_stats[msg.sender].lien += amount;
    user_stats[msg.sender].stake[vega_public_key] += amount;
    total_staked_tokens += amount;
    emit Stake_Deposited(msg.sender, amount, vega_public_key);
  }

  
  
  
  
  
  function remove_stake(uint256 amount, bytes32 vega_public_key) public {
    
    user_stats[msg.sender].stake[vega_public_key] -= amount;
    
    user_stats[msg.sender].lien -= amount;
    total_staked_tokens -= amount;
    emit Stake_Removed(msg.sender, amount, vega_public_key);
  }

  
  
  
  
  
  function permit_issuer(address issuer, uint256 amount) public only_controller {
    
    require(amount > 0, "amount must be > 0");
    require(permitted_issuance[issuer] == 0, "issuer already permitted, revoke first");
    require(controller != issuer, "controller cannot be permitted issuer");
    permitted_issuance[issuer] = amount;
    emit Issuer_Permitted(issuer, amount);
  }

  
  
  
  
  function revoke_issuer(address issuer) public only_controller {
    require(permitted_issuance[issuer] != 0, "issuer already revoked");
    permitted_issuance[issuer] = 0;
    emit Issuer_Revoked(issuer);
  }

  
  
  
  function set_controller(address new_controller) public only_controller {
    controller = new_controller;
    if(permitted_issuance[new_controller] > 0){
      permitted_issuance[new_controller] = 0;
      emit Issuer_Revoked(new_controller);
    }
    emit Controller_Set(new_controller);
  }

  
  
  function staking_token() external override view returns (address) {
    return v2_address;
  }

  
  
  
  
  function stake_balance(address target, bytes32 vega_public_key) external override view returns (uint256) {
    return user_stats[target].stake[vega_public_key];
  }

  
  
  function total_staked() external override view returns (uint256) {
    return total_staked_tokens;
  }

  
  modifier only_controller {
         require( msg.sender == controller, "not controller" );
         _;
  }

  
  modifier controller_or_issuer {
         require( msg.sender == controller || permitted_issuance[msg.sender] > 0,"not controller or issuer" );
         _;
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