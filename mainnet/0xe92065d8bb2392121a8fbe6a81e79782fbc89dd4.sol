
pragma solidity ^0.4.21;

// File: contracts/auth/AuthorizedList.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;

contract AuthorizedList {

    bytes32 constant APHRODITE = keccak256("Goddess of Love!");
    bytes32 constant CUPID = keccak256("Aphrodite's Little Helper.");
    bytes32 constant BULKTRANSFER = keccak256("Bulk Transfer User.");
    mapping (address => mapping(bytes32 => bool)) internal authorized;
    mapping (bytes32 => bool) internal contractPermissions;

}

// File: contracts/auth/Authorized.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;


contract Authorized is AuthorizedList {

    function Authorized() public {
        /// Set the initial permission for msg.sender (contract creator), it can then add permissions for others
        authorized[msg.sender][APHRODITE] = true;
    }

    /// Check if _address is authorized to access functionality with _authorization level
    modifier ifAuthorized(address _address, bytes32 _authorization) {
        require(authorized[_address][_authorization] || authorized[_address][APHRODITE]);
        _;
    }

    
    function isAuthorized(address _address, bytes32 _authorization) public view returns (bool) {
        return authorized[_address][_authorization];
    }

    
    
    
    function toggleAuthorization(address _address, bytes32 _authorization) public ifAuthorized(msg.sender, APHRODITE) {

        /// Prevent inadvertent self locking out, cannot change own authority
        require(_address != msg.sender);

        /// No need for lower level authorization to linger
        if (_authorization == APHRODITE && !authorized[_address][APHRODITE]) {
            authorized[_address][CUPID] = false;
        }

        authorized[_address][_authorization] = !authorized[_address][_authorization];
    }
}

// File: contracts/managed/Pausable.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;


contract Pausable is AuthorizedList, Authorized {

    event Pause();
    event Unpause();


    
    bool public paused = false;

    /// Make sure access control is initialized
    function Pausable() public AuthorizedList() Authorized() { }


    
    modifier whenNotPaused {
        require(!paused);
        _;
    }


    
    modifier whenPaused {
        require(paused);
        _;
    }


    
    /// Multiple addresses may be authorized to call this method
    function pause() public whenNotPaused ifAuthorized(msg.sender, CUPID) returns (bool) {
        emit Pause();
        paused = true;

        return true;
    }


    
    /// Multiple addresses may be authorized to call this method
    function unpause() public whenPaused ifAuthorized(msg.sender, CUPID) returns (bool) {
        emit Unpause();
        paused = false;
    
        return true;
    }
}

// File: contracts/math/SafeMath.sol

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    /* Not needed
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

// File: contracts/token/IERC20Basic.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;

contract IERC20Basic {

    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

}

// File: contracts/token/IERC20.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;


contract IERC20 is IERC20Basic {

    function allowance(address _tokenholder, address _tokenspender) view public returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _tokenspender, uint256 _value) public returns (bool);
    event Approval(address indexed _tokenholder, address indexed _tokenspender, uint256 _value);

}

// File: contracts/token/RecoverCurrency.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;




contract RecoverCurrency is AuthorizedList, Authorized {

    event EtherRecovered(address indexed _to, uint256 _value);

    function recoverEther() external ifAuthorized(msg.sender, APHRODITE) {
        msg.sender.transfer(address(this).balance);
        emit EtherRecovered(msg.sender, address(this).balance);
    }

    
    
    function recoverToken(address _address) external ifAuthorized(msg.sender, APHRODITE) {
        require(_address != address(0));
        IERC20Basic token = IERC20Basic(_address);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }
}

// File: contracts/managed/Freezable.sol

/*
 * Created by Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;


/**
 * @title Freezable
 * @dev allows authorized accounts to add/remove other accounts to the list of fozen accounts.
 * Accounts in the list cannot transfer and approve and their balances and allowances cannot be retrieved.
 */
contract Freezable is AuthorizedList, Authorized {

    event Frozen(address indexed _account);
    event Unfrozen(address indexed _account);
    
    mapping (address => bool) public frozenAccounts;

    /// Make sure access control is initialized
    function Freezable() public AuthorizedList() Authorized() { }

    /**
    * @dev Throws if called by any account that's frozen.
    */
    modifier notFrozen {
        require(!frozenAccounts[msg.sender]);
        _;
    }

    /**
    * @dev check if an account is frozen
    * @param account address to check
    * @return true iff the address is in the list of frozen accounts and hasn't been unfrozen
    */
    function isFrozen(address account) public view returns (bool) {
        return frozenAccounts[account];
    }

    /**
    * @dev add an address to the list of frozen accounts
    * @param account address to freeze
    * @return true if the address was added to the list of frozen accounts, false if the address was already in the list 
    */
    function freezeAccount(address account) public ifAuthorized(msg.sender, APHRODITE) returns (bool success) {
        if (!frozenAccounts[account]) {
            frozenAccounts[account] = true;
            emit Frozen(account);
            success = true; 
        }
    }

    /**
    * @dev remove an address from the list of frozen accounts
    * @param account address to unfreeze
    * @return true if the address was removed from the list of frozen accounts, 
    * false if the address wasn't in the list in the first place 
    */
    function unfreezeAccount(address account) public ifAuthorized(msg.sender, APHRODITE) returns (bool success) {
        if (frozenAccounts[account]) {
            frozenAccounts[account] = false;
            emit Unfrozen(account);
            success = true;
        }
    }
}

