
pragma solidity ^0.4.19;




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}




contract Unidirectional {
    using SafeMath for uint256;

    struct PaymentChannel {
        address sender;
        address receiver;
        uint256 value; // Total amount of money deposited to the channel.

        uint32 settlingPeriod; // How many blocks to wait for the receiver to claim her funds, after sender starts settling.
        uint256 settlingUntil; // Starting with this block number, anyone can settle the channel.
    }

    mapping (bytes32 => PaymentChannel) public channels;

    event DidOpen(bytes32 indexed channelId, address indexed sender, address indexed receiver, uint256 value);
    event DidDeposit(bytes32 indexed channelId, uint256 deposit);
    event DidClaim(bytes32 indexed channelId);
    event DidStartSettling(bytes32 indexed channelId);
    event DidSettle(bytes32 indexed channelId);

    /*** ACTIONS AND CONSTRAINTS ***/

    
    
    
    
    /// After that period is over anyone could call `settle`, and move all the channel funds to the sender.
    function open(bytes32 channelId, address receiver, uint32 settlingPeriod) public payable {
        require(isAbsent(channelId));

        channels[channelId] = PaymentChannel({
            sender: msg.sender,
            receiver: receiver,
            value: msg.value,
            settlingPeriod: settlingPeriod,
            settlingUntil: 0
        });

        DidOpen(channelId, msg.sender, receiver, msg.value);
    }

    
    
    
    
    function canDeposit(bytes32 channelId, address origin) public view returns(bool) {
        PaymentChannel memory channel = channels[channelId];
        bool isSender = channel.sender == origin;
        return isOpen(channelId) && isSender;
    }

    
    
    function deposit(bytes32 channelId) public payable {
        require(canDeposit(channelId, msg.sender));

        channels[channelId].value += msg.value;

        DidDeposit(channelId, msg.value);
    }

    
    
    
    
    function canStartSettling(bytes32 channelId, address origin) public view returns(bool) {
        PaymentChannel memory channel = channels[channelId];
        bool isSender = channel.sender == origin;
        return isOpen(channelId) && isSender;
    }

    
    
    
    function startSettling(bytes32 channelId) public {
        require(canStartSettling(channelId, msg.sender));

        PaymentChannel storage channel = channels[channelId];
        channel.settlingUntil = block.number + channel.settlingPeriod;

        DidStartSettling(channelId);
    }

    
    
    
    function canSettle(bytes32 channelId) public view returns(bool) {
        PaymentChannel memory channel = channels[channelId];
        bool isWaitingOver = isSettling(channelId) && block.number >= channel.settlingUntil;
        return isSettling(channelId) && isWaitingOver;
    }

    
    /// After the settling period is over, and receiver has not claimed the funds, anyone could call that.
    
    function settle(bytes32 channelId) public {
        require(canSettle(channelId));
        PaymentChannel storage channel = channels[channelId];
        channel.sender.transfer(channel.value);

        delete channels[channelId];
        DidSettle(channelId);
    }

    
    
    
    
    
    
    function canClaim(bytes32 channelId, uint256 payment, address origin, bytes signature) public view returns(bool) {
        PaymentChannel memory channel = channels[channelId];
        bool isReceiver = origin == channel.receiver;
        bytes32 hash = recoveryPaymentDigest(channelId, payment);
        bool isSigned = channel.sender == ECRecovery.recover(hash, signature);

        return isReceiver && isSigned;
    }

    
    
    
    
    
    function claim(bytes32 channelId, uint256 payment, bytes signature) public {
        require(canClaim(channelId, payment, msg.sender, signature));

        PaymentChannel memory channel = channels[channelId];

        if (payment >= channel.value) {
            channel.receiver.transfer(channel.value);
        } else {
            channel.receiver.transfer(payment);
            channel.sender.transfer(channel.value.sub(payment));
        }

        delete channels[channelId];

        DidClaim(channelId);
    }

    /*** CHANNEL STATE ***/

    
    
    function isPresent(bytes32 channelId) public view returns(bool) {
        return !isAbsent(channelId);
    }

    
    
    function isAbsent(bytes32 channelId) public view returns(bool) {
        PaymentChannel memory channel = channels[channelId];
        return channel.sender == 0;
    }

    
    
    
    function isSettling(bytes32 channelId) public view returns(bool) {
        PaymentChannel memory channel = channels[channelId];
        return channel.settlingUntil != 0;
    }

    
    
    function isOpen(bytes32 channelId) public view returns(bool) {
        return isPresent(channelId) && !isSettling(channelId);
    }

    /*** PAYMENT DIGEST ***/

    
    
    
    function paymentDigest(bytes32 channelId, uint256 payment) public view returns(bytes32) {
        return keccak256(address(this), channelId, payment);
    }

    
    
    
    function recoveryPaymentDigest(bytes32 channelId, uint256 payment) internal view returns(bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(prefix, paymentDigest(channelId, payment));
    }
}