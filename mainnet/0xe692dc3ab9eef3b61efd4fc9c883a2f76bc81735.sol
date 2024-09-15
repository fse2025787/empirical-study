// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-07-22
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File contracts/libs/TransferHelper.sol

// 

pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value,gas:5000}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/interfaces/INestVault.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;


interface INestVault {

    
    
    
    function approve(address target, uint limit) external;

    
    
    
    function transferTo(address to, uint amount) external;
}


// File contracts/interfaces/INestProbability.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;


interface INestProbability {

    // Roll dice44 information view
    struct DiceView44 {
        uint index;
        address owner;
        uint32 n;
        uint32 m;
        uint32 openBlock;
        uint gained;
    }

    
    
    /// (excluding the record corresponding to start)
    
    
    
    
    function find44(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (DiceView44[] memory diceArray44);

    
    
    
    
    
    function list44(
        uint offset, 
        uint count, 
        uint order
    ) external view returns (DiceView44[] memory diceArray44);

    
    
    function getDiceCount44() external view returns (uint);

    
    
    
    function roll44(uint n, uint m) external;

    
    
    function claim44(uint index) external;

    
    
    function batchClaim44(uint[] calldata indices) external;
}


// File contracts/interfaces/INestMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;


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


// File contracts/interfaces/INestGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

interface INestGovernance is INestMapping {

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    
    
    
    /// to pass the check
    
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/NestBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

contract NestBase {

    
    address public _governance;

    
    
    function initialize(address governance) public virtual {
        require(_governance == address(0), "NEST:!initialize");
        _governance = governance;
    }

    
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || INestGovernance(governance).checkGovernance(msg.sender, 0), "NEST:!gov");
        _governance = newGovernance;
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


// File contracts/custom/NestFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

contract NestFrequentlyUsed is NestBase {

    // ETH:
    // Address of nest token
    address constant NEST_TOKEN_ADDRESS = 0x04abEdA201850aC0124161F037Efd70c74ddC74C;
    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0xE544cF993C7d477C7ef8E91D28aCA250D135aa03;
    // Address of nest vault
    address constant NEST_VAULT_ADDRESS = 0x12858F7f24AA830EeAdab2437480277E92B0723a;

    // // BSC:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS = 0x65e7506244CDdeFc56cD43dC711470F8B0C43beE;

    // // Polygon:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // // KCC:
    // // Address of nest token
    // address constant NEST_TOKEN_ADDRESS = 0x98f8669F6481EbB341B522fCD3663f79A3d1A6A7;
    // // Address of NestOpenPrice contract
    // address constant NEST_OPEN_PRICE = 0x7DBe94A4D6530F411A1E7337c7eb84185c4396e6;
    // // Address of nest vault
    // address constant NEST_VAULT_ADDRESS;

    // USDT base
    uint constant USDT_BASE = 1 ether;
}


// File contracts/NestProbability.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

contract NestProbability is NestFrequentlyUsed, INestProbability {

    // Roll dice44 structure
    struct Dice44 {
        address owner;
        uint32 n;
        uint32 m;
        uint32 openBlock;
    }

    // Roll cost rate
    uint constant ROLL_COST_RATE = 1.01 ether;

    // The span from current block to hash block
    uint constant OPEN_BLOCK_SPAN44 = 1;

    // 4 decimals for M
    uint constant M_BASE44 = 10000;

    // 4 decimals for N
    uint constant N_BASE44 = 10000;
    
    // MAX M. [1.0000, 100.0000]
    uint constant MAX_M44 = 100 * M_BASE44;
    
    // MAX N, [0.0001, 1000.0000]
    uint constant MAX_N44 = 1000 * N_BASE44;

    // Roll dice44 array
    Dice44[] _dices44;

    
    
    /// (excluding the record corresponding to start)
    
    
    
    
    function find44(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view override returns (DiceView44[] memory diceArray44) {
        diceArray44 = new DiceView44[](count);
        // Calculate search region
        Dice44[] storage dices44 = _dices44;
        // Loop from start to end
        uint end = 0;
        // start is 0 means Loop from the last item
        if (start == 0) {
            start = dices44.length;
        }
        // start > maxFindCount, so end is not 0
        if (start > maxFindCount) {
            end = start - maxFindCount;
        }
        
        // Loop lookup to write qualified records to the buffer
        for (uint index = 0; index < count && start > end;) {
            Dice44 memory dice44 = dices44[--start];
            if (dice44.owner == owner) {
                diceArray44[index++] = _toDiceView44(dice44, start);
            }
        }
    }

    
    
    
    
    
    function list44(
        uint offset, 
        uint count, 
        uint order
    ) external view override returns (DiceView44[] memory diceArray44) {

        // Load dices44
        Dice44[] storage dices44 = _dices44;
        // Create result array
        diceArray44 = new DiceView44[](count);
        uint length = dices44.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                Dice44 memory gi = dices44[--index];
                diceArray44[i++] = _toDiceView44(gi, index);
            }
        } 
        // Positive order
        else {
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                diceArray44[i++] = _toDiceView44(dices44[index], index);
                ++index;
            }
        }
    }

    
    
