# Manual Audit Rules

> Table 5. Manual audit rules and true positive confirmation.

| Vulnerability | Audit Rules | True Positive |
| ------------- | ----------- | ------------- |
| REN | 𝑅1: Contains executable external calls by any caller. <br> 𝑅2: The address for the external call can be any contract or account. <br> 𝑅3: The external call is followed by statements that modify non-local variables or make additional external calls. | 𝑅1 ∧ 𝑅2 ∧ 𝑅3 |
| USI | 𝑅1: Contains executable built-in suicide/selfdestruct functions. <br> 𝑅2: suicide/selfdestruct can be executed by any caller. <br> 𝑅3: The recipient address of suicide/selfdestruct is the caller (msg.sender/tx.origin) or can be modified arbitrarily by the caller.| 𝑅1 ∧ 𝑅2 ∧ 𝑅3 |
| TXO | 𝑅1: tx.origin is used in executable conditional statements (e.g., require and if)for authentication. <br> 𝑅2: The current caller (msg.sender) is not an account address but can be any contract address.| 𝑅1 ∧ 𝑅2 |
| UEW | 𝑅1: Contains Ether withdrawal operations (e.g., call/send/transfer function calls), which can be successfully executed by any caller in the current contract. <br> 𝑅2: The recipient address of the withdrawal operation is the caller (msg.sender/tx.origin) or can be modified arbitrarily by the caller. <br> 𝑅3: The amount of the withdrawal operation can be changed to any value greater than the call payment (msg.value) or equal to the balance of the contract.| 𝑅1 ∧ 𝑅2 ∧ 𝑅3 |
| IOU | 𝑅1: Contains executable integer arithmetic operations (e.g., +, -,* ,/ ,** ,++ ,–, +=, -=, *=, /=). <br> 𝑅2: The operands can be modified by the caller to any value. <br> 𝑅3: The results of arithmetic operations are not checked for integer overflow and underflow.| 𝑅1 ∧ 𝑅2 ∧ 𝑅3 |

## REN Examples

### 👍Ture Positive
Address: 0x5f2c5cfeb3e752c32a9d8224854fe0b6e523d78e
```Javascript
    function transfer(address _to, uint _value, bytes _data) public {
        require(_value > 0 );
        if(isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data); // TP
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
    }
```

### 👎 False Positive
Address: 0xc6b12db89f680cf4ae57bc81d961bec3e664719d ~R1~R2
```Javascript
  function tokenBalance() constant public returns (uint256){
    return token_reward.balanceOf(this);
  }

  function lock() public onlyOwner returns (bool){
  	require(!isLocked);
  	require(tokenBalance() > 0); // FP
  	start_time = now;
  	end_time = start_time.add(fifty_two_weeks);
  	isLocked = true;
  }
```

## USI Examples

### 👍Ture Positive
Address: 0x01D2A52708d0D8FC4D639F09a13AE87a2aeC4390
```Javascript
    function destroycontract(address _to) {

        selfdestruct(_to); // TP

    }
```

### 👎 False Positive
Address: 0xCf8719E3767De77C28F935B30E59b8896f0454f9 ~R3
```Javascript
  function play(uint256 _number) 
  public 
  payable 
  {
      if(msg.value >= minBet && _number <= 1)
      {
          GameHistory gameHistory;
          gameHistory.player = msg.sender;
          gameHistory.number = _number;
          log.push(gameHistory);
          
          // if player guesses correctly, transfer contract balance
          // else transfer to owner
       
          if (_number == randomNumber) 
          {
              selfdestruct(msg.sender); // FP
          }else{
              selfdestruct(owner);
          }
          
      }
  }

```

## TXO Examples

### 👍Ture Positive
Address: 0x136b1e6e149f0dadf3c662fb6feec3d7587aaadd
```Javascript
    modifier onlyAdministrator() {
        require(administrator == tx.origin); // TP
        _;
    }
```

### 👎 False Positive
Address: 0xf37aa5f945688488056f32112267570517bbc303  ~R2
```Javascript
    modifier isHuman() {
        address _addr = msg.sender;
        require (_addr == tx.origin); // FP

        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
```

## UEW Examples

### 👍Ture Positive
Address: 0x072593300D48063b29e4662BF6496D8fF563298E
```Javascript
    /**
     * Send the amount of token to an address
     * @param _amount amount of token
     * @param _token token address
     */
    function send(GlobalConfig globalConfig, uint256 _amount, address _token) public {
        if (Utils._isETH(address(globalConfig), _token)) {
            msg.sender.transfer(_amount); // TP
        } else {
            IERC20(_token).safeTransfer(msg.sender, _amount);
        }
    }
```

### 👎 False Positive
Address: 0xF99881fDa3E24b16fA49b0d8359813b1e072a447  ~R1~R2
```Javascript
    function payFund() payable onlyAdministrator() public {
        uint256 ethToPay = SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
        require(ethToPay > 0);
        totalEthFundRecieved = SafeMath.add(totalEthFundRecieved, ethToPay);
        if(!giveEthFundAddress.call.value(ethToPay).gas(400000)()) { // FP
          totalEthFundRecieved = SafeMath.sub(totalEthFundRecieved, ethToPay);
        }
    }
```

## IOU Examples

### 👍Ture Positive
Address: 0xf6a1e68e9ff6589b19981c4716f32b38ec8cc3ac
```Javascript
    Auction[] public auctions;

    function getAuctions(address bidder) public view returns (
        uint40[5] _timeEnd,
        uint40[5] _lastBidTime,
        uint256[5] _highestBid,
        address[5] _highestBidder,
        uint16[5] _auctionIndex,
        uint256 _pendingReturn)
    {
        _pendingReturn = pendingReturns[bidder];

        uint16 j = 0;
        for (uint16 i = 0; i < auctions.length; i++) // TP
        {
            if (!isEnded(i))
            {
                _timeEnd[j] = auctions[i].timeEnd;
                _lastBidTime[j] = auctions[i].lastBidTime;
                _highestBid[j] = auctions[i].highestBid;
                _highestBidder[j] = auctions[i].highestBidder;
                _auctionIndex[j] = i;
                j++;
                if (j >= 5)
                {
                    break;
                }
            }
        }
    }
```

### 👎 False Positive
Address: 0x48198311ac8d81929c0e67e00dfc789b706178e9  ~R2
```Javascript
    uint8   constant public SIZE = 10; // size of the lottery
    uint256 counter;

    function refundAll() onlyOwner {
        // We send refunds after the game has gone 1 month without conclusion

        for (uint8 i = 0; i < counter%SIZE; i++) { // not counter.size, but modulus of SIZE // FP
            participants[gameNumber][i].transfer(PRICE);
            Refunded(msg.sender, PRICE);
        }

        // reduce the counter
        counter -= counter%SIZE;
    }
```