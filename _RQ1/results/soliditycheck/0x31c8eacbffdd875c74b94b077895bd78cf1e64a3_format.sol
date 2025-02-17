  pragma experimental ABIEncoderV2;
 pragma solidity ^0.7.5;
 contract RadicleToken {
 string public constant NAME = "Radicle";
 string public constant SYMBOL = "RAD";
 uint8 public constant DECIMALS = 18;
 uint256 public totalSupply = 100000000e18;
 mapping(address => mapping(address => uint96)) internal allowances;
 mapping(address => uint96) internal balances;
 mapping(address => address) public delegates;
 struct Checkpoint {
 uint32 fromBlock;
 uint96 votes;
 }
 mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
 mapping(address => uint32) public numCheckpoints;
 bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
 bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
 bytes32 public constant PERMIT_TYPEHASH = keccak256( "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)" );
 mapping(address => uint256) public nonces;
 event DelegateChanged( address indexed delegator, address indexed fromDelegate, address indexed toDelegate );
 event DelegateVotesChanged( address indexed delegate, uint256 previousBalance, uint256 newBalance );
 event Transfer(address indexed from, address indexed to, uint256 amount);
 event Approval(address indexed owner, address indexed spender, uint256 amount);
 constructor(address account) {
 balances[account] = uint96(totalSupply);
 emit Transfer(address(0), account, totalSupply);
 }
 function name() public pure returns (string memory) {
 return NAME;
 }
 function symbol() public pure returns (string memory) {
 return SYMBOL;
 }
 function decimals() public pure returns (uint8) {
 return DECIMALS;
 }
 function DOMAIN_SEPARATOR() public view returns (bytes32) {
 return keccak256( abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(NAME)), getChainId(), address(this)) );
 }
 function allowance(address account, address spender) external view returns (uint256) {
 return allowances[account][spender];
 }
 function approve(address spender, uint256 rawAmount) external returns (bool) {
 _approve(msg.sender, spender, rawAmount);
 return true;
 }
 function _approve( address owner, address spender, uint256 rawAmount ) internal {
 uint96 amount;
 if (rawAmount == uint256(-1)) {
 amount = uint96(-1);
 }
 else {
 amount = safe96(rawAmount, "RadicleToken::approve: amount exceeds 96 bits");
 }
 allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function balanceOf(address account) external view returns (uint256) {
 return balances[account];
 }
 function transfer(address dst, uint256 rawAmount) external returns (bool) {
 uint96 amount = safe96(rawAmount, "RadicleToken::transfer: amount exceeds 96 bits");
 _transferTokens(msg.sender, dst, amount);
 return true;
 }
 function transferFrom( address src, address dst, uint256 rawAmount ) external returns (bool) {
 address spender = msg.sender;
 uint96 spenderAllowance = allowances[src][spender];
 uint96 amount = safe96(rawAmount, "RadicleToken::approve: amount exceeds 96 bits");
 if (spender != src && spenderAllowance != uint96(-1)) {
 uint96 newAllowance = sub96( spenderAllowance, amount, "RadicleToken::transferFrom: transfer amount exceeds spender allowance" );
 allowances[src][spender] = newAllowance;
 emit Approval(src, spender, newAllowance);
 }
 _transferTokens(src, dst, amount);
 return true;
 }
 function burnFrom(address account, uint256 rawAmount) public {
 require(account != address(0), "RadicleToken::burnFrom: cannot burn from the zero address");
 uint96 amount = safe96(rawAmount, "RadicleToken::burnFrom: amount exceeds 96 bits");
 address spender = msg.sender;
 uint96 spenderAllowance = allowances[account][spender];
 if (spender != account && spenderAllowance != uint96(-1)) {
 uint96 newAllowance = sub96( spenderAllowance, amount, "RadicleToken::burnFrom: burn amount exceeds allowance" );
 allowances[account][spender] = newAllowance;
 emit Approval(account, spender, newAllowance);
 }
 balances[account] = sub96( balances[account], amount, "RadicleToken::burnFrom: burn amount exceeds balance" );
 emit Transfer(account, address(0), amount);
 _moveDelegates(delegates[account], address(0), amount);
 totalSupply -= rawAmount;
 }
 function delegate(address delegatee) public {
 return _delegate(msg.sender, delegatee);
 }
 function delegateBySig( address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s ) public {
 bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
 bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash));
 address signatory = ecrecover(digest, v, r, s);
 require(signatory != address(0), "RadicleToken::delegateBySig: invalid signature");
 require(nonce == nonces[signatory]++, "RadicleToken::delegateBySig: invalid nonce");
 require(block.timestamp <= expiry, "RadicleToken::delegateBySig: signature expired");
 _delegate(signatory, delegatee);
 }
 function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) public {
 bytes32 structHash = keccak256( abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline) );
 bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash));
 require(owner == ecrecover(digest, v, r, s), "RadicleToken::permit: invalid signature");
 require(owner != address(0), "RadicleToken::permit: invalid signature");
 require(block.timestamp <= deadline, "RadicleToken::permit: signature expired");
 _approve(owner, spender, value);
 }
 function getCurrentVotes(address account) external view returns (uint96) {
 uint32 nCheckpoints = numCheckpoints[account];
 return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
 }
 function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {
 require(blockNumber < block.number, "RadicleToken::getPriorVotes: not yet determined");
 uint32 nCheckpoints = numCheckpoints[account];
 if (nCheckpoints == 0) {
 return 0;
 }
 if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
 return checkpoints[account][nCheckpoints - 1].votes;
 }
 if (checkpoints[account][0].fromBlock > blockNumber) {
 return 0;
 }
 uint32 lower = 0;
 uint32 upper = nCheckpoints - 1;
 while (upper > lower) {
 uint32 center = upper - (upper - lower) / 2;
 Checkpoint memory cp = checkpoints[account][center];
 if (cp.fromBlock == blockNumber) {
 return cp.votes;
 }
 else if (cp.fromBlock < blockNumber) {
 lower = center;
 }
 else {
 upper = center - 1;
 }
 }
 return checkpoints[account][lower].votes;
 }
 function _delegate(address delegator, address delegatee) internal {
 address currentDelegate = delegates[delegator];
 uint96 delegatorBalance = balances[delegator];
 delegates[delegator] = delegatee;
 emit DelegateChanged(delegator, currentDelegate, delegatee);
 _moveDelegates(currentDelegate, delegatee, delegatorBalance);
 }
 function _transferTokens( address src, address dst, uint96 amount ) internal {
 require( src != address(0), "RadicleToken::_transferTokens: cannot transfer from the zero address" );
 require( dst != address(0), "RadicleToken::_transferTokens: cannot transfer to the zero address" );
 balances[src] = sub96( balances[src], amount, "RadicleToken::_transferTokens: transfer amount exceeds balance" );
 balances[dst] = add96( balances[dst], amount, "RadicleToken::_transferTokens: transfer amount overflows" );
 emit Transfer(src, dst, amount);
 _moveDelegates(delegates[src], delegates[dst], amount);
 }
 function _moveDelegates( address srcRep, address dstRep, uint96 amount ) internal {
 if (srcRep != dstRep && amount > 0) {
 if (srcRep != address(0)) {
 uint32 srcRepNum = numCheckpoints[srcRep];
 uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
 uint96 srcRepNew = sub96(srcRepOld, amount, "RadicleToken::_moveVotes: vote amount underflows");
 _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
 }
 if (dstRep != address(0)) {
 uint32 dstRepNum = numCheckpoints[dstRep];
 uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
 uint96 dstRepNew = add96(dstRepOld, amount, "RadicleToken::_moveVotes: vote amount overflows");
 _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
 }
 }
 }
 function _writeCheckpoint( address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes ) internal {
 uint32 blockNumber = safe32(block.number, "RadicleToken::_writeCheckpoint: block number exceeds 32 bits");
 if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
 checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
 }
 else {
 checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
 numCheckpoints[delegatee] = nCheckpoints + 1;
 }
 emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
 }
 function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
 require(n < 2**32, errorMessage);
 return uint32(n);
 }
 function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
 require(n < 2**96, errorMessage);
 return uint96(n);
 }
 function add96( uint96 a, uint96 b, string memory errorMessage ) internal pure returns (uint96) {
 uint96 c = a + b;
 require(c >= a, errorMessage);
 return c;
 }
 function sub96( uint96 a, uint96 b, string memory errorMessage ) internal pure returns (uint96) {
 require(b <= a, errorMessage);
 return a - b;
 }
 function getChainId() internal pure returns (uint256) {
 uint256 chainId;
 assembly {
 chainId := chainid() }
 return chainId;
 }
 }
