
pragma solidity 0.4.24;


/// for Ether values. Does not support ERC20 tokens.
contract RenExAtomicSwapper {
    string public VERSION; // Passed in as a constructor parameter.

    struct Swap {
        uint256 timelock;
        uint256 value;
        address ethTrader;
        address withdrawTrader;
        bytes32 secretLock;
        bytes32 secretKey;
    }

    enum States {
        INVALID,
        OPEN,
        CLOSED,
        EXPIRED
    }

    // Events
    event LogOpen(bytes32 _swapID, address _withdrawTrader, bytes32 _secretLock);
    event LogExpire(bytes32 _swapID);
    event LogClose(bytes32 _swapID, bytes32 _secretKey);

    // Storage
    mapping (bytes32 => Swap) private swaps;
    mapping (bytes32 => States) private swapStates;
    mapping (bytes32 => uint256) public redeemedAt;

    
    modifier onlyInvalidSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.INVALID, "swap opened previously");
        _;
    }

    
    modifier onlyOpenSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.OPEN, "swap not open");
        _;
    }

    
    modifier onlyClosedSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.CLOSED, "swap not redeemed");
        _;
    }

    
    modifier onlyExpirableSwaps(bytes32 _swapID) {
        /* solium-disable-next-line security/no-block-members */
        require(now >= swaps[_swapID].timelock, "swap not expirable");
        _;
    }

    
    modifier onlyWithSecretKey(bytes32 _swapID, bytes32 _secretKey) {
        require(swaps[_swapID].secretLock == sha256(abi.encodePacked(_secretKey)), "invalid secret");
        _;
    }

    
    ///
    
    constructor(string _VERSION) public {
        VERSION = _VERSION;
    }

    
    ///
    
    
    
    
    function initiate(
        bytes32 _swapID,
        address _withdrawTrader,
        bytes32 _secretLock,
        uint256 _timelock
    ) external onlyInvalidSwaps(_swapID) payable {
        // Store the details of the swap.
        Swap memory swap = Swap({
            timelock: _timelock,
            value: msg.value,
            ethTrader: msg.sender,
            withdrawTrader: _withdrawTrader,
            secretLock: _secretLock,
            secretKey: 0x0
        });
        swaps[_swapID] = swap;
        swapStates[_swapID] = States.OPEN;

        // Logs open event
        emit LogOpen(_swapID, _withdrawTrader, _secretLock);
    }

    
    ///
    
    
    function redeem(bytes32 _swapID, bytes32 _secretKey) external onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) {
        // Close the swap.
        Swap memory swap = swaps[_swapID];
        swaps[_swapID].secretKey = _secretKey;
        swapStates[_swapID] = States.CLOSED;
        /* solium-disable-next-line security/no-block-members */
        redeemedAt[_swapID] = now;

        // Transfer the ETH funds from this contract to the withdrawing trader.
        swap.withdrawTrader.transfer(swap.value);

        // Logs close event
        emit LogClose(_swapID, _secretKey);
    }

    
    ///
    
    function refund(bytes32 _swapID) external onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) {
        // Expire the swap.
        Swap memory swap = swaps[_swapID];
        swapStates[_swapID] = States.EXPIRED;

        // Transfer the ETH value from this contract back to the ETH trader.
        swap.ethTrader.transfer(swap.value);

        // Logs expire event
        emit LogExpire(_swapID);
    }

    
    ///
    
    function audit(bytes32 _swapID) external view returns (uint256 timelock, uint256 value, address to, address from, bytes32 secretLock) {
        Swap memory swap = swaps[_swapID];
        return (swap.timelock, swap.value, swap.withdrawTrader, swap.ethTrader, swap.secretLock);
    }

    
    ///
    
    function auditSecret(bytes32 _swapID) external view onlyClosedSwaps(_swapID) returns (bytes32 secretKey) {
        Swap memory swap = swaps[_swapID];
        return swap.secretKey;
    }

    
    ///
    
    function refundable(bytes32 _swapID) external view returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        return (now >= swaps[_swapID].timelock && swapStates[_swapID] == States.OPEN);
    }

    
    ///
    
    function initiatable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == States.INVALID);
    }

    
    ///
    
    function redeemable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == States.OPEN);
    }

    
    ///
    
    
    
    function swapID(address _withdrawTrader, bytes32 _secretLock, uint256 _timelock) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_withdrawTrader, _secretLock, _timelock));
    }
}