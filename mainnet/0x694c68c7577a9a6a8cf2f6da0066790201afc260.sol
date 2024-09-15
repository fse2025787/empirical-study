
pragma solidity ^0.4.21;

// File: @gnosis.pm/util-contracts/contracts/Math.sol




library Math {

    /*
     *  Constants
     */
    // This is equal to 1 in our calculations
    uint public constant ONE =  0x10000000000000000;
    uint public constant LN2 = 0xb17217f7d1cf79ac;
    uint public constant LOG2_E = 0x171547652b82fe177;

    /*
     *  Public functions
     */
    
    
    
    function exp(int x)
        public
        pure
        returns (uint)
    {
        // revert if x is > MAX_POWER, where
        // MAX_POWER = int(mp.floor(mp.log(mpf(2**256 - 1) / ONE) * ONE))
        require(x <= 2454971259878909886679);
        // return 0 if exp(x) is tiny, using
        // MIN_POWER = int(mp.floor(mp.log(mpf(1) / ONE) * ONE))
        if (x < -818323753292969962227)
            return 0;
        // Transform so that e^x -> 2^x
        x = x * int(ONE) / int(LN2);
        // 2^x = 2^whole(x) * 2^frac(x)
        //       ^^^^^^^^^^ is a bit shift
        // so Taylor expand on z = frac(x)
        int shift;
        uint z;
        if (x >= 0) {
            shift = x / int(ONE);
            z = uint(x % int(ONE));
        }
        else {
            shift = x / int(ONE) - 1;
            z = ONE - uint(-x % int(ONE));
        }
        // 2^x = 1 + (ln 2) x + (ln 2)^2/2! x^2 + ...
        //
        // Can generate the z coefficients using mpmath and the following lines
        // >>> from mpmath import mp
        // >>> mp.dps = 100
        // >>> ONE =  0x10000000000000000
        // >>> print('\n'.join(hex(int(mp.log(2)**i / mp.factorial(i) * ONE)) for i in range(1, 7)))
        // 0xb17217f7d1cf79ab
        // 0x3d7f7bff058b1d50
        // 0xe35846b82505fc5
        // 0x276556df749cee5
        // 0x5761ff9e299cc4
        // 0xa184897c363c3
        uint zpow = z;
        uint result = ONE;
        result += 0xb17217f7d1cf79ab * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x3d7f7bff058b1d50 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xe35846b82505fc5 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x276556df749cee5 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x5761ff9e299cc4 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xa184897c363c3 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xffe5fe2c4586 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x162c0223a5c8 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1b5253d395e * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1e4cf5158b * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1e8cac735 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1c3bd650 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x1816193 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x131496 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0xe1b7 * zpow / ONE;
        zpow = zpow * z / ONE;
        result += 0x9c7 * zpow / ONE;
        if (shift >= 0) {
            if (result >> (256-shift) > 0)
                return (2**256-1);
            return result << shift;
        }
        else
            return result >> (-shift);
    }

    
    
    
    function ln(uint x)
        public
        pure
        returns (int)
    {
        require(x > 0);
        // binary search for floor(log2(x))
        int ilog2 = floorLog2(x);
        int z;
        if (ilog2 < 0)
            z = int(x << uint(-ilog2));
        else
            z = int(x >> uint(ilog2));
        // z = x * 2^-⌊log₂x⌋
        // so 1 <= z < 2
        // and ln z = ln x - ⌊log₂x⌋/log₂e
        // so just compute ln z using artanh series
        // and calculate ln x from that
        int term = (z - int(ONE)) * int(ONE) / (z + int(ONE));
        int halflnz = term;
        int termpow = term * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 3;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 5;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 7;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 9;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 11;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 13;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 15;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 17;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 19;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 21;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 23;
        termpow = termpow * term / int(ONE) * term / int(ONE);
        halflnz += termpow / 25;
        return (ilog2 * int(ONE)) * int(ONE) / int(LOG2_E) + 2 * halflnz;
    }

    
    
    
    function floorLog2(uint x)
        public
        pure
        returns (int lo)
    {
        lo = -64;
        int hi = 193;
        // I use a shift here instead of / 2 because it floors instead of rounding towards 0
        int mid = (hi + lo) >> 1;
        while((lo + 1) < hi) {
            if (mid < 0 && x << uint(-mid) < ONE || mid >= 0 && x >> uint(mid) < ONE)
                hi = mid;
            else
                lo = mid;
            mid = (hi + lo) >> 1;
        }
    }

    
    
    
    function max(int[] nums)
        public
        pure
        returns (int maxNum)
    {
        require(nums.length > 0);
        maxNum = -2**255;
        for (uint i = 0; i < nums.length; i++)
            if (nums[i] > maxNum)
                maxNum = nums[i];
    }

    
    
    
    
    function safeToAdd(uint a, uint b)
        internal
        pure
        returns (bool)
    {
        return a + b >= a;
    }

    
    
    
    
    function safeToSub(uint a, uint b)
        internal
        pure
        returns (bool)
    {
        return a >= b;
    }

    
    
    
    
    function safeToMul(uint a, uint b)
        internal
        pure
        returns (bool)
    {
        return b == 0 || a * b / b == a;
    }

    
    
    
    
    function add(uint a, uint b)
        internal
        pure
        returns (uint)
    {
        require(safeToAdd(a, b));
        return a + b;
    }

    
    
    
    
    function sub(uint a, uint b)
        internal
        pure
        returns (uint)
    {
        require(safeToSub(a, b));
        return a - b;
    }

    
    
    
    
    function mul(uint a, uint b)
        internal
        pure
        returns (uint)
    {
        require(safeToMul(a, b));
        return a * b;
    }

    
    
    
    
    function safeToAdd(int a, int b)
        internal
        pure
        returns (bool)
    {
        return (b >= 0 && a + b >= a) || (b < 0 && a + b < a);
    }

    
    
    
    
    function safeToSub(int a, int b)
        internal
        pure
        returns (bool)
    {
        return (b >= 0 && a - b <= a) || (b < 0 && a - b > a);
    }

    
    
    
    
    function safeToMul(int a, int b)
        internal
        pure
        returns (bool)
    {
        return (b == 0) || (a * b / b == a);
    }

    
    
    
    
    function add(int a, int b)
        internal
        pure
        returns (int)
    {
        require(safeToAdd(a, b));
        return a + b;
    }

    
    
    
    
    function sub(int a, int b)
        internal
        pure
        returns (int)
    {
        require(safeToSub(a, b));
        return a - b;
    }

    
    
    
    
    function mul(int a, int b)
        internal
        pure
        returns (int)
    {
        require(safeToMul(a, b));
        return a * b;
    }
}