// File: contracts/storage/AllowancesLedger.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, 
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE 
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE, 
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;

contract AllowancesLedger {

    mapping (address => mapping (address => uint256)) public allowances;

}

// File: contracts/storage/TokenLedger.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;


contract TokenLedger is AuthorizedList, Authorized {

    mapping(address => uint256) public balances;
    uint256 public totalsupply;

    struct SeenAddressRecord {
        bool seen;
        uint256 accountArrayIndex;
    }

    // Iterable accounts
    address[] internal accounts;
    mapping(address => SeenAddressRecord) internal seenBefore;

    
    
    function numberAccounts() public view ifAuthorized(msg.sender, APHRODITE) returns (uint256) {
        return accounts.length;
    }

    
    function returnAccounts() public view ifAuthorized(msg.sender, APHRODITE) returns (address[] holders) {
        return accounts;
    }

    function balanceOf(uint256 _id) public view ifAuthorized(msg.sender, CUPID) returns (uint256 balance) {
        require (_id < accounts.length);
        return balances[accounts[_id]];
    }
}

// File: contracts/storage/TokenSettings.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;


contract TokenSettings is AuthorizedList, Authorized {

    /// These strings should be set temporarily for testing on Rinkeby/Ropsten/Kovan to somethin else
    /// to avoid people squatting on names
    /// Change back to "intimate" and "ITM" for mainnet deployment

    string public name = "intimate";
    string public symbol = "ITM";

    uint256 public INITIAL_SUPPLY = 100000000 * 10**18;  // 100 million of subdivisible tokens
    uint8 public constant decimals = 18;


    
    
    function setName(string _name) public ifAuthorized(msg.sender, APHRODITE) {
        name = _name;
    }

    
    
    function setSymbol(string _symbol) public ifAuthorized(msg.sender, APHRODITE) {
        symbol = _symbol;
    }
}

// File: contracts/storage/BasicTokenStorage.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;





/// Collect all the state variables for the token's functions into a single contract
contract BasicTokenStorage is AuthorizedList, Authorized, TokenSettings, AllowancesLedger, TokenLedger {

    
    function BasicTokenStorage() public Authorized() TokenSettings() AllowancesLedger() TokenLedger() { }

    
    
    function trackAddresses(address _tokenholder) internal {
        if (!seenBefore[_tokenholder].seen) {
            seenBefore[_tokenholder].seen = true;
            accounts.push(_tokenholder);
            seenBefore[_tokenholder].accountArrayIndex = accounts.length - 1;
        }
    }

    
    
    function removeSeenAddress(address _tokenholder) internal {
        uint index = seenBefore[_tokenholder].accountArrayIndex;
        require(index < accounts.length);

        if (index != accounts.length - 1) {
            accounts[index] = accounts[accounts.length - 1];
        } 
        accounts.length--;
        delete seenBefore[_tokenholder];
    }
}

// File: contracts/token/BasicToken.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;







