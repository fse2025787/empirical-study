# RQ2 Experiment

## Vulnerability Number Count

Workdir: `./number/`

`./number/contract_level` counts the number of vulnerabilities on contract level, suggesting that if a tool reported multiple vulnerabilities of a certain type in a contract, these vulnerabilities are considered to be only one.

## Manual Confirmation of True Positive Results

Workdir: `./manual/`

`./number/details_of_tool_results` presents the vulnerable contracts and the corresponding line number reported by tools.

`./number/labels` presents the results of manual confirmation of True Positive Results.

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