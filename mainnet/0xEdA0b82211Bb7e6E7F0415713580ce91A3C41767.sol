// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.7;



interface IGaugeProxy {
  
  
  function totalWeight() external returns (uint256 _totalWeight);

  
  function keeper() external returns (address _keeper);

  
  
  function gov() external returns (address _gov);

  
  function nextgov() external returns (address _nextGov);

  
  function commitgov() external returns (uint256 _commitGov);

  
  function delay() external returns (uint256 _delay);

  
  
  function gauges(address _pool) external view returns (address _gauge);

  
  
  function weights(address _pool) external view returns (uint256 _weight);

  
  
  
  
  function votes(address _voter, address _pool) external view returns (uint256 _votes);

  
  
  
  function tokenVote(address _voter, uint256 _i) external view returns (address _pool);

  
  
  function usedWeights(address _voter) external view returns (uint256 _usedWeights);

  
  
  function enabled(address _pool) external view returns (bool _enabled);

  
  function tokens() external view returns (address[] memory _pools);

  
  
  function setKeeper(address _keeper) external;

  
  function setGov(address _gov) external;

  
  
  function acceptGov() external;

  
  function reset() external;

  
  
  
  function poke(address _voter) external;

  
  
  
  
  function vote(address[] calldata _poolVote, uint256[] calldata _weights) external;

  
  
  
  function addGauge(address _pool, address _gauge) external;

  
  
  
  function disable(address _pool) external;

  
  
  function enable(address _pool) external;

  /// returns _lenght Total amount of rewarded pools
  function length() external view returns (uint256 _lenght);

  
  function forceDistribute() external;

  
  function distribute() external;
}// 
pragma solidity ^0.8.12;








