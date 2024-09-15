// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-04-27
*/

// File: contracts\lib\TransferHelper.sol

// 

pragma solidity ^0.8.3;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// File: contracts\interface\INestLedger.sol


interface INestLedger {

    
    
    
    event ApplicationChanged(address addr, uint flag);
    
    
    struct Config {
        
        // nest reward scale(10000 based). 2000
        uint16 nestRewardScale;

        // // ntoken reward scale(10000 based). 8000
        // uint16 ntokenRewardScale;
    }
    
    
    
    function setConfig(Config memory config) external;

    
    
    function getConfig() external view returns (Config memory);

    
    
    
    function setApplication(address addr, uint flag) external;

    
    
    
    function checkApplication(address addr) external view returns (uint);

    
    
    function carveETHReward(address ntokenAddress) external payable;

    
    
    function addETHReward(address ntokenAddress) external payable;

    
    
    function totalETHRewards(address ntokenAddress) external view returns (uint);

    
    
    
    
    
    function pay(address ntokenAddress, address tokenAddress, address to, uint value) external;

    
    
    
    
    
    function settle(address ntokenAddress, address tokenAddress, address to, uint value) external payable;
}

// File: contracts\interface\INestMapping.sol


interface INestMapping {

    
    
    
    
    
    
    
    
    
    
    
    function setBuiltinAddress(
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    ) external;

    
    
    
    
    
    
    
    
    
    
    
    function getBuiltinAddress() external view returns (
        address nestTokenAddress,
        address nestNodeAddress,
        address nestLedgerAddress,
        address nestMiningAddress,
        address ntokenMiningAddress,
        address nestPriceFacadeAddress,
        address nestVoteAddress,
        address nestQueryAddress,
        address nnIncomeAddress,
        address nTokenControllerAddress
    );

    
    
    function getNestTokenAddress() external view returns (address);

    
    
    function getNestNodeAddress() external view returns (address);

    
    
    function getNestLedgerAddress() external view returns (address);

    
    
    function getNestMiningAddress() external view returns (address);

    
    
    function getNTokenMiningAddress() external view returns (address);

    
    
    function getNestPriceFacadeAddress() external view returns (address);

    
    
    function getNestVoteAddress() external view returns (address);

    
    
    function getNestQueryAddress() external view returns (address);

    
    
    function getNnIncomeAddress() external view returns (address);

    
    
    function getNTokenControllerAddress() external view returns (address);

    
    
    
    function registerAddress(string memory key, address addr) external;

    
    
    
    function checkAddress(string memory key) external view returns (address);
}

// File: contracts\interface\INestGovernance.sol


interface INestGovernance is INestMapping {

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    
    
    
    
    function checkGovernance(address addr, uint flag) external view returns (bool);
}

// File: contracts\NestBase.sol


