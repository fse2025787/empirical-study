// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-06-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// 
pragma solidity ^0.8.0;

interface IERC20 {
    
    function mint(address account, uint256 amount) external;
    
    function addMinter(address account) external;
    
    function renounceMinter() external;
    
    function isMinter(address account) external view returns (bool);
}


contract MultiSigModifiers {
    address public TokenAddress; //will change only in constractor
    uint256 public MinSigners; //min signers amount to do action - will change only in constractor
    uint256 public sigCounter; //vote count if the transaction can be implemented
    mapping(address => bool) public AuthorizedMap; //can self change
    mapping(uint => address) public VotesMap; // who voted
    uint256 public Amount; //hold temp data for transaction
    address public TargetAddress; //hold temp data for transaction

    modifier OnlyAuthorized() {
        require(
            AuthorizedMap[msg.sender],
            "User is not Authorized"
        );
        _;
    }

    modifier isThisContractMinter() {
        require(
            IERC20(TokenAddress).isMinter(address(this)),
            "MultiSig doesn't have a minter role"
        );
        _;
    }

    modifier ValuesCheck(address target, uint256 amount) {
        require(
            TargetAddress == target && Amount == amount,
            "Must use the same values from initiation"
        );
        _;
    }

    modifier NotVoted(){
        for (uint256 i = 0; i < sigCounter; i++) {
            require(VotesMap[i] != msg.sender, "your vote is already accepted");
        }
        _;
    }
}


contract MultiSigEvents {
    event Setup(address[] Authorized, address Token, uint256 MinSignersAmount);
    event StartMint(address target, uint256 amount);
    event CompleteMint(address target, uint256 amount);
    event StartChangeOwner(address target);
    event CompleteChangeOwner(address target);
    event AuthorizedChanged(address newAuthorize, address OldAuthorize);
    event NewSig(address Signer, uint256 CurrentSigns, uint256 NeededSigns);
    event Clear();
}

contract MultiSigInitiator is MultiSigModifiers, MultiSigEvents {
    
    function InitiateMint(address target, uint256 amount)
        external
        OnlyAuthorized
        isThisContractMinter
        ValuesCheck(address(0), 0)
    {
        require(
            amount > 0 && target != address(0),
            "Target address must be non-zero and amount must be greater than 0"
        );
        Amount = amount;
        TargetAddress = target;
        emit StartMint(target, amount);
        _confirmMint(target, amount);
    }

    
    function InitiateTransferOwnership(address target)
        external
        OnlyAuthorized
        isThisContractMinter
        ValuesCheck(address(0), 0)
    {
        require(target != address(0), "Target address must be non-zero");
        TargetAddress = target;
        emit StartChangeOwner(target);
        _confirmTransferOwnership(target);
    }

    
    function IsFinalSig() internal view returns (bool) {
        return sigCounter == MinSigners;
    }

    function _newSignature() internal NotVoted {
        VotesMap[sigCounter++] = msg.sender;
        emit NewSig(msg.sender, sigCounter, MinSigners);
    }

    function _mint(address target, uint256 amount) internal {
        IERC20(TokenAddress).mint(target, amount);
        emit CompleteMint(target, amount);
    }

    
    function ClearConfirmation() public OnlyAuthorized {
        Amount = 0;
        TargetAddress = address(0);
        sigCounter = 0;
        emit Clear();
    }

    function _confirmMint(address target, uint256 amount) internal {
        _newSignature();
        if (IsFinalSig()) {
            _mint(target, amount);
            ClearConfirmation();
        }
    }

    function _confirmTransferOwnership(address target) internal {
        _newSignature();
        if (IsFinalSig()) {
            IERC20(TokenAddress).addMinter(target);
            IERC20(TokenAddress).renounceMinter();
            emit CompleteChangeOwner(target);
            ClearConfirmation();
        }
    }
}


contract MultiSigConfirmer is MultiSigInitiator {
    
    function ChangeAuthorizedAddress(address authorize)
        external
        OnlyAuthorized
    {
        require(
            !AuthorizedMap[authorize],
            "AuthorizedMap must have unique addresses"
        );
        require(authorize != address(0), "Authorize address must be non-zero");
        emit AuthorizedChanged(authorize, msg.sender);
        AuthorizedMap[msg.sender] = false;
        AuthorizedMap[authorize] = true;
    }

    
    /// if there are enough votes, coins will be minted
    function ConfirmMint(address target, uint256 amount)
        external
        OnlyAuthorized
        ValuesCheck(target, amount)
    {
        _confirmMint(target, amount);
    }

    
    function ConfirmTransferOwnership(address target)
        external
        OnlyAuthorized
        ValuesCheck(target, 0)
    {
        _confirmTransferOwnership(target);
    }
}



contract MultiSig is MultiSigConfirmer {
    
    
    
    constructor(
        address[] memory Authorized,
        address Token,
        uint256 MinSignersAmount
    ) {
        require(Authorized.length >= MinSignersAmount, "Authorized array length must be equal or greater than MinSignersAmount");
        require(Token != address(0), "Token address must be non-zero");
        require(MinSignersAmount > 1, "Minimum signers must be greater than 1");
        for (uint256 index = 0; index < Authorized.length; index++) {
            require(Authorized[index] != address(0), "Invalid Authorized address");
            AuthorizedMap[Authorized[index]] = true;
        }
        TokenAddress = Token;
        MinSigners = MinSignersAmount;
        emit Setup(Authorized, Token, MinSignersAmount);
    }
}