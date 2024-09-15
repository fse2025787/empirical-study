// SPDX-License-Identifier: Apache-2.0

/**
 *Submitted for verification at Etherscan.io on 2021-08-09
*/

// 

pragma solidity >=0.6.0 <0.8.0;

interface IMultisig {

    function owners() external view returns (address[] memory addresses, uint256[] memory vPowers);
    function request() external view returns (address destination, uint256 value, bytes memory data);
    function requestProgress() external view returns (uint32 requestId, uint256 timestamp, uint16 currentVote, uint16 requiredVote);
    function voteRequirement() external view returns (uint16 requiredVote, uint16 totalVote);
    function hasVoted(address owner) external view returns (bool voted, uint16 vPower);
    function createRequest(address destination, uint256 value, bytes memory data) external returns (bool);
    function vote() external returns (bool);
    function cancelRequest() external returns (bool);
    function changeOwners(address[] memory nOwners, uint16[] memory vPowers, uint16 vRate) external returns (bool);

    event Requested(uint256 requestId, address indexed destination, uint256 value, bytes data, uint16 currentVote, uint16 requiredVote);
    event Voted(address owner, uint256 requestId, uint16 currentVote, uint16 requiredVote);
    event Executed(bool status, uint256 requestId, address indexed destination, uint256 value, bytes data);
    event Cancelled(uint256 requestId);
    event OwnersChanged(address[] owners, uint16 requireVote, uint16 totalVote);
    event Deposited(address indexed sender, uint256 value);
}

