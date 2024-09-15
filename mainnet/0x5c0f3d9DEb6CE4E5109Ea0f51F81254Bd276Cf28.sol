// SPDX-License-Identifier: MIT
pragma abicoder v2;

/**
 *Submitted for verification at Etherscan.io on 2021-09-07
*/

// 
pragma solidity 0.8.7;



interface Token {

    
    function totalSupply() external view returns (uint256 supply);

    
    
    function balanceOf(address _owner) external view returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) external returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) external returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Optionally implemented function to show the number of decimals for the token
    function decimals() external view returns (uint8 decimals);
}



/// contracts.
contract Utils {

    uint256 constant MAX_SAFE_UINT256 = 2**256 - 1;

    
    
    /// deployed or not
    
    function contractExists(address contract_address) public view returns (bool) {
        uint size;

        assembly { // solium-disable-line security/no-inline-assembly
            size := extcodesize(contract_address)
        }

        return size > 0;
    }

    string public constant signature_prefix = "\x19Ethereum Signed Message:\n";

    function min(uint256 a, uint256 b) public pure returns (uint256)
    {
        return a > b ? b : a;
    }

    function max(uint256 a, uint256 b) public pure returns (uint256)
    {
        return a > b ? a : b;
    }

    
    
    
    
    /// subtrahend for which no underflow occurs
    function failsafe_subtract(uint256 a, uint256 b)
        public
        pure
        returns (uint256, uint256)
    {
        unchecked {
            return a > b ? (a - b, b) : (0, a);
        }
    }

    
    
    
    
    /// uint256 value
    function failsafe_addition(uint256 a, uint256 b)
        public
        pure
        returns (uint256)
    {
        unchecked {
            uint256 sum = a + b;
            return sum >= a ? sum : MAX_SAFE_UINT256;
        }
    }
}

