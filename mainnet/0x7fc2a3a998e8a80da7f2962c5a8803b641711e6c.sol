pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

/**
 *Paralism.com EPARA Token V1 on Ethereum
*/
pragma solidity >=0.6.4 <0.8.0;




library SafeMath {
    function safeAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "add() overflow!");
    }

    function safeSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "sub() underflow!");
    }
    
    function toUint64(uint256 _value) internal pure returns (uint64 z){
        require(_value < 2**64, "toUint64() overflow!");
        return uint64(_value);
    }
}





contract EPARA {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint8 public decimals;
    
    uint256 internal _supplyCap;
    uint256 public totalLocked;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256) public freezeOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
    
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
    event Burn(address indexed from, uint256 value);

    struct TokensWithLock {
        address sender;
        uint256 lockValue;
        uint64 lockTime;
        bool allowLockTimeUpdate;      
        uint64 initAskTime;
        uint256 askToLock;
    }

    mapping (address => TokensWithLock) public lock;
    
    event TransferWithLock(address indexed sender, address indexed owner, uint256 value, uint256 lockTime ,uint256 initLockDays);
    event ReturnLockedTokens(address indexed owner, address indexed sender, uint256 value);
    event UpdateLockTime(address indexed sender, address indexed owner, uint256 lockDays);
    event AllowUpdateLock(address indexed owner, bool allow);
    event RequestToLock(address indexed sender, address indexed owner, uint256 value, uint256 intLockDays);
    event AcceptLock(address indexed owner,address indexed sender, uint256 value, uint256 lockTime);
    event ReduceLockValue(address indexed sender, address indexed owner, uint256 value);
 
    /*MultiSign*/
    struct Approver {address addr; uint64 score; bool activated; }
    struct ApproveTrans {address to; uint256 value; }
    struct MultiSign {
        uint256 multiSignBalance;
        Approver[] approvers;
        uint64 passScore;                // score of multi party signed to effective
        uint64 expiration;               // MultiSign account expiration time in UNIX seconds
        bool holdFlag;                // hold balance flag, for transfer check gas saving
        address backAccount;             // all tokens controled by MultiSign will return to backAccount when expired
    }
    mapping (address => MultiSign) public multiSign;
    struct Vote {
        ApproveTrans approveTrans;       // transfer request
        uint256 recall;                  // the requestion of recall from keeper's balance to multisign balance
        address backAccount;             // the account where the expired token return to
        bool holdBalance;                // true: freeze account keeper's balance
        uint64 expireDays;               // update expiration days 
    }
    mapping (address => mapping(address => Vote)) public vote;
    
    event MultiSignApprover(address indexed keeper, address indexed approver, uint individualScore);
    event CreateMultiSign(address indexed keeper, uint passScore, address backAccount, uint expiration);
    event FreezeKeeper(address indexed approver, address indexed keeper, bool freeze);
    event HoldBalance(address indexed keeper, bool _freeze);
    event ApproveTransferTo(address indexed approver,address indexed keeper, address indexed to, uint value);
    event MultiSignTransfer(address indexed keeper, address indexed to, uint value);
    event RecallToMultiSign(address indexed approver, address indexed keeper, uint value);
    event MultiSignRecall(address indexed keeper, uint value);
    event UpdateExpiration(address indexed approver, address indexed keeper,uint expireDays);
    event MultiSignExpirationUpdated(address indexed keeper,uint expireDays);
    event UpdateBackAccount(address indexed approver, address indexed keeper, address newBackAccount);
    event MultiSignBackAccountUpdated(address indexed keeper, address newBackAccount);
    event CancelVote(address indexed approver, address indexed keeper);
    event TransferToMultiSign(address indexed approver,address indexed keeper, uint valu);
    event ClearMutiSign(address indexed sender,address indexed keeper, address indexed backAccount,uint value);

    constructor() {
        decimals = 9;
        name = "Paralism-EPARA";  
        symbol = "EPARA";
        _supplyCap = 21000*10000*(10**9);
        totalLocked = 0;

        balanceOf[msg.sender] = _supplyCap;         //210M
    }

    
    
    function totalSupply() public view returns (uint256){
        return _supplyCap - totalLocked;
    }
    
    
    
    
    
    
    
    function transferWithLockInit(address _to, uint256 _value, uint256 _initLockdays) public returns (bool success) {
        require (address(0) != _to,"transfer to address 0");
        require (false == isMutltiSignHoldBalance(msg.sender), "multisign balance hold");
        require (balanceOf[msg.sender] >= theLockValue(msg.sender).safeAdd(_value),"insufficient balance or locked");

        if (0 < theLockValue(_to)) {
            require (msg.sender == lock[_to].sender,"others lock detected") ;
            require (_initLockdays == 0,"Lock detected, init fail") ;
        }

        if (0 == theLockValue(_to)) {
            lock[_to].lockTime = (block.timestamp.safeAdd(_initLockdays * 1 days)).toUint64();           //init expriation day.
            lock[_to].sender= msg.sender;                                                   //init sender
        }

        lock[_to].lockValue = lock[_to].lockValue.safeAdd(_value);                          //add lock value
        balanceOf[msg.sender] = balanceOf[msg.sender].safeSub(_value);                      //subtract from the sender
        balanceOf[_to] = balanceOf[_to].safeAdd(_value);                                    //add to the recipient
        
        if (true == lock[_to].allowLockTimeUpdate) 
            lock[_to].allowLockTimeUpdate = false;                                         //disable sender change lock time until owner allowed again
        
        emit TransferWithLock(msg.sender, _to, _value, lock[_to].lockTime , _initLockdays);

        totalLocked = totalLocked.safeAdd(_value);    //increase totalLocked
        return true;
    }
    
    
    
    
    
    
    function transferMoreToLock(address _to, uint256 _value) public returns (bool success) {
        if(0 == theLockValue(_to)) revert("NO lock detected");
        return transferWithLockInit(_to,_value,0);
    }

    
    
    
    
    function theLockValue(address _addr) internal returns (uint256 amount){
        if (lock[_addr].lockTime <= block.timestamp) {
            totalLocked = totalLocked.safeSub(lock[_addr].lockValue);           //reduce totalLocked
            lock[_addr].lockValue = 0;                      //reset expired value
        }
        return lock[_addr].lockValue;
    }

    
    
    
    function getLockValue(address _addr) public view returns (uint256 amount){
        lock[_addr].lockTime > block.timestamp ? amount = lock[_addr].lockValue : amount = 0;
    }

    
    
    
    function getLockRemainSeconds(address _addr) public view returns (uint256 sec){
        lock[_addr].lockTime > block.timestamp ? sec = lock[_addr].lockTime - block.timestamp : sec = 0;
    }

    
    
    
    
    
    function updateLockTime(address _addr, uint256 _days)public returns (bool success) {
        require(theLockValue(_addr) > 0,"NO lock detected");
        require(msg.sender == lock[_addr].sender, "others lock detected");
        require(true == lock[_addr].allowLockTimeUpdate,"allowUpdateLockTime is false");

        lock[_addr].lockTime = (block.timestamp.safeAdd(_days * 1 days)).toUint64();
        lock[_addr].allowLockTimeUpdate = false;
        emit UpdateLockTime(msg.sender, _addr, _days);
        return true;
    }

    
    
    
    function allowUpdateLockTime(bool _allow) public returns (bool success){
        lock[msg.sender].allowLockTimeUpdate = _allow;
        emit AllowUpdateLock(msg.sender, _allow);
        return true;
    }

    
    
    
    
    function returnLockedTokens(uint256 _value) public returns (bool success){
        address _returnTo = lock[msg.sender].sender;
        address _returnFrom = msg.sender;

        uint256 lockValue = theLockValue(_returnFrom);
        require(0 < lockValue, "NO lock detected");
        require(_value <= lockValue,"insufficient lock value");
        require(balanceOf[_returnFrom] >= _value,"insufficient balance");

        balanceOf[_returnFrom] = balanceOf[_returnFrom].safeSub(_value);
        balanceOf[_returnTo] = balanceOf[_returnTo].safeAdd(_value);

        lock[_returnFrom].lockValue = lock[_returnFrom].lockValue.safeSub(_value);   //reduce locked amount

        emit ReturnLockedTokens(_returnFrom, _returnTo, _value);

        totalLocked = totalLocked.safeSub(_value);  //reduce totalLocked
        return true;
    }

    
    
    
    
    
    
    function askToLock(address _to, uint256 _value, uint256 _initLockdays) public returns(bool success) {
        require(balanceOf[_to] >= theLockValue(_to).safeAdd(_value), "insufficient balance to lock");
        if (0 < theLockValue(_to)) {
            require (msg.sender == lock[_to].sender,"others lock detected") ;
            require (_initLockdays == 0,"lock time exist") ;
        }
        lock[_to].askToLock = _value;
        lock[_to].initAskTime = (block.timestamp + _initLockdays * 1 days).toUint64();
        lock[_to].sender = msg.sender;
        
        emit RequestToLock(msg.sender, _to, _value, _initLockdays);
        return true;
    }

    
    
    
    
    
    function acceptLockReq(address _sender, uint256 _value) public returns(bool success) {
        require(lock[msg.sender].askToLock == _value,"value incorrect");
        require(balanceOf[msg.sender] >= theLockValue(msg.sender).safeAdd(_value), "insufficient balance or locked");//
        require(_sender == lock[msg.sender].sender,"sender incorrect");

        if(0 == theLockValue(msg.sender)) {
            lock[msg.sender].lockTime = lock[msg.sender].initAskTime;
        }
        lock[msg.sender].lockValue = theLockValue(msg.sender).safeAdd(_value);
        totalLocked = totalLocked.safeAdd(_value);    //increase totalLocked
        
        if (true ==lock[msg.sender].allowLockTimeUpdate) 
            lock[msg.sender].allowLockTimeUpdate = false;           //disable sender change lock timer until owner permits
            
        emit AcceptLock(msg.sender, _sender, _value, lock[msg.sender].lockTime);
        resetLockReq();
        return true;
    }

    
    
    
    function resetLockReq() public returns(bool success) {
        lock[msg.sender].askToLock = 0;
        lock[msg.sender].initAskTime = 0;
        return true;
    }

    
    
    
    
    
    function reduceLockValue(address _to, uint256 _value) public returns(bool success) {
        require(_value <= theLockValue(_to), "insufficient lock balance");
        require (msg.sender == lock[_to].sender,"others lock detected") ;

        lock[_to].lockValue = lock[_to].lockValue.safeSub(_value);
        totalLocked = totalLocked.safeSub(_value);  //reduce totalLocked
        emit ReduceLockValue(msg.sender, _to, _value);
        return true;
    }
    
    
    
    
    
    
    
    
    
    function createMultiSign(address[] memory _approvers, 
                             uint[] memory _individualScores, 
                             uint _initPassScore, 
                             address _backAccount, 
                             uint _initExpireDays) 
                             public returns(bool) 
    {
        require(_initPassScore > 0,"invalid pass score");
        require(false == isMultiSignActivated(msg.sender), "multiSign existed");
        require(_individualScores.length == _approvers.length,"arrays length mismatch");

        if (0 < multiSign[address(this)].approvers.length) clearMultiSign(address(this));  //have multiSign not activated and not expired, clean
        
        for (uint i = 0; i < _approvers.length; i++) {
            Approver memory a = Approver(_approvers[i],_individualScores[i].toUint64(),false);
            multiSign[msg.sender].approvers.push(a);
            emit MultiSignApprover(msg.sender, _approvers[i], _individualScores[i]);
        }
        multiSign[msg.sender].passScore = _initPassScore.toUint64();
        multiSign[msg.sender].expiration = (block.timestamp+_initExpireDays*1 days).toUint64();
        
        if (address(0) != _backAccount){
            multiSign[msg.sender].backAccount = _backAccount;
        } else {
            multiSign[msg.sender].backAccount = msg.sender;
        }
        
        emit CreateMultiSign(msg.sender,_initPassScore,_backAccount, _initExpireDays);
        return true;
    }
    
    
    
    
    
    function isMultiSignActivated(address _multisign) public returns (bool activated){
        uint score;
        uint length = multiSign[_multisign].approvers.length;
        if (multiSign[_multisign].expiration < block.timestamp && multiSign[_multisign].expiration != 0) { // if expired clean 
            clearMultiSign(_multisign); 
        }
        else{       //check if actived 
            for (uint i = 0; i < length; i++) {
                if(true == multiSign[_multisign].approvers[i].activated){
                    score += multiSign[_multisign].approvers[i].score;
                    if (score >= multiSign[_multisign].passScore) return true;
                }
            }
        }
        return false;
    }
    
    
    
    
    function isApprover(address _multisign) public view returns (bool presence) {
        uint length = multiSign[_multisign].approvers.length;
        require(length > 0, "multiSign not found");
        for (uint i = 0; i < length; i++) {
            if (msg.sender == multiSign[_multisign].approvers[i].addr){
                return true;
            }
        }
        return false;
    }
    
    
    
    
    function activateApprover(address _multisign) public returns(bool activated) 
    {
        require(isApprover(_multisign),"approver only");
        uint length = multiSign[_multisign].approvers.length;
        for (uint i = 0; i < length; i++) {
            if (msg.sender == multiSign[_multisign].approvers[i].addr){
                if(false == multiSign[_multisign].approvers[i].activated){
                    multiSign[_multisign].approvers[i].activated = true;
                }
                activated = true;
            }
        }
        return activated;
    }
    
    
    
    
    
    
    function freezeKeeper(address _multisign, bool _freeze) public returns(bool success) 
    {
        require(activateApprover(_multisign));
        vote[_multisign][msg.sender].holdBalance = _freeze;
        emit FreezeKeeper(msg.sender, _multisign, _freeze);

        uint length = multiSign[_multisign].approvers.length;
        uint score = 0;
        for (uint i = 0; i < length; i++) {                     //count score
            if (_freeze == vote[_multisign][multiSign[_multisign].approvers[i].addr].holdBalance) 
                score += multiSign[_multisign].approvers[i].score;            //count score by individual score weight
        }
        
        if (true == isMultiSignActivated(_multisign)
            && score >= multiSign[_multisign].passScore 
            && multiSign[_multisign].holdFlag != _freeze){           //check if reach passScore,and is necessary to update
            multiSign[_multisign].holdFlag = _freeze;                //update holdFlag
            emit HoldBalance(_multisign, _freeze);
        }
        
        return true;
    }
    
    
    
    
    function isMutltiSignHoldBalance(address _multisign) public view returns(bool flag){
        return multiSign[_multisign].holdFlag;
    }
    
    
    
    
    
    
    
    function approveTransferTo(address _multisign, address _to, uint _value) public returns(bool success) 
    {
        require(address(0) != _to,"transfer to address 0");
        require(activateApprover(_multisign));

        vote[_multisign][msg.sender].approveTrans.to = _to;
        vote[_multisign][msg.sender].approveTrans.value = _value;
        emit ApproveTransferTo(msg.sender,_multisign, _to, _value);
        
        uint length = multiSign[_multisign].approvers.length;
        uint score = 0;
        for (uint i = 0; i < length; i++) {                                    //count score
            if (_to == vote[_multisign][multiSign[_multisign].approvers[i].addr].approveTrans.to
                && _value == vote[_multisign][multiSign[_multisign].approvers[i].addr].approveTrans.value) 
                score += multiSign[_multisign].approvers[i].score;             //count score by individual score weight
        }
        
        if (true == isMultiSignActivated(_multisign)
            && score >= multiSign[_multisign].passScore){//check if reach passScore, execute recall
            require(_value <= multiSign[_multisign].multiSignBalance,"insufficent MultiSign balance");
            //reset to prevent errorly repeat transfer trigger by more vote 
            for (uint i = 0; i < length; i++) {                                                                
                if (_to == vote[_multisign][multiSign[_multisign].approvers[i].addr].approveTrans.to
                    && _value == vote[_multisign][multiSign[_multisign].approvers[i].addr].approveTrans.value) 
                {   
                    vote[_multisign][multiSign[_multisign].approvers[i].addr].approveTrans.to = address(0);        //reset
                    vote[_multisign][multiSign[_multisign].approvers[i].addr].approveTrans.value = 0;              //reset
                }
            }
            
            multiSign[_multisign].multiSignBalance = multiSign[_multisign].multiSignBalance.safeSub(_value);     //reduce multiSignBalance
            balanceOf[_to] = balanceOf[_to].safeAdd(_value);                   //increase receiver balance
            emit MultiSignTransfer(_multisign, _to, _value);
            totalLocked = totalLocked.safeSub(_value);  //reduce totalLocked
            }
        
        return true;
    }
    
    
    
    
    
    
    function recallToMultiSign(address _multisign, uint _value) public returns(bool success) 
    {
        require(activateApprover(_multisign));
        require(0 <_value);
        
        vote[_multisign][msg.sender].recall = _value;         //vote recall
        emit RecallToMultiSign(msg.sender, _multisign, _value);
        
        uint length = multiSign[_multisign].approvers.length;
        uint score = 0;
        for (uint i = 0; i < length; i++) {                     //count score
            if (_value == vote[_multisign][multiSign[_multisign].approvers[i].addr].recall) 
                score += multiSign[_multisign].approvers[i].score;             //count score by individual score weight
        }

        if (true == isMultiSignActivated(_multisign)
            && score >= multiSign[_multisign].passScore
            && balanceOf[_multisign] >= theLockValue(_multisign).safeAdd(_value)){//check if reach passScore and have enough balance, execute recall
            //reset to prevent errorly repeat transfer trigger by more vote
            for (uint i = 0; i < length; i++) {                     
                if (_value == vote[_multisign][multiSign[_multisign].approvers[i].addr].recall) 
                    vote[_multisign][multiSign[_multisign].approvers[i].addr].recall = 0;             //reset
            }
            balanceOf[_multisign] = balanceOf[_multisign].safeSub(_value);                                   //reduce keeper's balance
            multiSign[_multisign].multiSignBalance = multiSign[_multisign].multiSignBalance.safeAdd(_value); //increase multiSignBalance
            emit MultiSignRecall(_multisign, _value);
            totalLocked = totalLocked.safeAdd(_value);                                                     //increase totalLocked
        }
        
        return true;
    }
    
    
    
    
    
    
    function updateExpiration(address _multisign, uint _expireDays) public returns(bool success) 
    {
        require (activateApprover(_multisign));

        _expireDays = _expireDays.safeAdd(1);     //add vote guard
        
        vote[_multisign][msg.sender].expireDays = _expireDays.toUint64();     //vote expireDays
        emit UpdateExpiration(msg.sender, _multisign, _expireDays);
        
        uint length = multiSign[_multisign].approvers.length;
        uint score = 0;
        for (uint i = 0; i < length; i++) {                     //count score
            if (_expireDays == vote[_multisign][multiSign[_multisign].approvers[i].addr].expireDays) 
                score += multiSign[_multisign].approvers[i].score;            //count score by individual score weight
        }
        
        if (true == isMultiSignActivated(_multisign)
            && score >= multiSign[_multisign].passScore){                         //check if reach passScore,
            for (uint i = 0; i < length; i++) {
                vote[_multisign][multiSign[_multisign].approvers[i].addr].expireDays = 0;   //clear voted data
            }  
            _expireDays -= 1;   //clear vote guard
            multiSign[_multisign].expiration = (block.timestamp + (_expireDays) * 1 days).toUint64();             //update multisign expire
            emit MultiSignExpirationUpdated(_multisign, _expireDays);
        }
        
        return true;
    }
    
    
    
    
    
    
    function updateBackAccount(address _multisign, address _newBackAccount) public returns(bool success)
    {
        require (address(0) != _newBackAccount,"invalid address");
        require (activateApprover(_multisign));
        vote[_multisign][msg.sender].backAccount = _newBackAccount;     //vote backAccount
        emit UpdateBackAccount(msg.sender, _multisign, _newBackAccount);
        
        uint length = multiSign[_multisign].approvers.length;
        uint score = 0;
        for (uint i = 0; i < length; i++) {                     //count score
            if (_newBackAccount == vote[_multisign][multiSign[_multisign].approvers[i].addr].backAccount) 
                score += multiSign[_multisign].approvers[i].score;            //count score by individual score weight
        }
        
        if (true == isMultiSignActivated(_multisign)
            && score >= multiSign[_multisign].passScore
            && multiSign[_multisign].backAccount != _newBackAccount){     //check if reach passScore,
            multiSign[_multisign].backAccount = _newBackAccount;             //update multisign backAccount
            emit MultiSignBackAccountUpdated(_multisign, _newBackAccount);
        }
        
        return true;
    }
    
    
    
    
    function cancelVote(address _multisign) public returns(bool success) 
    {
        require (activateApprover(_multisign));
        delete vote[_multisign][msg.sender];
        emit CancelVote(msg.sender,_multisign);
        return true;
    }
    
    
    
    
    
    function transferToMultiSign(address _multisign, uint _value) public returns(bool success) 
    {
        require (address(0) != _multisign,"transfer to address 0");
        require (balanceOf[msg.sender] >= theLockValue(msg.sender).safeAdd(_value),"insufficient balance or locked");
        require (isMultiSignActivated(_multisign),"multisign not activated");
        require (false == isMutltiSignHoldBalance(msg.sender), "multisign balance hold");

        balanceOf[msg.sender] = balanceOf[msg.sender].safeSub(_value);                                    //subtract from the sender
        multiSign[_multisign].multiSignBalance = multiSign[_multisign].multiSignBalance.safeAdd(_value);    //add to the multisignbalance
        emit TransferToMultiSign(msg.sender, _multisign, _value);
        totalLocked = totalLocked.safeAdd(_value);                                                     //increase totalLocked
        return true;
    }
    
    
    
    
    function getBalanceOfMultiSign(address _multisign) public view returns(uint balanceOfMultiSign) 
    {
        return multiSign[_multisign].multiSignBalance;
    }
    
    
    
    
    function getApproversOfMultiSign(address _multisign) public view returns(Approver[] memory approvers) 
    {
        return multiSign[_multisign].approvers;
    }
    
    
    
    
    function clearMultiSign(address _multisign) public returns (bool success) {
        require(isApprover(_multisign) || msg.sender == _multisign);
        
        uint score;
        uint length = multiSign[_multisign].approvers.length;
        for (uint i = 0; i < length; i++) {
            if(true == multiSign[_multisign].approvers[i].activated){
                score += multiSign[_multisign].approvers[i].score;
            }
        }
        
        require(score < multiSign[_multisign].passScore || multiSign[_multisign].expiration < block.timestamp);
            
        for (uint i = 0; i < length; i++) {
            delete vote[_multisign][multiSign[_multisign].approvers[i].addr];   //clear votes
        }
           
        address bAccount = multiSign[_multisign].backAccount;
        uint value = multiSign[_multisign].multiSignBalance;
        if (address(0) != bAccount && 0 < value){                                 //transfer balance to backAccount
            balanceOf[bAccount] = balanceOf[bAccount].safeAdd(value); 
            totalLocked = totalLocked.safeSub(value);   //reduce totalLocked
        }

        delete multiSign[_multisign];                                           //remove multiSign
        emit ClearMutiSign(msg.sender,_multisign,bAccount,value);
        return true;
    }
    
    
    
    
    
    function transferForMultiAddresses(address[] memory _addresses, uint256[] memory _amounts) public returns (bool) {
        require(_addresses.length == _amounts.length,"arrays length mismatch");
        require (false == isMutltiSignHoldBalance(msg.sender), "multisign balance hold");

        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0),"transfer to address 0");
            if (balanceOf[msg.sender] < theLockValue(msg.sender).safeAdd(_amounts[i])) revert("insufficient balance or locked");

            balanceOf[msg.sender] = balanceOf[msg.sender].safeSub(_amounts[i]);
            balanceOf[_addresses[i]] = balanceOf[_addresses[i]].safeAdd(_amounts[i]);
            emit Transfer(msg.sender, _addresses[i], _amounts[i]);
        }
        return true;
    }
    
    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success){
        if (_to == address(0)) revert("transfert to address 0");
        require (false == isMutltiSignHoldBalance(msg.sender), "multisign balance hold");
        require (balanceOf[msg.sender] >= theLockValue(msg.sender).safeAdd(_value),"insufficient balance or locked");

        balanceOf[msg.sender] = balanceOf[msg.sender].safeSub(_value);
        balanceOf[_to] = balanceOf[_to].safeAdd(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (_to != address(0), "transfert to address 0");
        require (_value <= allowance[_from][msg.sender],"transfer more than allowance");
        require (false == isMutltiSignHoldBalance(_from), "multisign balance hold");
        require (balanceOf[_from] >= theLockValue(_from).safeAdd(_value),"insufficient balance or locked");

        allowance[_from][msg.sender] = allowance[_from][msg.sender].safeSub(_value);
        balanceOf[_from] = balanceOf[_from].safeSub(_value);
        balanceOf[_to] = balanceOf[_to].safeAdd(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }
    
    
    
    
    
    function burn(uint256 _value) public returns (bool success) {
        require (balanceOf[msg.sender] >= theLockValue(msg.sender).safeAdd(_value), "insufficient balance or locked");
        require (false == isMutltiSignHoldBalance(msg.sender), "multisign balance hold");

        balanceOf[msg.sender] = balanceOf[msg.sender].safeSub(_value);
        _supplyCap = _supplyCap.safeSub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }
    
    
    
    
    
    function freeze(uint256 _value) public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert("insufficient balance");

        balanceOf[msg.sender] = balanceOf[msg.sender].safeSub(_value);
        freezeOf[msg.sender] = freezeOf[msg.sender].safeAdd(_value);
        emit Freeze(msg.sender, _value);
        return true;
    }

    
    
    
    
    function unfreeze(uint256 _value) public returns (bool success) {
        if (freezeOf[msg.sender] < _value) revert("insufficient balance.");

        freezeOf[msg.sender] = freezeOf[msg.sender].safeSub(_value);
        balanceOf[msg.sender] = balanceOf[msg.sender].safeAdd(_value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }

 }