    function getDiceCount44() external view override returns (uint) {
        return _dices44.length;
    }

    
    
    
    function roll44(uint n, uint m) external override {
        require(n > 0 && n <= MAX_N44  && m >= M_BASE44 && m <= MAX_M44, "NP:n or m not valid");

        //_burn(msg.sender, n * 1 ether / N_BASE44);
        TransferHelper.safeTransferFrom(
            NEST_TOKEN_ADDRESS, 
            msg.sender, 
            NEST_VAULT_ADDRESS,
            n * ROLL_COST_RATE / N_BASE44
        );

        _dices44.push(Dice44(msg.sender, uint32(n), uint32(m), uint32(block.number)));
    }

    
    
    function claim44(uint index) external override {
        Dice44 memory dice44 = _dices44[index];
        uint gain = _gained44(dice44, index);
        if (gain > 0) {
            //DCU(DCU_TOKEN_ADDRESS).mint(dice44.owner, gain);
            INestVault(NEST_VAULT_ADDRESS).transferTo(dice44.owner, gain);
        }

        _dices44[index].n = uint32(0);
    }

    
    
    function batchClaim44(uint[] calldata indices) external override {
        
        address owner = address(0);
        uint gain = 0;

        for (uint i = indices.length; i > 0;) {
            uint index = indices[--i];
            Dice44 memory dice44 = _dices44[index];
            if (owner == address(0)) {
                owner = dice44.owner;
            } else {
                require(owner == dice44.owner, "NP:different owner");
            }
            gain += _gained44(dice44, index);
            _dices44[index].n = uint32(0);
        }

        if (owner > address(0)) {
            //DCU(DCU_TOKEN_ADDRESS).mint(owner, gain);
            INestVault(NEST_VAULT_ADDRESS).transferTo(owner, gain);
        }
    }

    // Calculate gained number of NEST
    function _gained44(Dice44 memory dice44, uint index) private view returns (uint gain) {
        uint hashBlock = uint(dice44.openBlock) + OPEN_BLOCK_SPAN44;
        require(block.number > hashBlock, "NP:!hashBlock");

        // Ethereum miners may affect the blockhash value, thus changing the random results and submitting only blocks 
        // of blockhash that are beneficial to them. Considering this, by limiting the number and magnification of each
        // lottery, users' profits after winning the lottery are limited to a maximum value, so it is considered that
        // the rewards obtained by Ethereum miners after cheating are not enough to cover their costs
        uint hashValue = uint(blockhash(hashBlock));
        if (hashValue > 0) {
            hashValue = uint(keccak256(abi.encodePacked(hashValue, index)));
            if (hashValue % uint(dice44.m) < M_BASE44) {
                gain = uint(dice44.n) * uint(dice44.m) * 1 ether / M_BASE44 / N_BASE44;
            }
        }
    }

    // Convert Dice44 to DiceView44
    function _toDiceView44(Dice44 memory dice44, uint index) private view returns (DiceView44 memory div) {
        div = DiceView44(
            index,
            dice44.owner,
            dice44.n,
            dice44.m,
            dice44.openBlock,
            block.number > uint(dice44.openBlock) + OPEN_BLOCK_SPAN44 ? _gained44(dice44, index) : 0
        );
    }
}