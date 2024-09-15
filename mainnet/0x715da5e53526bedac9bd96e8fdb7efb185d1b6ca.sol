// SPDX-License-Identifier: AGPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-02-12
*/

// 
pragma solidity 0.8.11;




interface IERC165 {
    
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}




interface IERC721 is IERC165 {
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) external view returns (address owner);

    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    
    
    
    
    function approve(address to, uint256 tokenId) external;

    
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    
    
    function setApprovalForAll(address operator, bool _approved) external;

    
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/// Fee Overflow


error FeeOverflow(address sender, uint256 fee);

/// Non Coordinator


error NonCoordinator(address sender, address coordinator);




contract Coordinator {
    
    address public coordinator;

    
    address payable public profitReceiver;

    
    
    uint32 public botFeeBips;

    
    uint32 public constant MAXIMUM_FEE = 10_000;

    
    modifier onlyCoordinator() {
        if (msg.sender != coordinator) revert NonCoordinator(msg.sender, coordinator);
        _;
    }

    
    
    
    
    constructor(address _profitReceiver, uint32 _botFeeBips) {
        if (botFeeBips > MAXIMUM_FEE) revert FeeOverflow(msg.sender, _botFeeBips);
        coordinator = msg.sender;
        profitReceiver = payable(_profitReceiver);
        botFeeBips = _botFeeBips;
    }

    
    
    function changeCoordinator(address newCoordinator) external onlyCoordinator {
        coordinator = newCoordinator;
    }

    
    
    function changeProfitReceiver(address newProfitReceiver) external onlyCoordinator {
        profitReceiver = payable(newProfitReceiver);
    }

    
    
    
    function changeBotFeeBips(uint32 newBotFeeBips) external onlyCoordinator {
        if (newBotFeeBips > MAXIMUM_FEE) revert FeeOverflow(msg.sender, newBotFeeBips);
        botFeeBips = newBotFeeBips;
    }
}

/// Require EOA
error NonEOA();

/// Order Out of Bounds



error OrderOOB(address sender, uint256 orderNumber, uint256 maxOrderCount);

/// Order Nonexistent



error OrderNonexistent(address user, uint256 orderNumber, uint256 orderId);

/// Invalid Amount




error InvalidAmount(address sender, uint256 priceInWeiEach, uint256 quantity, address tokenAddress);

/// Insufficient price in wei





error InsufficientPrice(address sender, uint256 orderId, uint256 tokenId, uint256 expectedPriceInWeiEach, uint256 priceInWeiEach);

/// Inconsistent Arguments

error InconsistentArguments(address sender);




///         https://etherscan.io/address/0x56E6FA0e461f92644c6aB8446EA1613F4D72a756#code
///         with the original UI at See ArtBotter.io

