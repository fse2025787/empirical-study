// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-08-09
*/

//
pragma solidity 0.8.1;

interface IERC20_Vesting {
  
  function issue_into_tranche(address user, uint8 tranche_id, uint256 amount) external;
}





contract Claim_Codes {

  event Issuer_Permitted(address indexed issuer, uint256 amount);
  event Issuer_Revoked(address indexed issuer);
  event Controller_Set(address indexed new_controller);
  event Claimed(bytes32 indexed message_hash);

  
  address public controller;
  
  address public vesting_address;
  
  mapping(uint256 => bool) public nonces;
  
  mapping(bytes2 => bool) public allowed_countries;
  
  
  mapping(bytes32 => bool) public commits;
  
  mapping(address => uint256) public permitted_issuance;

  
  
  
  constructor(address _vesting_address, address _controller){
    controller = _controller;
    vesting_address = _vesting_address;
    emit Controller_Set(_controller);
  }

  
  
  function block_countries(bytes2[] calldata country_codes) public only_controller {
    for (uint256 i = 0; i < country_codes.length; i++) {
      allowed_countries[country_codes[i]] = false;
    }
  }

  
  
  function allow_countries(bytes2[] calldata country_codes) public only_controller {
    for (uint256 i = 0; i < country_codes.length; i++) {
      allowed_countries[country_codes[i]] = true;
    }
  }

  function verify_signature(bytes calldata claim_code, bytes32 message_hash) internal pure returns(address) {
    //recover address from that msg
    bytes32 r;
    bytes32 s;
    uint8 v;

      assembly {
        // first 32 bytes, after the length prefix
       r := calldataload(claim_code.offset)
       // second 32 bytes
       s := calldataload(add(claim_code.offset, 32))
       // final byte (first byte of the next 32 bytes)
       v := byte(0,calldataload(add(claim_code.offset, 64)))
      }
    // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
    // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
    // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
    // signatures from current libraries generate a unique signature with an s-value in the lower half order.
    //
    // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
    // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
    // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
    // these malleable signatures as well.
    require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "Mallable signature error");

    if (v < 27) v += 27;

    return ecrecover(message_hash, v, r, s);
  }

  
  
  
  
  
  
  
  
  
  
  
  
  function redeem_targeted(bytes calldata claim_code, uint256 denomination, uint8 tranche, uint256 expiry, uint256 nonce, bytes2 country_code) public {
    require(expiry == 0 || block.timestamp <= expiry, "this code has expired");
    require(!nonces[nonce], "already redeemed");
    require(allowed_countries[country_code], "restricted country");

    bytes32 message_hash = keccak256(abi.encode(denomination, tranche, expiry, nonce, msg.sender));

    address recovered_address = verify_signature(claim_code, message_hash);
    require(recovered_address != address(0), "bad claim code");
    require(recovered_address != msg.sender, "cannot issue to self");
    if(permitted_issuance[recovered_address] > 0){
      
      require(permitted_issuance[recovered_address] >= denomination, "not enough permitted balance");
      permitted_issuance[recovered_address] -= denomination;
    } else {
      require(recovered_address == controller, "unauthorized issuer");
    }

    nonces[nonce] = true;
    IERC20_Vesting(vesting_address).issue_into_tranche(msg.sender, tranche, denomination);
    emit Claimed(message_hash);
  }

  
  
  
  function get_code_hash(bytes memory claim_code) public view returns (bytes32){
    return keccak256(abi.encode(claim_code, msg.sender));
  }

  
  
  
  function commit_untargeted_code(bytes32 hash) public {
    commits[hash] = true;
  }

  
  
  
  
  
  
  
  
  
  
  
  
  function redeem_untargeted_code(bytes calldata claim_code, uint256 denomination, uint8 tranche, uint256 expiry, uint256 nonce, bytes2 country_code) public {
    require(expiry == 0 || block.timestamp <= expiry, "this code has expired");
    require(!nonces[nonce], "already redeemed");
    require(allowed_countries[country_code], "restricted country");

    bytes32 message_hash = keccak256(abi.encode(denomination, tranche, expiry, nonce));
    bytes32 commit_msg = keccak256(abi.encode(claim_code, msg.sender));
    require(commits[commit_msg], "code has not been commited");

    address recovered_address = verify_signature(claim_code, message_hash);
    require(recovered_address != address(0), "bad claim code");
    require(recovered_address != msg.sender, "cannot issue to self");
    if(permitted_issuance[recovered_address] > 0){
      
      require(permitted_issuance[recovered_address] >= denomination, "not enough permitted balance");
      permitted_issuance[recovered_address] -= denomination;
    } else {
      require(recovered_address == controller, "unauthorized issuer");
    }
    delete(commits[commit_msg]);
    nonces[nonce] = true;
    IERC20_Vesting(vesting_address).issue_into_tranche(msg.sender, tranche, denomination);
    emit Claimed(message_hash);
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
    permitted_issuance[new_controller] = 0;
    emit Controller_Set(new_controller);
  }

  modifier only_controller {
         require( msg.sender == controller, "not controller" );
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