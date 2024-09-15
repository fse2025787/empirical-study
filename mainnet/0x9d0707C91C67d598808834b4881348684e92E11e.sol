// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-09-02
*/

//
pragma solidity 0.8.1;





abstract contract IMultisigControl {

    /***************************EVENTS****************************/
    event SignerAdded(address new_signer);
    event SignerRemoved(address old_signer);
    event ThresholdSet(uint16 new_threshold);

    /**************************FUNCTIONS*********************/
    
    
    
    
    
    
    
    
    function set_threshold(uint16 new_threshold, uint nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    function add_signer(address new_signer, uint nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    function remove_signer(address old_signer, uint nonce, bytes memory signatures) public virtual;

    
    
    
    
    
    
    
    
    function verify_signatures(bytes memory signatures, bytes memory message, uint nonce) public virtual returns(bool);

    /**********************VIEWS*********************/
    
    function get_valid_signer_count() public virtual view returns(uint8);

    
    function get_current_threshold() public virtual view returns(uint16);

    
    
    function is_valid_signer(address signer_address) public virtual view returns(bool);

    
    
    function is_nonce_used(uint nonce) public virtual view returns(bool);
}



contract MultisigControl is IMultisigControl {
    constructor () {
        // set initial threshold to 50%
        threshold = 500;
        signers[msg.sender] = true;
        signer_count++;
        emit SignerAdded(msg.sender, 0);
    }

    uint16 threshold;
    uint8 signer_count;
    mapping(address => bool) signers;
    mapping(uint => bool) used_nonces;
    mapping(bytes32 => mapping(address => bool)) has_signed;

    event SignerAdded(address new_signer, uint256 nonce);
    event SignerRemoved(address old_signer, uint256 nonce);
    event ThresholdSet(uint16 new_threshold, uint256 nonce);

    /**************************FUNCTIONS*********************/
    
    
    
    
    
    
    
    
    function set_threshold(uint16 new_threshold, uint256 nonce, bytes memory signatures) public override{
        require(new_threshold <= 1000 && new_threshold > 0, "new threshold outside range");
        bytes memory message = abi.encode(new_threshold, nonce, "set_threshold");
        require(verify_signatures(signatures, message, nonce), "bad signatures");
        threshold = new_threshold;
        emit ThresholdSet(new_threshold, nonce);
    }

    
    
    
    
    
    
    function add_signer(address new_signer, uint256 nonce, bytes memory signatures) public override{
        bytes memory message = abi.encode(new_signer, nonce, "add_signer");
        require(!signers[new_signer], "signer already exists");
        require(verify_signatures(signatures, message, nonce), "bad signatures");
        signers[new_signer] = true;
        signer_count++;
        emit SignerAdded(new_signer, nonce);
    }

    
    
    
    
    
    
    function remove_signer(address old_signer, uint256 nonce, bytes memory signatures) public override {
        bytes memory message = abi.encode(old_signer, nonce, "remove_signer");
        require(signers[old_signer], "signer doesn't exist");
        require(verify_signatures(signatures, message, nonce), "bad signatures");
        signers[old_signer] = false;
        signer_count--;
        emit SignerRemoved(old_signer, nonce);
    }

    
    
    
    
    
    
    
    
    function verify_signatures(bytes memory signatures, bytes memory message, uint256 nonce) public override returns(bool) {
        require(signatures.length % 65 == 0, "bad sig length");
        require(!used_nonces[nonce], "nonce already used");
        uint8 sig_count = 0;

        bytes32 message_hash = keccak256(abi.encode(message, msg.sender));

        for(uint256 msg_idx = 32; msg_idx < signatures.length + 32; msg_idx+= 65){
            //recover address from that msg
            bytes32 r;
            bytes32 s;
            uint8 v;

            assembly {
            // first 32 bytes, after the length prefix
                r := mload(add(signatures, msg_idx))
            // second 32 bytes
                s := mload(add(signatures, add(msg_idx, 32)))
            // final byte (first byte of the next 32 bytes)
                v := byte(0, mload(add(signatures, add(msg_idx, 64))))
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

            address recovered_address = ecrecover(message_hash, v, r, s);

            if(signers[recovered_address] && !has_signed[message_hash][recovered_address]){
                has_signed[message_hash][recovered_address] = true;
                sig_count++;
            }
        }
        used_nonces[nonce] = true;
        return ((uint256(sig_count) * 1000) / (uint256(signer_count))) > threshold;
    }

    
    function get_valid_signer_count() public override view returns(uint8){
        return signer_count;
    }

    
    function get_current_threshold() public override view returns(uint16) {
        return threshold;
    }

    
    
    function is_valid_signer(address signer_address) public override view returns(bool){
        return signers[signer_address];
    }

    
    
    function is_nonce_used(uint256 nonce) public override view returns(bool){
        return used_nonces[nonce];
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