contract Coin98Multisig is IMultisig {

    address[] private _owners;
    mapping(address => uint16) private _votePowers;
    VoteRequirement private _voteRequirement;

    uint32 private _requestId;
    Request private _request;
    mapping(address => uint32) private _votes;
    VoteProgress private _voteProgress;

    
    
    
    
    constructor(address[] memory owners_, uint16[] memory vPowers_, uint16 requiredVote_) {
        _lock = _NOT_ENTERED;
        _changeOwners(owners_, vPowers_, requiredVote_);
    }

    // Data structure to store information of a request
    struct Request {
        address destination;
        uint256 value;
        bytes data;
    }

    // Data structure to store information for the vote of current request
    struct VoteProgress {
        uint32 requestId;
        uint16 currentVote;
        uint16 requiredVote;
        uint256 timestamp;
    }

    // Data structure to store information about voting weight
    struct VoteRequirement {
        uint16 requiredVote;
        uint16 totalVote;
    }

    modifier selfOnly() {
        require(msg.sender == address(this), "Coin98MSig: Wallet only");
        _;
    }

    modifier isOwner(address owner) {
        require(_votePowers[owner] > 0, "Coin98MSig: Not an owner");
        _;
    }

    fallback() external payable {
        if (msg.value > 0) {
            emit Deposited(msg.sender, msg.value);
        }
    }

    
    receive() external payable {
        if (msg.value > 0) {
            emit Deposited(msg.sender, msg.value);
        }
    }

    
    
    
    function owners() external view override returns (address[] memory addresses, uint256[] memory vPowers) {
        uint256[] memory values = new uint256[](_owners.length);
        uint256 i;
        for (i = 0; i < _owners.length; i++) {
            values[i] = (_votePowers[_owners[i]]);
        }
        return (_owners, values);
    }

    
    
    
    
    function request() external view override returns (address destination, uint256 value, bytes memory data) {
        Request memory req = _request;
        return (req.destination, req.value, req.data);
    }

    
    
    
    
    
    function requestProgress() external view override returns (uint32 requestId, uint256 timestamp, uint16 currentVote, uint16 requiredVote) {
        VoteProgress memory progress = _voteProgress;
        return (progress.requestId, progress.timestamp, progress.currentVote, progress.requiredVote);
    }

    
    
    
    function voteRequirement() external view override returns (uint16 requiredVote, uint16 totalVote) {
        VoteRequirement memory requirement = _voteRequirement;
        return (requirement.requiredVote, requirement.totalVote);
    }

    
    
    
    function hasVoted(address owner) external view override returns (bool voted, uint16 vPower) {
        VoteProgress memory progress = _voteProgress;
        uint16 power = _votePowers[owner];
        if (progress.requestId == 0) {
            return (false, power);
        }
        return (progress.requestId == _votes[owner], power);
    }

    
    
    
    
    function createRequest(address destination, uint256 value, bytes memory data)
        isOwner(msg.sender)
        external override returns (bool) {
        VoteProgress memory progress = _voteProgress;
        require(progress.requestId == 0, "Coin98MSig: Request pending");

        Request memory req;
        req.destination = destination;
        req.value = value;
        req.data = data;
        progress.requestId = _requestId + 1;
        progress.requiredVote = _voteRequirement.requiredVote;
        progress.timestamp = block.timestamp;
        _request = req;
        _requestId = progress.requestId;
        _voteProgress = progress;
        vote();

        emit Requested(progress.requestId, req.destination, req.value, req.data, progress.currentVote, progress.requiredVote);
        return true;
    }

    
    function vote()
        isOwner(msg.sender)
        nonReentrant()
        public override returns (bool) {
        VoteProgress memory progress = _voteProgress;
        require(progress.requestId > 0, "Coin98MSig: No pending request");
        if (_votes[msg.sender] < progress.requestId) {
            _votes[msg.sender] = progress.requestId;
            progress.currentVote += _votePowers[msg.sender];
            _voteProgress = progress;
            emit Voted(msg.sender, progress.requestId, progress.currentVote, progress.requiredVote);
        }
        if (progress.currentVote >= progress.requiredVote) {
            Request memory req = _request;
            (bool success,) = req.destination.call{value: req.value}(req.data);
            if (success) {
                delete _request;
                delete _voteProgress;
                Executed(true, progress.requestId, req.destination, req.value, req.data);
            }
            else {
                Executed(false, progress.requestId, req.destination, req.value, req.data);
            }
        }
        return true;
    }

    
    function cancelRequest()
        isOwner(msg.sender)
        external override returns (bool) {
        VoteProgress memory progress = _voteProgress;
        require(progress.requestId > 0, "Coin98MSig: No pending request");
        require(block.timestamp - progress.timestamp > 600, "Coin98MSig: 10 mins not passed");

        delete _request;
        delete _voteProgress;

        emit Cancelled(progress.requestId);
        return true;
    }

    
    /// and number of votes needed to perform the request
    
    
    
    function changeOwners(address[] memory nOwners, uint16[] memory vPowers, uint16 vRate)
        selfOnly()
        external override returns (bool) {
        _changeOwners(nOwners, vPowers, vRate);
        return true;
    }

    function _changeOwners(address[] memory nOwners, uint16[] memory vPowers, uint16 vRate) internal {
        require(nOwners.length == vPowers.length, "Coin98MSig: Owners and vPowers length mismatch");
        VoteRequirement memory requirement = _voteRequirement;
        uint256 i;
        for (i = 0; i < nOwners.length; i++) {
            address nOwner = nOwners[i];
            uint16 cPower = _votePowers[nOwner];
            uint16 vPower = vPowers[i];
            require(vPower <= 256, "Coin98MSig: Invalid vRate");
            if (cPower > 0) {
                if (vPower == 0) {
                    uint256 j;
                    for(j = 0; j < _owners.length; j++) {
                        if (_owners[j] == nOwner) {
                            _owners[j] = _owners[_owners.length - 1];
                            _owners.pop();
                            delete _votes[nOwner];
                            break;
                        }
                    }
                }
                requirement.totalVote -= cPower;
            }
            else {
                if (vPower > 0) {
                    _owners.push(nOwner);
                }
            }
            _votePowers[nOwner] = vPower;
            requirement.totalVote += vPower;
        }
        if (vRate > 0) {
            requirement.requiredVote = vRate;
        }
        uint256 ownerCount = _owners.length;
        require(requirement.requiredVote > 0, "Coin98MSig: Invalid vRate");
        require(requirement.requiredVote <= requirement.totalVote, "Coin98MSig: Invalid vRate");
        require(requirement.totalVote <= 4096, "Coin98MSig: Max weight reached");
        require(ownerCount > 0, "Coin98MSig: At least 1 owner");
        require(ownerCount <= 64, "Coin98MSig: Max owner reached");
        _voteRequirement = requirement;

        OwnersChanged(nOwners, requirement.requiredVote, requirement.totalVote);
    }

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _lastLockTimestamp;
    uint256 private _lock;

    
    /// Calling a `nonReentrant` function from another `nonReentrant`
    /// function is not supported. It is possible to prevent this from happening
    /// by making the `nonReentrant` function external, and make it call a
    /// `private` function that does the actual work.
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        // Add 24-hour timeout to unlock contract in case of deadlock
        require(_lock != _ENTERED || block.timestamp - _lastLockTimestamp > 86400, "Coin98MSig: Reentrant call");

        // Any calls to nonReentrant after this point will fail
        _lastLockTimestamp = block.timestamp;
        _lock = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _lock = _NOT_ENTERED;
    }
}

contract Coin98MultisigFactory {
    event Created(address indexed wallet, address[] owners);

    
    
    
    
    function createMulitSig(address[] memory owners_, uint16[] memory vPowers_, uint16 requiredVote_)
        external returns (Coin98Multisig wallet) {
        wallet = new Coin98Multisig(owners_, vPowers_, requiredVote_);
        emit Created(address(wallet), owners_);
    }
}