contract BasicToken is IERC20Basic, BasicTokenStorage, Pausable, Freezable {

    using SafeMath for uint256;

    event Transfer(address indexed _tokenholder, address indexed _tokenrecipient, uint256 _value);
    event BulkTransfer(address indexed _tokenholder, uint256 _howmany);

    
    function totalSupply() public view whenNotPaused returns (uint256) {
        return totalsupply;
    }

    
    
    
    function transfer(address _to, uint256 _value) public whenNotPaused notFrozen returns (bool) {

        /// No transfers to 0x0 address, use burn instead, if implemented
        require(_to != address(0));

        /// No useless operations
        require(msg.sender != _to);

        /// This will revert if not enough funds
        balances[msg.sender] = balances[msg.sender].sub(_value);

        if (balances[msg.sender] == 0) {
            removeSeenAddress(msg.sender);
        }

        /// _to might be a completely new address, so check and store if so
        trackAddresses(_to);

        /// This will revert on overflow
        balances[_to] = balances[_to].add(_value);

        /// Emit the Transfer event
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    
    
    
    function bulkTransfer(address[] _tos, uint256[] _values) public whenNotPaused notFrozen ifAuthorized(msg.sender, BULKTRANSFER) returns (bool) {

        require (_tos.length == _values.length);

        uint256 sourceBalance = balances[msg.sender];

        /// Temporarily set balance to 0 to mitigate the possibility of re-entrancy attacks
        balances[msg.sender] = 0;

        for (uint256 i = 0; i < _tos.length; i++) {
            uint256 currentValue = _values[i];
            address _to = _tos[i];
            require(_to != address(0));
            require(currentValue <= sourceBalance);
            require(msg.sender != _to);

            sourceBalance = sourceBalance.sub(currentValue);
            balances[_to] = balances[_to].add(currentValue);

            trackAddresses(_to);

            emit Transfer(msg.sender, _tos[i], currentValue);
        }

        /// Set to the remaining balance
        balances[msg.sender] = sourceBalance;

        emit BulkTransfer(msg.sender, _tos.length);

        if (balances[msg.sender] == 0) {
            removeSeenAddress(msg.sender);
        }

        return true;
    }


    
    
    
    function balanceOf(address _tokenholder) public view whenNotPaused returns (uint256 balance) {
        require(!isFrozen(_tokenholder));
        return balances[_tokenholder];
    }
}

// File: contracts/token/StandardToken.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;








contract StandardToken is IERC20Basic, BasicToken, IERC20 {

    using SafeMath for uint256;

    event Approval(address indexed _tokenholder, address indexed _tokenspender, uint256 _value);

    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused notFrozen returns (bool) {

        // Don't send tokens to 0x0 address, use burn function that updates totalSupply
        // and don't waste gas sending tokens to yourself
        require(_to != address(0) && _from != _to);

        require(!isFrozen(_from) && !isFrozen(_to));

        /// This will revert if _value is larger than the allowance
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);

        balances[_from] = balances[_from].sub(_value);

        /// _to might be a completely new address, so check and store if so
        trackAddresses(_to);

        balances[_to] = balances[_to].add(_value);

        /// Emit the Transfer event
        emit Transfer(_from, _to, _value);

        return true;
    }


    
    
    
    function approve(address _tokenspender, uint256 _value) public whenNotPaused notFrozen returns (bool) {

        require(_tokenspender != address(0) && msg.sender != _tokenspender);

        require(!isFrozen(_tokenspender));

        /// To mitigate reentrancy race condition, set allowance for _tokenspender to 0
        /// first and then set the new value
        /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowances[msg.sender][_tokenspender] == 0));

        /// Allow _tokenspender to transfer up to _value in tokens from msg.sender
        allowances[msg.sender][_tokenspender] = _value;

        /// Emit the Approval event
        emit Approval(msg.sender, _tokenspender, _value);

        return true;
    }


    
    
    
    
    function allowance(address _tokenholder, address _tokenspender) public view whenNotPaused returns (uint256) {
        require(!isFrozen(_tokenholder) && !isFrozen(_tokenspender));
        return allowances[_tokenholder][_tokenspender];
    }
}

// File: contracts/sales/IntimateShoppe.sol