// File: @gnosis.pm/util-contracts/contracts/Proxy.sol



contract Proxied {
    address public masterCopy;
}



contract Proxy is Proxied {
    
    
    function Proxy(address _masterCopy)
        public
    {
        require(_masterCopy != 0);
        masterCopy = _masterCopy;
    }

    
    function ()
        external
        payable
    {
        address _masterCopy = masterCopy;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

// File: @gnosis.pm/util-contracts/contracts/Token.sol

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
pragma solidity ^0.4.21;



contract Token {

    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     *  Public functions
     */
    function transfer(address to, uint value) public returns (bool);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
    function balanceOf(address owner) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function totalSupply() public view returns (uint);
}

// File: @gnosis.pm/util-contracts/contracts/StandardToken.sol

contract StandardTokenData {

    /*
     *  Storage
     */
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;
    uint totalTokens;
}


contract StandardToken is Token, StandardTokenData {
    using Math for *;

    /*
     *  Public functions
     */
    
    
    
    
    function transfer(address to, uint value)
        public
        returns (bool)
    {
        if (   !balances[msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    
    
    
    
    
    function transferFrom(address from, address to, uint value)
        public
        returns (bool)
    {
        if (   !balances[from].safeToSub(value)
            || !allowances[from][msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    
    
    
    
    function approve(address spender, uint value)
        public
        returns (bool)
    {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    
    
    
    function allowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return allowances[owner][spender];
    }

    
    
    
    function balanceOf(address owner)
        public
        view
        returns (uint)
    {
        return balances[owner];
    }

    
    
    function totalSupply()
        public
        view
        returns (uint)
    {
        return totalTokens;
    }
}

// File: contracts/TokenOWL.sol

contract TokenOWL is Proxied, StandardToken {
    using Math for *;

    string public constant name = "OWL Token";
    string public constant symbol = "OWL";
    uint8 public constant decimals = 18;

    struct masterCopyCountdownType {
        address masterCopy;
        uint timeWhenAvailable;
    }

    masterCopyCountdownType masterCopyCountdown;

    address public creator;
    address public minter;

    event Minted(address indexed to, uint256 amount);
    event Burnt(address indexed from, address indexed user, uint256 amount);

    modifier onlyCreator() {
        // R1
        require(msg.sender == creator);
        _;
    }
    
    /// updating is only possible after 30 days
    function startMasterCopyCountdown (
        address _masterCopy
     )
        public
        onlyCreator()
    {
        require(address(_masterCopy) != 0);

        // Update masterCopyCountdown
        masterCopyCountdown.masterCopy = _masterCopy;
        masterCopyCountdown.timeWhenAvailable = now + 30 days;
    }

     
    function updateMasterCopy()
        public
        onlyCreator()
    {   
        require(address(masterCopyCountdown.masterCopy) != 0);
        require(now >= masterCopyCountdown.timeWhenAvailable);

        // Update masterCopy
        masterCopy = masterCopyCountdown.masterCopy;
    }

    function getMasterCopy()
        public
        view
        returns (address)
    {
        return masterCopy;
    }

    
    
    function setMinter(address newMinter)
        public
        onlyCreator()
    {
        minter = newMinter;
    }


    
    
    function setNewOwner(address newOwner)
        public
        onlyCreator()
    {
        creator = newOwner;
    }

    
    
    
    function mintOWL(address to, uint amount)
        public
    {
        require(minter != 0 && msg.sender == minter);
        balances[to] = balances[to].add(amount);
        totalTokens = totalTokens.add(amount);
        emit Minted(to, amount);
    }

    
    
    
    function burnOWL(address user, uint amount)
        public
    {
        allowances[user][msg.sender] = allowances[user][msg.sender].sub(amount);
        balances[user] = balances[user].sub(amount);
        totalTokens = totalTokens.sub(amount);
        emit Burnt(msg.sender, user, amount);
    }
}