contract NestBase {

    // Address of nest token contract
    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;

    // Genesis block number of nest
    // NEST token contract is created at block height 6913517. However, because the mining algorithm of nest1.0
    // is different from that at present, a new mining algorithm is adopted from nest2.0. The new algorithm
    // includes the attenuation logic according to the block. Therefore, it is necessary to trace the block
    // where the nest begins to decay. According to the circulation when nest2.0 is online, the new mining
    // algorithm is used to deduce and convert the nest, and the new algorithm is used to mine the nest2.0
    // on-line flow, the actual block is 5120000
    uint constant NEST_GENESIS_BLOCK = 5120000;

    
    
    function initialize(address nestGovernanceAddress) virtual public {
        require(_governance == address(0), 'NEST:!initialize');
        _governance = nestGovernanceAddress;
    }

    
    address public _governance;

    
    ///      super.update(nestGovernanceAddress) when overriding, and override method without onlyGovernance
    
    function update(address nestGovernanceAddress) virtual public {

        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = nestGovernanceAddress;
    }

    
    
    
    function migrate(address tokenAddress, uint value) external onlyGovernance {

        address to = INestGovernance(_governance).getNestLedgerAddress();
        if (tokenAddress == address(0)) {
            INestLedger(to).addETHReward { value: value } (address(0));
        } else {
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(INestGovernance(_governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _;
    }

    modifier noContract() {
        require(msg.sender == tx.origin, "NEST:!contract");
        _;
    }
}

// File: contracts\NestLedger.sol


contract NestLedger is NestBase, INestLedger {

    // 
    // constructor(address nestTokenAddress) {
    //     NEST_TOKEN_ADDRESS = nestTokenAddress;
    // }

    
    struct UINT {
        uint value;
    }

    // Configuration
    Config _config;

    // nest ledger
    uint _nestLedger;

    // ntoken ledger
    mapping(address=>UINT) _ntokenLedger;

    // DAO applications
    mapping(address=>uint) _applications;

    
    
    function setConfig(Config memory config) override external onlyGovernance {
        require(uint(config.nestRewardScale) <= 10000, "NestLedger:!value");
        _config = config;
    }

    
    
    function getConfig() override external view returns (Config memory) {
        return _config;
    }

    
    
    
    function setApplication(address addr, uint flag) override external onlyGovernance {
        _applications[addr] = flag;
        emit ApplicationChanged(addr, flag);
    }

    
    
    
    function checkApplication(address addr) override external view returns (uint) {
        return _applications[addr];
    }

    
    
    function carveETHReward(address ntokenAddress) override external payable {

        // nest not carve
        if (ntokenAddress == NEST_TOKEN_ADDRESS) {
            _nestLedger += msg.value;
        }
        // ntoken need carve
        else {

            Config memory config = _config;
            UINT storage balance = _ntokenLedger[ntokenAddress];

            // Calculate nest reward
            uint nestReward = msg.value * uint(config.nestRewardScale) / 10000;
            // The part of ntoken is msg.value - nestReward
            balance.value += msg.value - nestReward;
            // nest reward
            _nestLedger += nestReward;
        }
    }

    
    
    function addETHReward(address ntokenAddress) override external payable {

        // Ledger for nest is independent
        if (ntokenAddress == NEST_TOKEN_ADDRESS) {
            _nestLedger += msg.value;
        }
        // Ledger for ntoken is in a mapping
        else {
            UINT storage balance = _ntokenLedger[ntokenAddress];
            balance.value += msg.value;
        }
    }

    
    
    function totalETHRewards(address ntokenAddress) override external view returns (uint) {

        if (ntokenAddress == NEST_TOKEN_ADDRESS) {
            return _nestLedger;
        }
        return _ntokenLedger[ntokenAddress].value;
    }

    
    
    
    
    
    function pay(address ntokenAddress, address tokenAddress, address to, uint value) override external {

        require(_applications[msg.sender] == 1, "NestLedger:!app");

        // Pay eth from ledger
        if (tokenAddress == address(0)) {
            // nest ledger
            if (ntokenAddress == NEST_TOKEN_ADDRESS) {
                _nestLedger -= value;
            }
            // ntoken ledger
            else {
                UINT storage balance = _ntokenLedger[ntokenAddress];
                balance.value -= value;
            }
            // pay
            payable(to).transfer(value);
        }
        // Pay token
        else {
            // pay
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    }

    
    
    
    
    
    function settle(address ntokenAddress, address tokenAddress, address to, uint value) override external payable {

        require(_applications[msg.sender] == 1, "NestLedger:!app");

        // Pay eth from ledger
        if (tokenAddress == address(0)) {
            // nest ledger
            if (ntokenAddress == NEST_TOKEN_ADDRESS) {
                // If msg.value is not 0, add to ledger
                _nestLedger = _nestLedger + msg.value - value;
            }
            // ntoken ledger
            else {
                // If msg.value is not 0, add to ledger
                UINT storage balance = _ntokenLedger[ntokenAddress];
                balance.value = balance.value + msg.value - value;
            }
            // pay
            payable(to).transfer(value);
        }
        // Pay token
        else {
            // If msg.value is not 0, add to ledger
            if (msg.value > 0) {
                if (ntokenAddress == NEST_TOKEN_ADDRESS) {
                    _nestLedger += msg.value;
                } else {
                    UINT storage balance = _ntokenLedger[ntokenAddress];
                    balance.value += msg.value;
                }
            }
            // pay
            TransferHelper.safeTransfer(tokenAddress, to, value);
        }
    } 
}