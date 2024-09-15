
pragma solidity ^0.4.8;
/*
AvatarNetwork Copyright

https://avatarnetwork.io

*/

/* Родительский контракт */
contract Owned {

    /* Адрес владельца контракта*/
    address owner;

    /* Конструктор контракта, вызывается при первом запуске */
    function Owned() {
        owner = msg.sender;
    }

        /* Изменить владельца контракта, newOwner - адрес нового владельца */
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }


    /* Модификатор для ограничения доступа к функциям только для владельца */
    modifier onlyowner() {
        if (msg.sender==owner) _;
    }
}

// Абстрактный контракт для токена стандарта ERC 20
// https://github.com/ethereum/EIPs/issues/20
contract Token is Owned {

    /// Общее кол-во токенов
    uint256 public totalSupply;

    
    
    function balanceOf(address _owner) constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
Контракт реализует ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20Token is Token
{

    function transfer(address _to, uint256 _value) returns (bool success)
    {
        //По-умолчанию предполагается, что totalSupply не может быть больше (2^256 - 1).
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
    {
        //По-умолчанию предполагается, что totalSupply не может быть больше (2^256 - 1).
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

/* Основной контракт токена, наследует ERC20Token */
contract ArmMoneyliFe is ERC20Token
{
    bool public isTokenSale = true;
    uint256 public price;
    uint256 public limit;

    address walletOut = 0xde8c00ae50b203ac1091266d5b207fbc59be5bc4;

    function getWalletOut() constant returns (address _to) {
        return walletOut;
    }

    function () external payable  {
        if (isTokenSale == false) {
            throw;
        }

        uint256 tokenAmount = (msg.value  * 1000000000000000000) / price;

        if (balances[owner] >= tokenAmount && balances[msg.sender] + tokenAmount > balances[msg.sender]) {
            if (balances[owner] - tokenAmount < limit) {
                throw;
            }
            balances[owner] -= tokenAmount;
            balances[msg.sender] += tokenAmount;
            Transfer(owner, msg.sender, tokenAmount);
        } else {
            throw;
        }
    }

    function stopSale() onlyowner {
        isTokenSale = false;
    }

    function startSale() onlyowner {
        isTokenSale = true;
    }

    function setPrice(uint256 newPrice) onlyowner {
        price = newPrice;
    }

    function setLimit(uint256 newLimit) onlyowner {
        limit = newLimit;
    }

    function setWallet(address _to) onlyowner {
        walletOut = _to;
    }

    function sendFund() onlyowner {
        walletOut.send(this.balance);
    }

    /* Публичные переменные токена */
    string public name;                 // Название
    uint8 public decimals;              // Сколько десятичных знаков
    string public symbol;               // Идентификатор (трехбуквенный обычно)
    string public version = '1.0';      // Версия

    function ArmMoneyliFe()
    {
        totalSupply = 1000000000000000000000000000;
        balances[msg.sender] = 1000000000000000000000000000;  // Передача создателю всех выпущенных монет
        name = 'ArmMoneyliFe';
        decimals = 18;
        symbol = 'AMF';
        price = 2188183807439824;
        limit = 0;
    }

    
    /* Добавляет на счет токенов */
    function add(uint256 _value) onlyowner returns (bool success)
    {
        if (balances[msg.sender] + _value <= balances[msg.sender]) {
            return false;
        }
        totalSupply += _value;
        balances[msg.sender] += _value;
        return true;
    }


    
}