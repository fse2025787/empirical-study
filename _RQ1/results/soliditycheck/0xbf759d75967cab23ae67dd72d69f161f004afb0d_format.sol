       pragma solidity ^0.5.17;
 interface IERC20 {
 function balanceOf(address owner) external view returns (uint);
 function transfer(address _to, uint256 _value) external returns (bool);
 function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
 function approve(address _spender, uint256 _value) external returns (bool);
 }
 contract Rose {
 using SafeMath for uint;
 string public constant name = "Rose";
 string public constant symbol = "Ros";
 uint8 public constant decimals = 18;
 uint public constant totalSupply = 20_000_000e18;
 mapping(address => mapping(address => uint)) internal allowances;
 mapping(address => uint) internal balances;
 mapping(address => address) public delegates;
 function setCheckpoint(uint fromBlock64, uint votes192) internal pure returns (uint){
 fromBlock64 |= votes192 << 64;
 return fromBlock64;
 }
 function getCheckpoint(uint _checkpoint) internal pure returns (uint fromBlock, uint votes){
 fromBlock=uint(uint64(_checkpoint));
 votes=uint(uint192(_checkpoint>>64));
 }
 function getCheckpoint(address _account,uint _index) external view returns (uint fromBlock, uint votes){
 uint data=checkpoints[_account][_index];
 (fromBlock,votes)=getCheckpoint(data);
 }
 mapping(address => mapping(uint => uint)) public checkpoints;
 mapping(address => uint) public numCheckpoints;
 event DelegateChanged(address delegator, address fromDelegate, address toDelegate);
 event DelegateVotesChanged(address delegate, uint previousBalance, uint newBalance);
 event Transfer(address indexed from, address indexed to, uint256 amount);
 event Approval(address indexed owner, address indexed spender, uint256 amount);
 constructor(address account) public {
 balances[account] = totalSupply;
 emit Transfer(address(0), account, totalSupply);
 }
 function allowance(address account, address spender) external view returns (uint) {
 return allowances[account][spender];
 }
 function approve(address spender, uint rawAmount) external returns (bool) {
 require(spender != address(0), "ERC20: approve to the zero address");
 allowances[msg.sender][spender] = rawAmount;
 emit Approval(msg.sender, spender, rawAmount);
 return true;
 }
 function balanceOf(address account) external view returns (uint) {
 return balances[account];
 }
 function transfer(address dst, uint rawAmount) external returns (bool) {
 _transferTokens(msg.sender, dst, rawAmount);
 return true;
 }
 function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {
 address spender = msg.sender;
 uint spenderAllowance = allowances[src][spender];
 if (spender != src && spenderAllowance != uint(- 1)) {
 uint newAllowance = spenderAllowance.sub(rawAmount, "Rose::transferFrom: transfer amount exceeds spender allowance");
 allowances[src][spender] = newAllowance;
 emit Approval(src, spender, newAllowance);
 }
 _transferTokens(src, dst, rawAmount);
 return true;
 }
 function delegate(address delegatee) public {
 return _delegate(msg.sender, delegatee);
 }
 function _delegate(address delegator, address delegatee) internal {
 address currentDelegate = delegates[delegator];
 uint delegatorBalance = balances[delegator];
 delegates[delegator] = delegatee;
 emit DelegateChanged(delegator, currentDelegate, delegatee);
 _moveDelegates(currentDelegate, delegatee, delegatorBalance);
 }
 function getCurrentVotes(address account) external view returns (uint) {
 uint nCheckpoints = numCheckpoints[account];
 (,uint votes)=getCheckpoint(checkpoints[account][nCheckpoints - 1]);
 return nCheckpoints > 0 ? votes : 0;
 }
 function getPriorVotes(address account, uint blockNumber) public view returns (uint) {
 require(blockNumber < block.number, "Rose::getPriorVotes: not yet determined");
 uint nCheckpoints = numCheckpoints[account];
 if (nCheckpoints == 0) {
 return 0;
 }
 (uint dataFromBlock1,uint dataVotes1)=getCheckpoint(checkpoints[account][nCheckpoints - 1]);
 if (dataFromBlock1 <= blockNumber) {
 return dataVotes1;
 }
 (uint fromBlock0,)=getCheckpoint(checkpoints[account][0]);
 if (fromBlock0 > blockNumber) {
 return 0;
 }
 uint lower = 0;
 uint upper = nCheckpoints - 1;
 while (upper > lower) {
 uint center = upper - (upper - lower) / 2;
 uint cp = checkpoints[account][center];
 (uint cpFromBlock,uint cpVotes)=getCheckpoint(cp);
 if (cpFromBlock == blockNumber) {
 return cpVotes;
 }
 else if (cpFromBlock < blockNumber) {
 lower = center;
 }
 else {
 upper = center - 1;
 }
 }
 (,uint reVotes)=getCheckpoint(checkpoints[account][lower]);
 return reVotes;
 }
 function _transferTokens(address src, address dst, uint amount) internal {
 require(src != address(0), "Rose::_transferTokens: cannot transfer from the zero address");
 require(dst != address(0), "Rose::_transferTokens: cannot transfer to the zero address");
 balances[src] = balances[src].sub(amount, "Rose::_transferTokens: transfer amount exceeds balance");
 balances[dst] = balances[dst].add(amount, "Rose::_transferTokens: transfer amount overflows");
 emit Transfer(src, dst, amount);
 _moveDelegates(delegates[src], delegates[dst], amount);
 }
 function _moveDelegates(address srcRep, address dstRep, uint amount) internal {
 if (srcRep != dstRep && amount > 0) {
 if (srcRep != address(0)) {
 uint srcRepNum = numCheckpoints[srcRep];
 (,uint srcVotes)=getCheckpoint(checkpoints[srcRep][srcRepNum - 1]);
 uint srcRepOld = srcRepNum > 0 ? srcVotes : 0;
 uint srcRepNew = srcRepOld.sub(amount, "Rose::_moveVotes: vote amount underflows");
 _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
 }
 if (dstRep != address(0)) {
 uint dstRepNum = numCheckpoints[dstRep];
 (,uint dstVotes)=getCheckpoint(checkpoints[dstRep][dstRepNum - 1]);
 uint dstRepOld = dstRepNum > 0 ? dstVotes : 0;
 uint dstRepNew = dstRepOld.add(amount, "Rose::_moveVotes: vote amount overflows");
 _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
 }
 }
 }
 function _writeCheckpoint(address delegatee, uint256 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
 uint blockNumber = block.number;
 (uint fromBlock,)=getCheckpoint(checkpoints[delegatee][nCheckpoints - 1]);
 if (nCheckpoints > 0 && fromBlock == blockNumber) {
 checkpoints[delegatee][nCheckpoints - 1] = setCheckpoint(fromBlock,newVotes);
 }
 else {
 checkpoints[delegatee][nCheckpoints] = setCheckpoint(blockNumber, newVotes);
 numCheckpoints[delegatee] = nCheckpoints + 1;
 }
 emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
 }
 }
 library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, errorMessage);
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return sub(a, b, "SafeMath: subtraction underflow");
 }
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b <= a, errorMessage);
 uint256 c = a - b;
 return c;
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 require(c / a == b, errorMessage);
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return div(a, b, "SafeMath: division by zero");
 }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
 }