contract GaugeProxyV2 is IGaugeProxy {
  address constant _rkp3r = 0xEdB67Ee1B171c4eC66E6c10EC43EDBbA20FaE8e9;
  address constant _vkp3r = 0x2FC52C61fB0C03489649311989CE2689D93dC1a2;
  address constant _kp3rV1 = 0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44;
  address constant _kp3rV1Proxy = 0x976b01c02c636Dd5901444B941442FD70b86dcd5;
  address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

  
  uint256 public totalWeight;

  
  address public keeper;
  
  address public gov;
  
  address public nextgov;
  
  uint256 public commitgov;
  
  uint256 public constant delay = 1 days;

  address[] internal _tokens;
  
  mapping(address => address) public gauges; // token => gauge
  
  mapping(address => uint256) public weights; // token => weight
  
  mapping(address => mapping(address => uint256)) public votes; // msg.sender => votes
  
  mapping(address => address[]) public tokenVote; // msg.sender => token
  
  mapping(address => uint256) public usedWeights; // msg.sender => total voting weight of user
  
  mapping(address => bool) public enabled;

  
  function tokens() external view returns (address[] memory) {
    return _tokens;
  }

  constructor(address _gov) {
    gov = _gov;
    _safeApprove(_kp3rV1, _rkp3r, type(uint256).max);
  }

  modifier g() {
    require(msg.sender == gov);
    _;
  }

  modifier k() {
    require(msg.sender == keeper);
    _;
  }

  
  function setKeeper(address _keeper) external g {
    keeper = _keeper;
  }

  
  function setGov(address _gov) external g {
    nextgov = _gov;
    commitgov = block.timestamp + delay;
  }

  
  function acceptGov() external {
    require(msg.sender == nextgov && commitgov < block.timestamp);
    gov = nextgov;
  }

  
  function reset() external {
    _reset(msg.sender);
  }

  function _reset(address _owner) internal {
    address[] storage _tokenVote = tokenVote[_owner];
    uint256 _tokenVoteCnt = _tokenVote.length;

    for (uint256 i = 0; i < _tokenVoteCnt; i++) {
      address _token = _tokenVote[i];
      uint256 _votes = votes[_owner][_token];

      if (_votes > 0) {
        totalWeight -= _votes;
        weights[_token] -= _votes;
        votes[_owner][_token] = 0;
      }
    }

    delete tokenVote[_owner];
  }

  
  function poke(address _owner) public {
    address[] memory _tokenVote = tokenVote[_owner];
    uint256 _tokenCnt = _tokenVote.length;
    uint256[] memory _weights = new uint256[](_tokenCnt);

    uint256 _prevUsedWeight = usedWeights[_owner];
    uint256 _weight = IvKP3R(_vkp3r).get_adjusted_ve_balance(_owner, ZERO_ADDRESS);

    for (uint256 i = 0; i < _tokenCnt; i++) {
      uint256 _prevWeight = votes[_owner][_tokenVote[i]];
      _weights[i] = (_prevWeight * _weight) / _prevUsedWeight;
    }

    _vote(_owner, _tokenVote, _weights);
  }

  function _vote(
    address _owner,
    address[] memory _tokenVote,
    uint256[] memory _weights
  ) internal {
    // _weights[i] = percentage * 100
    _reset(_owner);
    uint256 _tokenCnt = _tokenVote.length;
    uint256 _weight = IvKP3R(_vkp3r).get_adjusted_ve_balance(_owner, ZERO_ADDRESS);
    uint256 _totalVoteWeight = 0;
    uint256 _usedWeight = 0;

    for (uint256 i = 0; i < _tokenCnt; i++) {
      _totalVoteWeight += _weights[i];
    }

    for (uint256 i = 0; i < _tokenCnt; i++) {
      address _token = _tokenVote[i];
      address _gauge = gauges[_token];
      uint256 _tokenWeight = (_weights[i] * _weight) / _totalVoteWeight;

      if (_gauge != address(0x0)) {
        _usedWeight += _tokenWeight;
        totalWeight += _tokenWeight;
        weights[_token] += _tokenWeight;
        tokenVote[_owner].push(_token);
        votes[_owner][_token] = _tokenWeight;
      }
    }

    usedWeights[_owner] = _usedWeight;
  }

  
  function vote(address[] calldata _tokenVote, uint256[] calldata _weights) external {
    require(_tokenVote.length == _weights.length);
    _vote(msg.sender, _tokenVote, _weights);
  }

  
  function addGauge(address _token, address _gauge) external g {
    require(gauges[_token] == address(0x0), 'exists');
    _safeApprove(_rkp3r, _gauge, type(uint256).max);
    gauges[_token] = _gauge;
    enabled[_token] = true;
    _tokens.push(_token);
  }

  
  function disable(address _token) external g {
    enabled[_token] = false;
  }

  
  function enable(address _token) external g {
    enabled[_token] = true;
  }

  
  function length() external view returns (uint256) {
    return _tokens.length;
  }

  
  function forceDistribute() external g {
    _distribute();
  }

  
  function distribute() external k {
    _distribute();
  }

  function _distribute() internal {
    uint256 _balance = IKeep3rV1Proxy(_kp3rV1Proxy).draw();
    IrKP3R(_rkp3r).deposit(_balance);

    if (_balance > 0 && totalWeight > 0) {
      uint256 _totalWeight = totalWeight;
      for (uint256 i = 0; i < _tokens.length; i++) {
        if (!enabled[_tokens[i]]) {
          _totalWeight -= weights[_tokens[i]];
        }
      }
      for (uint256 x = 0; x < _tokens.length; x++) {
        if (enabled[_tokens[x]]) {
          uint256 _reward = (_balance * weights[_tokens[x]]) / _totalWeight;
          if (_reward > 0) {
            address _gauge = gauges[_tokens[x]];
            IGauge(_gauge).deposit_reward_token(_rkp3r, _reward);
          }
        }
      }
    }
  }

  function _safeApprove(
    address token,
    address spender,
    uint256 value
  ) internal {
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, spender, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))));
  }
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rV1Proxy {
  // Structs
  struct Recipient {
    address recipient;
    uint256 caps;
  }

  // Variables
  function keep3rV1() external view returns (address);

  function minter() external view returns (address);

  function next(address) external view returns (uint256);

  function caps(address) external view returns (uint256);

  function recipients() external view returns (address[] memory);

  function recipientsCaps() external view returns (Recipient[] memory);

  // Errors
  error Cooldown();
  error NoDrawableAmount();
  error ZeroAddress();
  error OnlyMinter();

  // Methods
  function addRecipient(address _recipient, uint256 _amount) external;

  function removeRecipient(address _recipient) external;

  function draw() external returns (uint256 _amount);

  function setKeep3rV1(address _keep3rV1) external;

  function setMinter(address _minter) external;

  function mint(uint256 _amount) external;

  function mint(address _account, uint256 _amount) external;

  function setKeep3rV1Governance(address _governance) external;

  function acceptKeep3rV1Governance() external;

  function dispute(address _keeper) external;

  function slash(
    address _bonded,
    address _keeper,
    uint256 _amount
  ) external;

  function revoke(address _keeper) external;

  function resolve(address _keeper) external;

  function addJob(address _job) external;

  function removeJob(address _job) external;

  function addKPRCredit(address _job, uint256 _amount) external;

  function approveLiquidity(address _liquidity) external;

  function revokeLiquidity(address _liquidity) external;

  function setKeep3rHelper(address _keep3rHelper) external;

  function addVotes(address _voter, uint256 _amount) external;

  function removeVotes(address _voter, uint256 _amount) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IvKP3R {
  // solhint-disable-next-line func-name-mixedcase
  function get_adjusted_ve_balance(address, address) external view returns (uint256);
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IrKP3R {
  function deposit(uint256 _amount) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IGauge {
  // solhint-disable-next-line func-name-mixedcase
  function deposit_reward_token(address, uint256) external;
}
