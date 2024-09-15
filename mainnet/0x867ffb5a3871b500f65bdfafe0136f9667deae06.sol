
pragma solidity ^0.4.24;

contract Token {
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
}



contract LocalEthereumEscrows {
    /***********************
    +   Global settings   +
    ***********************/

    // Address of the arbitrator (currently always localethereum staff)
    address public arbitrator;
    // Address of the owner (who can withdraw collected fees)
    address public owner;
    // Address of the relayer (who is allowed to forward signed instructions from parties)
    address public relayer;
    uint32 public requestCancellationMinimumTime;
    // Cumulative balance of collected fees
    uint256 public feesAvailableForWithdraw;

    /***********************
    +  Instruction types  +
    ***********************/

    // Called when the buyer marks payment as sent. Locks funds in escrow
    uint8 constant INSTRUCTION_SELLER_CANNOT_CANCEL = 0x01;
    // Buyer cancelling
    uint8 constant INSTRUCTION_BUYER_CANCEL = 0x02;
    // Seller cancelling
    uint8 constant INSTRUCTION_SELLER_CANCEL = 0x03;
    // Seller requesting to cancel. Begins a window for buyer to object
    uint8 constant INSTRUCTION_SELLER_REQUEST_CANCEL = 0x04;
    // Seller releasing funds to the buyer
    uint8 constant INSTRUCTION_RELEASE = 0x05;
    // Either party permitting the arbitrator to resolve a dispute
    uint8 constant INSTRUCTION_RESOLVE = 0x06;

    /***********************
    +       Events        +
    ***********************/

    event Created(bytes32 indexed _tradeHash);
    event SellerCancelDisabled(bytes32 indexed _tradeHash);
    event SellerRequestedCancel(bytes32 indexed _tradeHash);
    event CancelledBySeller(bytes32 indexed _tradeHash);
    event CancelledByBuyer(bytes32 indexed _tradeHash);
    event Released(bytes32 indexed _tradeHash);
    event DisputeResolved(bytes32 indexed _tradeHash);

    struct Escrow {
        // So we know the escrow exists
        bool exists;
        // This is the timestamp in whic hthe seller can cancel the escrow after.
        // It has two special values:
        // 0 : Permanently locked by the buyer (i.e. marked as paid; the seller can never cancel)
        // 1 : The seller can only request to cancel, which will change this value to a timestamp.
        //     This option is avaialble for complex trade terms such as cash-in-person where a
        //     payment window is inappropriate
        uint32 sellerCanCancelAfter;
        // Cumulative cost of gas incurred by the relayer. This amount will be refunded to the owner
        // in the way of fees once the escrow has completed
        uint128 totalGasFeesSpentByRelayer;
    }

    // Mapping of active trades. The key here is a hash of the trade proprties
    mapping (bytes32 => Escrow) public escrows;

    modifier onlyOwner() {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Must be arbitrator");
        _;
    }

    
    constructor() public {
        owner = msg.sender;
        arbitrator = msg.sender;
        relayer = msg.sender;
        requestCancellationMinimumTime = 2 hours;
    }

    
    
    
    
    
    
    
    
    
    
    
    function createEscrow(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint32 _paymentWindowInSeconds,
        uint32 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) payable external {
        // The trade hash is created by tightly-concatenating and hashing properties of the trade.
        // This hash becomes the identifier of the escrow, and hence all these variables must be
        // supplied on future contract calls
        bytes32 _tradeHash = keccak256(abi.encodePacked(_tradeID, _seller, _buyer, _value, _fee));
        // Require that trade does not already exist
        require(!escrows[_tradeHash].exists, "Trade already exists");
        // A signature (v, r and s) must come from localethereum to open an escrow
        bytes32 _invitationHash = keccak256(abi.encodePacked(
            _tradeHash,
            _paymentWindowInSeconds,
            _expiry
        ));
        require(recoverAddress(_invitationHash, _v, _r, _s) == relayer, "Must be relayer");
        // These signatures come with an expiry stamp
        require(block.timestamp < _expiry, "Signature has expired");
        // Check transaction value against signed _value and make sure is not 0
        require(msg.value == _value && msg.value > 0, "Incorrect ether sent");
        uint32 _sellerCanCancelAfter = _paymentWindowInSeconds == 0
            ? 1
            : uint32(block.timestamp) + _paymentWindowInSeconds;
        // Add the escrow to the public mapping
        escrows[_tradeHash] = Escrow(true, _sellerCanCancelAfter, 0);
        emit Created(_tradeHash);
    }

    uint16 constant GAS_doResolveDispute = 36100;
    
    
    
    
    
    
    
    
    
    
    function resolveDispute(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _buyerPercent
    ) external onlyArbitrator {
        address _signature = recoverAddress(keccak256(abi.encodePacked(
            _tradeID,
            INSTRUCTION_RESOLVE
        )), _v, _r, _s);
        require(_signature == _buyer || _signature == _seller, "Must be buyer or seller");

        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        require(_escrow.exists, "Escrow does not exist");
        require(_buyerPercent <= 100, "_buyerPercent must be 100 or lower");

        uint256 _totalFees = _escrow.totalGasFeesSpentByRelayer + (GAS_doResolveDispute * uint128(tx.gasprice));
        require(_value - _totalFees <= _value, "Overflow error"); // Prevent underflow
        feesAvailableForWithdraw += _totalFees; // Add the the pot for localethereum to withdraw

        delete escrows[_tradeHash];
        emit DisputeResolved(_tradeHash);
        if (_buyerPercent > 0)
          _buyer.transfer((_value - _totalFees) * _buyerPercent / 100);
        if (_buyerPercent < 100)
          _seller.transfer((_value - _totalFees) * (100 - _buyerPercent) / 100);
    }

    
    
    
    
    
    
    
    function release(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) external returns (bool){
        require(msg.sender == _seller, "Must be seller");
        return doRelease(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    
    
    
    
    
    
    
    function disableSellerCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _buyer, "Must be buyer");
        return doDisableSellerCancel(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    
    
    
    
    
    
    
    function buyerCancel(
      bytes16 _tradeID,
      address _seller,
      address _buyer,
      uint256 _value,
      uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _buyer, "Must be buyer");
        return doBuyerCancel(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    
    
    
    
    
    
    
    function sellerCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _seller, "Must be seller");
        return doSellerCancel(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    
    
    
    
    
    
    
    function sellerRequestCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) external returns (bool) {
        require(msg.sender == _seller, "Must be seller");
        return doSellerRequestCancel(_tradeID, _seller, _buyer, _value, _fee, 0);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    uint16 constant GAS_batchRelayBaseCost = 28500;
    function batchRelay(
        bytes16[] _tradeID,
        address[] _seller,
        address[] _buyer,
        uint256[] _value,
        uint16[] _fee,
        uint128[] _maximumGasPrice,
        uint8[] _v,
        bytes32[] _r,
        bytes32[] _s,
        uint8[] _instructionByte
    ) public returns (bool[]) {
        bool[] memory _results = new bool[](_tradeID.length);
        uint128 _additionalGas = uint128(msg.sender == relayer ? GAS_batchRelayBaseCost / _tradeID.length : 0);
        for (uint8 i=0; i<_tradeID.length; i++) {
            _results[i] = relay(
                _tradeID[i],
                _seller[i],
                _buyer[i],
                _value[i],
                _fee[i],
                _maximumGasPrice[i],
                _v[i],
                _r[i],
                _s[i],
                _instructionByte[i],
                _additionalGas
            );
        }
        return _results;
    }

    
    
    
    function withdrawFees(address _to, uint256 _amount) onlyOwner external {
        // This check also prevents underflow
        require(_amount <= feesAvailableForWithdraw, "Amount is higher than amount available");
        feesAvailableForWithdraw -= _amount;
        _to.transfer(_amount);
    }

    
    
    function setArbitrator(address _newArbitrator) onlyOwner external {
        arbitrator = _newArbitrator;
    }

    
    
    function setOwner(address _newOwner) onlyOwner external {
        owner = _newOwner;
    }

    
    
    function setRelayer(address _newRelayer) onlyOwner external {
        relayer = _newRelayer;
    }

    
    
    function setRequestCancellationMinimumTime(
        uint32 _newRequestCancellationMinimumTime
    ) onlyOwner external {
        requestCancellationMinimumTime = _newRequestCancellationMinimumTime;
    }

    
    
    
    
    function transferToken(
        Token _tokenContract,
        address _transferTo,
        uint256 _value
    ) onlyOwner external {
        _tokenContract.transfer(_transferTo, _value);
    }

    
    
    
    
    
    function transferTokenFrom(
        Token _tokenContract,
        address _transferTo,
        address _transferFrom,
        uint256 _value
    ) onlyOwner external {
        _tokenContract.transferFrom(_transferTo, _transferFrom, _value);
    }

    
    
    
    
    function approveToken(
        Token _tokenContract,
        address _spender,
        uint256 _value
    ) onlyOwner external {
        _tokenContract.approve(_spender, _value);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    function relay(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _maximumGasPrice,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint8 _instructionByte,
        uint128 _additionalGas
    ) private returns (bool) {
        address _relayedSender = getRelayedSender(
            _tradeID,
            _instructionByte,
            _maximumGasPrice,
            _v,
            _r,
            _s
        );
        if (_relayedSender == _buyer) {
            // Buyer's instructions:
            if (_instructionByte == INSTRUCTION_SELLER_CANNOT_CANCEL) {
                // Disable seller from cancelling
                return doDisableSellerCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            } else if (_instructionByte == INSTRUCTION_BUYER_CANCEL) {
                // Cancel
                return doBuyerCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            }
        } else if (_relayedSender == _seller) {
            // Seller's instructions:
            if (_instructionByte == INSTRUCTION_RELEASE) {
                // Release
                return doRelease(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            } else if (_instructionByte == INSTRUCTION_SELLER_CANCEL) {
                // Cancel
                return doSellerCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            } else if (_instructionByte == INSTRUCTION_SELLER_REQUEST_CANCEL){
                // Request to cancel
                return doSellerRequestCancel(_tradeID, _seller, _buyer, _value, _fee, _additionalGas);
            }
        } else {
            require(msg.sender == _seller, "Unrecognised party");
            return false;
        }
    }

    
    
    
    function increaseGasSpent(bytes32 _tradeHash, uint128 _gas) private {
        escrows[_tradeHash].totalGasFeesSpentByRelayer += _gas * uint128(tx.gasprice);
    }

    
    
    
    
    
    function transferMinusFees(
        address _to,
        uint256 _value,
        uint128 _totalGasFeesSpentByRelayer,
        uint16 _fee
    ) private {
        uint256 _totalFees = (_value * _fee / 10000) + _totalGasFeesSpentByRelayer;
        // Prevent underflow
        if(_value - _totalFees > _value) {
            return;
        }
        // Add fees to the pot for localethereum to withdraw
        feesAvailableForWithdraw += _totalFees;
        _to.transfer(_value - _totalFees);
    }

    uint16 constant GAS_doRelease = 46588;
    
    
    
    
    
    
    
    
    function doRelease(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) return false;
        uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer
            + (msg.sender == relayer
                ? (GAS_doRelease + _additionalGas ) * uint128(tx.gasprice)
                : 0
            );
        delete escrows[_tradeHash];
        emit Released(_tradeHash);
        transferMinusFees(_buyer, _value, _gasFees, _fee);
        return true;
    }

    uint16 constant GAS_doDisableSellerCancel = 28944;
    
    
    
    
    
    
    
    
    function doDisableSellerCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) return false;
        if(_escrow.sellerCanCancelAfter == 0) return false;
        escrows[_tradeHash].sellerCanCancelAfter = 0;
        emit SellerCancelDisabled(_tradeHash);
        if (msg.sender == relayer) {
          increaseGasSpent(_tradeHash, GAS_doDisableSellerCancel + _additionalGas);
        }
        return true;
    }

    uint16 constant GAS_doBuyerCancel = 46255;
    
    
    
    
    
    
    
    
    function doBuyerCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) {
            return false;
        }
        uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer
            + (msg.sender == relayer
                ? (GAS_doBuyerCancel + _additionalGas ) * uint128(tx.gasprice)
                : 0
            );
        delete escrows[_tradeHash];
        emit CancelledByBuyer(_tradeHash);
        transferMinusFees(_seller, _value, _gasFees, 0);
        return true;
    }

    uint16 constant GAS_doSellerCancel = 46815;
    
    
    
    
    
    
    
    
    function doSellerCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) {
            return false;
        }
        if(_escrow.sellerCanCancelAfter <= 1 || _escrow.sellerCanCancelAfter > block.timestamp) {
            return false;
        }
        uint128 _gasFees = _escrow.totalGasFeesSpentByRelayer
            + (msg.sender == relayer
                ? (GAS_doSellerCancel + _additionalGas ) * uint128(tx.gasprice)
                : 0
            );
        delete escrows[_tradeHash];
        emit CancelledBySeller(_tradeHash);
        transferMinusFees(_seller, _value, _gasFees, 0);
        return true;
    }

    uint16 constant GAS_doSellerRequestCancel = 29507;
    
    
    
    
    
    
    
    
    function doSellerRequestCancel(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee,
        uint128 _additionalGas
    ) private returns (bool) {
        // Called on unlimited payment window trades where the buyer is not responding
        Escrow memory _escrow;
        bytes32 _tradeHash;
        (_escrow, _tradeHash) = getEscrowAndHash(_tradeID, _seller, _buyer, _value, _fee);
        if (!_escrow.exists) {
            return false;
        }
        if(_escrow.sellerCanCancelAfter != 1) {
            return false;
        }
        escrows[_tradeHash].sellerCanCancelAfter = uint32(block.timestamp)
            + requestCancellationMinimumTime;
        emit SellerRequestedCancel(_tradeHash);
        if (msg.sender == relayer) {
          increaseGasSpent(_tradeHash, GAS_doSellerRequestCancel + _additionalGas);
        }
        return true;
    }

    
    
    
    
    
    
    
    
    function getRelayedSender(
      bytes16 _tradeID,
      uint8 _instructionByte,
      uint128 _maximumGasPrice,
      uint8 _v,
      bytes32 _r,
      bytes32 _s
    ) view private returns (address) {
        bytes32 _hash = keccak256(abi.encodePacked(
            _tradeID,
            _instructionByte,
            _maximumGasPrice
        ));
        if(tx.gasprice > _maximumGasPrice) {
            return;
        }
        return recoverAddress(_hash, _v, _r, _s);
    }

    
    
    
    
    
    
    
    
    function getEscrowAndHash(
        bytes16 _tradeID,
        address _seller,
        address _buyer,
        uint256 _value,
        uint16 _fee
    ) view private returns (Escrow, bytes32) {
        bytes32 _tradeHash = keccak256(abi.encodePacked(
            _tradeID,
            _seller,
            _buyer,
            _value,
            _fee
        ));
        return (escrows[_tradeHash], _tradeHash);
    }

    
    
    
    
    
    
    function recoverAddress(
        bytes32 _h,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {
        bytes memory _prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 _prefixedHash = keccak256(abi.encodePacked(_prefix, _h));
        return ecrecover(_prefixedHash, _v, _r, _s);
    }
}