contract UserDeposit is Utils {
    uint constant public withdraw_delay = 100;  // time before withdraw is allowed in blocks

    // Token to be used for the deposit
    Token public token;

    // Trusted contracts (can execute `transfer`)
    address public msc_address;
    address public one_to_n_address;

    // Total amount of tokens that have been deposited. This is monotonous and
    // doing a transfer or withdrawing tokens will not decrease total_deposit!
    mapping(address => uint256) public total_deposit;
    // Current user's balance, ignoring planned withdraws
    mapping(address => uint256) public balances;
    mapping(address => WithdrawPlan) public withdraw_plans;

    // The sum of all balances
    uint256 public whole_balance = 0;
    // Deposit limit for this whole contract
    uint256 public whole_balance_limit;

    /*
     *  Structs
     */
    struct WithdrawPlan {
        uint256 amount;
        uint256 withdraw_block;  // earliest block at which withdraw is allowed
    }

    /*
     *  Events
     */

    event BalanceReduced(address indexed owner, uint newBalance);
    event WithdrawPlanned(address indexed withdrawer, uint plannedBalance);

    /*
     *  Modifiers
     */

    modifier canTransfer() {
        require(msg.sender == msc_address || msg.sender == one_to_n_address, "unknown caller");
        _;
    }

    /*
     *  Constructor
     */

    
    
    constructor(address _token_address, uint256 _whole_balance_limit)
    {
        // check token contract
        require(_token_address != address(0x0), "token at address zero");
        require(contractExists(_token_address), "token has no code");
        token = Token(_token_address);
        require(token.totalSupply() > 0, "token has no total supply"); // Check if the contract is indeed a token contract
        // check and set the whole balance limit
        require(_whole_balance_limit > 0, "whole balance limit is zero");
        whole_balance_limit = _whole_balance_limit;
    }

    
    /// constructor to avoid cyclic dependencies.
    
    
    function init(address _msc_address, address _one_to_n_address)
        external
    {
        // prevent changes of trusted contracts after initialization
        require(msc_address == address(0x0) && one_to_n_address == address(0x0), "already initialized");

        // check monitoring service contract
        require(_msc_address != address(0x0), "MS contract at address zero");
        require(contractExists(_msc_address), "MS contract has no code");
        msc_address = _msc_address;

        // check one to n contract
        require(_one_to_n_address != address(0x0), "OneToN at address zero");
        require(contractExists(_one_to_n_address), "OneToN has no code");
        one_to_n_address = _one_to_n_address;
    }

    
    /// `new_total_deposit - total_deposit[beneficiary]`. This makes the
    /// function behavior predictable and idempotent. Can be called several
    /// times and on behalf of other accounts.
    
    
    /// deposited by the user by calling this function.
    function deposit(address beneficiary, uint256 new_total_deposit)
        external
    {
        require(new_total_deposit > total_deposit[beneficiary], "deposit not increasing");

        // Calculate the actual amount of tokens that will be transferred
        uint256 added_deposit = new_total_deposit - total_deposit[beneficiary];

        balances[beneficiary] += added_deposit;
        total_deposit[beneficiary] += added_deposit;

        // Update whole_balance, but take care against overflows.
        require(whole_balance + added_deposit >= whole_balance, "overflowing deposit");
        whole_balance += added_deposit;

        // Decline deposit if the whole balance is bigger than the limit.
        require(whole_balance <= whole_balance_limit, "too much deposit");

        // Actual transfer.
        require(token.transferFrom(msg.sender, address(this), added_deposit), "tokens didn't transfer");
    }

    
    /// Sender and receiver must be different or the transaction will fail.
    
    
    
    
    function transfer(
        address sender,
        address receiver,
        uint256 amount
    )
        external
        canTransfer()
        returns (bool success)
    {
        require(sender != receiver, "sender == receiver");
        if (balances[sender] >= amount && amount > 0) {
            balances[sender] -= amount;
            // This can overflow in theory, but this is checked by solidity since 0.8.0.
            // In practice, with any reasonable token, where the supply is limited to uint256,
            // this can never overflow.
            // See https://github.com/raiden-network/raiden-contracts/pull/448#discussion_r250609178
            balances[receiver] += amount;
            emit BalanceReduced(sender, balances[sender]);
            return true;
        } else {
            return false;
        }
    }

    
    /// Sets the planned withdraw amount and resets the withdraw_block.
    /// There is only one planned withdrawal at a time, the old one gets overwritten.
    
    function planWithdraw(uint256 amount)
        external
    {
        require(amount > 0, "withdrawing zero");
        require(balances[msg.sender] >= amount, "withdrawing too much");

        withdraw_plans[msg.sender] = WithdrawPlan({
            amount: amount,
            withdraw_block: block.number + withdraw_delay
        });
        emit WithdrawPlanned(msg.sender, balances[msg.sender] - amount);
    }

    
    /// Will only work after the withdraw_delay has expired.
    /// An amount lower or equal to the planned amount may be withdrawn.
    /// Removes the withdraw plan even if not the full amount has been
    /// withdrawn.
    
    
    function withdrawToBeneficiary(uint256 amount, address beneficiary)
        external
    {
        withdrawHelper(amount, msg.sender, beneficiary);
    }

    
    /// Will only work after the withdraw_delay has expired.
    /// An amount lower or equal to the planned amount may be withdrawn.
    /// Removes the withdraw plan even if not the full amount has been
    /// withdrawn.
    
    function withdraw(uint256 amount)
        external
    {
        withdrawHelper(amount, msg.sender, msg.sender);
    }

    
    
    
    function effectiveBalance(address owner)
        external
        view
        returns (uint256 remaining_balance)
    {
        WithdrawPlan storage withdraw_plan = withdraw_plans[owner];
        if (withdraw_plan.amount > balances[owner]) {
            return 0;
        }
        return balances[owner] - withdraw_plan.amount;
    }

    function withdrawHelper(uint256 amount, address deposit_holder, address beneficiary)
        internal
    {
        require(beneficiary != address(0x0), "beneficiary is zero");
        WithdrawPlan storage withdraw_plan = withdraw_plans[deposit_holder];
        require(amount <= withdraw_plan.amount, "withdrawing more than planned");
        require(withdraw_plan.withdraw_block <= block.number, "withdrawing too early");
        uint256 withdrawable = min(amount, balances[deposit_holder]);
        balances[deposit_holder] -= withdrawable;

        // Update whole_balance, but take care against underflows.
        require(whole_balance - withdrawable <= whole_balance, "underflow in whole_balance");
        whole_balance -= withdrawable;

        emit BalanceReduced(deposit_holder, balances[deposit_holder]);
        delete withdraw_plans[deposit_holder];

        require(token.transfer(beneficiary, withdrawable), "tokens didn't transfer");
    }
}


// MIT License

// Copyright (c) 2018

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.