/*
 * Created by: alexo (Big Deeper Advisors, Inc)
 * For: Input Strategic Partners (ISP) and Intimate.io
 *
 * Derived from some public sources and substantially extended/adapted for intimate's use.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE
 * SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

pragma solidity ^0.4.21;









contract IntimateShoppe is Pausable, RecoverCurrency {

    using SafeMath for uint256;

    /// List of contributors, i.e. msg.sender(s) who has sent in Ether
    address[] internal contributors;

    /// List of contributions for each contributor
    mapping (address => uint256[]) internal contributions;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    
    
    
    
    
    event ITMTokenPurchase(address indexed _seller_wallet_address, address indexed _buyer_address, uint256 _value, uint256 _amount);

    
    event SetPeriod(uint256 _startTime, uint256 _endTime);


    /// The ITM token object
    StandardToken public token;

    /// address of the ITM token
    address public token_address;

    /// start and end timestamps in between which investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    /// address where funds are collected, it could a simple address or multi-sig wallet contract
    address public wallet_address;

    /// how many token units a buyer gets per wei
    uint256 public rate = 600;

    /// upper limit for tokens to be sold in this public offering
    /// NOTE: Since decimals are set at 1e18, if one sets a limit of one(1) ITM, this number should be
    /// 1 * 1e18
    uint256 public capTokens;

    /// Maxiumum acceptable Ether amount 
    uint256 public maxValue = 100 ether;

    /// Minimum acceptable Ether amount, 1 ITM worth
    uint256 public minValue = uint256(1 ether)/600;

    /// amount of raised money in wei
    uint256 public weiRaised = 0;
    uint256 public tokensSold = 0;

    /// High water line for contract balance
    uint256 internal highWater = 1 ether;

    /// What round it is
    uint8 public round = 0;

    
    
    /// then the _duration = 30(31)*24*60*60 seconds
    function IntimateShoppe(
        uint256 _startTime, 
        uint256 _duration, 
        uint256 _rate, 
        address _wallet_address, 
        address _token_address, 
        uint256 _cap,
        uint8 _round) public Authorized() {

        require(_startTime >= 0 && _duration > 0);
        require(_rate > 0);
        require(_wallet_address != address(0x0));
        require(_token_address != address(0x0));
        require(_cap > 0);

        round = _round;

        startTime = _startTime;
        endTime = startTime + _duration;

        rate = _rate;
        minValue = uint256(1 ether)/_rate;
        capTokens = _cap;
        wallet_address = _wallet_address;
        token_address = _token_address;
        token = StandardToken(token_address);
    }

    
    
    
    function trackContributions(address _sender, uint256 _value) internal {
        if (contributions[_sender].length == 0) {
            contributors.push(_sender);
        }
        contributions[_sender].push(_value);
    }

    
    
    function getContributors() external view ifAuthorized(msg.sender, APHRODITE) returns (address[]) {
        return contributors;
    }

    
    
    
    /// Using the function above one can get a list first, and then get individual Ether payments
    /// and aggregate them if needed
    function getContributionsForAddress(address _contributor) external view ifAuthorized(msg.sender, APHRODITE) returns (uint256[]) {
        return contributions[_contributor];
    }

    
    /// on market demand and value of the ITM token. Is also set via the constructor
    
    function setRound(uint8 _round) public ifAuthorized(msg.sender, APHRODITE) {
        round = _round;
    }

    
    
    function setMaxValue(uint256 _maxValue) public ifAuthorized(msg.sender, APHRODITE) {
        /// Cannot be modified once sale is ongoing
        require(now < startTime || now > endTime);
        maxValue = _maxValue;
    }

    
    
    function setMinValue(uint256 _minValue) public ifAuthorized(msg.sender, APHRODITE) {
        /// Cannot be modified once sale is ongoing
        require(now < startTime || now > endTime);
        minValue = _minValue;
    }


    
    
    
    function setTimes(uint256 _startTime, uint256 _duration) public ifAuthorized(msg.sender, APHRODITE) {
        /// Can't reset times if sale ongoing already, make sure everything else is set before
        require(now < startTime || now > endTime);

        require(_startTime >= 0 && _duration > 0);
        startTime = _startTime;
        endTime = startTime + _duration;
        emit SetPeriod(startTime, endTime);
    }


    
    
    function setCap(uint256 _capTokens) public ifAuthorized(msg.sender, APHRODITE) {
        /// Cannot be modified once sale is ongoing
        require(now < startTime || now > endTime);
        require(_capTokens > 0);
        capTokens = _capTokens;
    }

    
    
    function setRate(uint256 _rate) public ifAuthorized(msg.sender, APHRODITE) {
        require(_rate > 0);
        rate = _rate;
    }

    
    
    function changeCompanyWallet(address _wallet_address) public ifAuthorized(msg.sender, APHRODITE) {
        wallet_address = _wallet_address;
    }

    
    
    function getHighWater() public view ifAuthorized(msg.sender, APHRODITE) returns (uint256) {
        return highWater;
    }

    
    
    function setHighWater(uint256 _highWater) public ifAuthorized(msg.sender, APHRODITE) {
        highWater = _highWater;
    }


    /// fallback function used to buy tokens
    function () payable public {
        /// Make certain msg.value sent is within permitted bounds
        require(msg.value >= minValue && msg.value <= maxValue);
        backTokenOwner();
    }

    
    function backTokenOwner() whenNotPaused internal {

        // Within the current sale period
        require(now >= startTime && now <= endTime);

        // Transfer Ether from this contract to the company's or foundation's wallet_address

        if (address(this).balance >= highWater) {
            //wallet_address.transfer(msg.value);
            wallet_address.transfer(address(this).balance);
            emit Transfer(this, wallet_address, address(this).balance);
        }

        /// Keep data about buyers's addresses and amounts
        /// If this functionality is not wanted, comment out the next line
        trackContributions(msg.sender, msg.value);

        uint256 tokens = msg.value.mul(rate);

        /// Transfer purchased tokens to the public buyer

        /// Note that the address authorized to control the token contract needs to set "wallet_address" allowance
        /// using ERC20 approve function before this contract can transfer tokens.
   
        if (token.transferFrom(wallet_address, msg.sender, tokens)) {

            token.freezeAccount(msg.sender);

            weiRaised = weiRaised.add(msg.value);
            tokensSold = tokensSold.add(tokens);
            emit ITMTokenPurchase(wallet_address, msg.sender, msg.value, tokens);

            // Check the cap and revert if exceeded
            require(tokensSold <= capTokens);
        }
    }
}