contract YobotERC721LimitOrder is Coordinator {
    
    struct Order {
        
        address owner;
        
        address tokenAddress;
        
        uint256 priceInWeiEach;
        
        uint256 quantity;
        
        uint256 num;
    }

    
    
    uint256 public orderId = 1;

    
    mapping(uint256 => Order) public orderStore;

    
    mapping(address => mapping(uint256 => uint256)) public userOrders;

    
    mapping(address => uint256) public userOrderCount;

    
    mapping(address => uint256) public balances;

    
    
    
    
    
    
    
    
    
    event Action(
        address indexed _user,
        address indexed _tokenAddress,
        uint256 indexed _priceInWeiEach,
        uint256 _quantity,
        string _action,
        uint256 _orderId,
        uint256 _orderNum,
        uint256 _tokenId
    );

    
    
    
    // solhint-disable-next-line no-empty-blocks
    constructor(address _profitReceiver, uint32 _botFeeBips) Coordinator(_profitReceiver, _botFeeBips) {}

    ////////////////////////////////////////////////////
    ///                     ORDERS                   ///
    ////////////////////////////////////////////////////

    
    
    
    
    function placeOrder(address _tokenAddress, uint256 _quantity) external payable {
        // Removes user foot-guns and garuantees user can receive NFTs
        // We disable linting against tx-origin to purposefully allow EOA checks
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender != tx.origin) revert NonEOA();

        // Check to make sure the bids are gt zero
        uint256 priceInWeiEach = msg.value / _quantity;
        if (priceInWeiEach == 0 || _quantity == 0) revert InvalidAmount(msg.sender, priceInWeiEach, _quantity, _tokenAddress);

        // Update the Order Id
        uint256 currOrderId = orderId;
        orderId += 1;

        // Get the current order number for the user
        uint256 currUserOrderCount = userOrderCount[msg.sender];

        // Create a new Order
        orderStore[currOrderId].owner = msg.sender;
        orderStore[currOrderId].tokenAddress = _tokenAddress;
        orderStore[currOrderId].priceInWeiEach = priceInWeiEach;
        orderStore[currOrderId].quantity = _quantity;
        orderStore[currOrderId].num = currUserOrderCount;

        // Update the user's orders
        userOrders[msg.sender][currUserOrderCount] = currOrderId;
        userOrderCount[msg.sender] += 1;

        emit Action(msg.sender, _tokenAddress, priceInWeiEach, _quantity, "ORDER_PLACED", currOrderId, currUserOrderCount, 0);
    }

    
    
    function cancelOrder(uint256 _orderNum) external {
        // Check to make sure the user's order is in bounds
        uint256 currUserOrderCount = userOrderCount[msg.sender];
        if (_orderNum >= currUserOrderCount) revert OrderOOB(msg.sender, _orderNum, currUserOrderCount);

        // Get the id for the given user order num
        uint256 currOrderId = userOrders[msg.sender][_orderNum];
        
        // Revert if the order id is 0, already deleted or filled
        if (currOrderId == 0) revert OrderNonexistent(msg.sender, _orderNum, currOrderId);

        // Get the order
        Order memory order = orderStore[currOrderId];
        uint256 amountToSendBack = order.priceInWeiEach * order.quantity;
        if (amountToSendBack == 0) revert InvalidAmount(msg.sender, order.priceInWeiEach, order.quantity, order.tokenAddress);

        // Delete the order
        delete orderStore[currOrderId];

        // Delete the order id from the userOrders mapping
        delete userOrders[msg.sender][_orderNum];

        // Send the value back to the user
        sendValue(payable(msg.sender), amountToSendBack);

        emit Action(msg.sender, order.tokenAddress, order.priceInWeiEach, order.quantity, "ORDER_CANCELLED", currOrderId, _orderNum, 0);
    }

    ////////////////////////////////////////////////////
    ///                  BOT LOGIC                   ///
    ////////////////////////////////////////////////////

    
    
    
    
    
    
    function fillOrder(
        uint256 _orderId,
        uint256 _tokenId,
        uint256 _expectedPriceInWeiEach,
        address _profitTo,
        bool _sendNow
    ) public returns (uint256) {
        Order storage order = orderStore[_orderId];

        // Make sure the order isn't deleted
        uint256 orderIdFromMap = userOrders[order.owner][order.num];
        if (order.quantity == 0 || order.priceInWeiEach == 0 || orderIdFromMap == 0) revert InvalidAmount(order.owner, order.priceInWeiEach, order.quantity, order.tokenAddress);

        // Protects bots from users frontrunning them
        if (order.priceInWeiEach < _expectedPriceInWeiEach) revert InsufficientPrice(msg.sender, _orderId, _tokenId, _expectedPriceInWeiEach, order.priceInWeiEach);

        // Transfer NFT to user (benign reentrancy possible here)
        // ERC721-compliant contracts revert on failure here
        IERC721(order.tokenAddress).safeTransferFrom(msg.sender, order.owner, _tokenId);
        
        // This reverts on underflow
        order.quantity -= 1;
        uint256 botFee = (order.priceInWeiEach * botFeeBips) / 10_000;
        balances[profitReceiver] += botFee;

        // Pay the bot with the remaining amount
        uint256 botPayment = order.priceInWeiEach - botFee;
        if (_sendNow) {
            sendValue(payable(_profitTo), botPayment);
        } else {
            balances[_profitTo] += botPayment;
        }

        // Emit the action later so we can log trace on a bot dashboard
        emit Action(order.owner, order.tokenAddress, order.priceInWeiEach, order.quantity, "ORDER_FILLED", _orderId, order.num, _tokenId);

        // Clear up if the quantity is now 0
        if (order.quantity == 0) {
            delete orderStore[_orderId];
            userOrders[order.owner][order.num] = 0;
        }

        // RETURN
        return botPayment;
    }

    
    
    
    
    
    
    
    
    function fillMultipleOrdersOptimized(
        uint256[] memory _orderIds,
        uint256[] memory _tokenIds,
        uint256[] memory _expectedPriceInWeiEach,
        address _profitTo,
        bool _sendNow
    ) external returns (uint256[] memory) {
        if (_orderIds.length != _tokenIds.length || _tokenIds.length != _expectedPriceInWeiEach.length) revert InconsistentArguments(msg.sender);
        uint256[] memory output = new uint256[](_orderIds.length);
        for (uint256 i = 0; i < _orderIds.length; i++) {
            output[i] = fillOrder(_orderIds[i], _tokenIds[i], _expectedPriceInWeiEach[i], _profitTo, _sendNow);
        }
        return output;
    }

    
    
    
    
    
    
    
    function fillMultipleOrdersUnOptimized(
        uint256[] memory _orderIds,
        uint256[] memory _tokenIds,
        uint256[] memory _expectedPriceInWeiEach,
        address[] memory _profitTo,
        bool[] memory _sendNow
    ) external returns (uint256[] memory) {
        if (
            _orderIds.length != _tokenIds.length
            || _tokenIds.length != _expectedPriceInWeiEach.length
            || _expectedPriceInWeiEach.length != _profitTo.length
            || _profitTo.length != _sendNow.length
        ) revert InconsistentArguments(msg.sender);

        // Fill the orders iteratively
        uint256[] memory output = new uint256[](_orderIds.length);
        for (uint256 i = 0; i < _orderIds.length; i++) {
            output[i] = fillOrder(_orderIds[i], _tokenIds[i], _expectedPriceInWeiEach[i], _profitTo[i], _sendNow[i]);
        }
        return output;
    }

    ////////////////////////////////////////////////////
    ///                 WITHDRAWALS                  ///
    ////////////////////////////////////////////////////

    
    
    function withdraw() external {
        // EFFECTS
        uint256 amount = balances[msg.sender];
        delete balances[msg.sender];
        // INTERACTIONS
        sendValue(payable(msg.sender), amount);
    }

    ////////////////////////////////////////////////////
    ///                   HELPERS                    ///
    ////////////////////////////////////////////////////

    
    
    
    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    
    
    function viewUserOrder(address _user, uint256 _orderNum) public view returns (Order memory) {
        // Revert if the order id is 0
        uint256 _orderId = userOrders[_user][_orderNum];
        if (_orderId == 0) revert OrderNonexistent(_user, _orderNum, _orderId);
        return orderStore[_orderId];
    }

    
    
    function viewUserOrders(address _user) public view returns (Order[] memory output) {
        uint256 _userOrderCount = userOrderCount[_user];
        output = new Order[](_userOrderCount);
        for (uint256 i = 0; i < _userOrderCount; i += 1) {
            uint256 _orderId = userOrders[_user][i];
            output[i] = orderStore[_orderId]; 
        }
    }

    
    
    function viewMultipleOrders(address[] memory _users) public view returns (Order[][] memory output) {
        Order[][] memory output = new Order[][](_users.length);
        for (uint256 i = 0; i < _users.length; i++) {
            output[i] = viewUserOrders(_users[i]);
        }
    }
}