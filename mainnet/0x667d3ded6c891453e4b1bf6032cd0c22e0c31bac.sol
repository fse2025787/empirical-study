// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.13;




interface IOrderBook {
    event SellOrderCreated(address indexed sellOrder);

    event OwnerChanged(address previous, address next);

    event FeeChanged(uint256 previous, uint256 next);

    function owner() external view returns (address);

    function fee() external view returns (uint256);

    function setFee(uint256 _fee) external;

    function setOwner(address _newOwner) external;

    function createSellOrder(
        address seller,
        IERC20 token,
        uint256 stake,
        string memory uri,
        uint256 timeout
    ) external returns (SellOrder);
}// 
pragma solidity ^0.8.13;






contract OrderBook is IOrderBook {
    
    mapping(address => bool) public sellOrders;

    
    uint256 public fee = 10000; // 1%

    
    address private _owner;

    
    error NotOwner();

    
    constructor() {
        _owner = msg.sender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (owner() != msg.sender) {
            revert NotOwner();
        }
        _;
    }

    
    function setFee(uint256 _fee) external onlyOwner {
        emit FeeChanged(fee, _fee);
        fee = _fee;
    }

    
    function setOwner(address _newOwner) external onlyOwner {
        emit OwnerChanged(owner(), _newOwner);
        _owner = _newOwner;
    }

    
    function createSellOrder(
        address seller,
        IERC20 token,
        uint256 stake,
        string memory uri,
        uint256 timeout
    ) external returns (SellOrder) {
        SellOrder sellOrder = new SellOrder(seller, token, stake, uri, timeout);
        emit SellOrderCreated(address(sellOrder));
        sellOrders[address(sellOrder)] = true;
        return sellOrder;
    }
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// 
pragma solidity ^0.8.13;




contract SellOrder {
    
    error MustBeSeller();

    
    error InvalidState(State expected, State received);

    
    event OfferSubmitted(
        address indexed buyer,
        uint256 indexed price,
        uint256 indexed stake,
        string uri
    );

    
    event OfferWithdrawn(address indexed buyer);

    
    event OfferCommitted(address indexed buyer);

    
    event OfferConfirmed(address indexed buyer);

    
    event OfferEnforced(address indexed buyer);

    
    IERC20 public token;

    
    address public seller;

    
    uint256 public timeout;

    
    uint256 public orderStake;

    
    address public orderBook;

    
    string private _uri;

    
    enum State {
        Closed,
        Open,
        Committed
    }

    struct Offer {
        
        uint256 price;
        
        uint256 stake;
        
        string uri;
        
        State state;
        
        uint256 acceptedAt;
    }

    
    mapping(address => Offer) public offers;

    
    uint256 constant ONE_MILLION = 1000000;

    
    constructor(
        address seller_,
        IERC20 token_,
        uint256 orderStake_,
        string memory uri_,
        uint256 timeout_
    ) {
        orderBook = msg.sender;
        seller = seller_;
        token = token_;
        orderStake = orderStake_;
        _uri = uri_;
        timeout = timeout_;
    }

    
    function orderURI() external view virtual returns (string memory) {
        return _uri;
    }

    
    function setURI(string memory uri_) external virtual onlySeller {
        _uri = uri_;
    }

    
    modifier onlyState(address buyer_, State expected) {
        if (offers[buyer_].state != expected) {
            revert InvalidState(expected, offers[buyer_].state);
        }

        _;
    }

    
    modifier onlySeller() {
        if (msg.sender != seller) {
            revert MustBeSeller();
        }

        _;
    }

    
    function submitOffer(
        uint256 price,
        uint256 stake,
        string memory uri
    ) external virtual onlyState(msg.sender, State.Closed) {
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= stake + price, 'Insufficient allowance');

        offers[msg.sender] = Offer(price, stake, uri, State.Open, 0);

        bool result = token.transferFrom(
            msg.sender,
            address(this),
            stake + price
        );
        require(result, 'Transfer failed');

        emit OfferSubmitted(msg.sender, price, stake, uri);
    }

    
    function withdrawOffer()
        external
        virtual
        onlyState(msg.sender, State.Open)
    {
        Offer memory offer = offers[msg.sender];

        bool result = token.transfer(msg.sender, offer.stake + offer.price);
        assert(result);

        offers[msg.sender] = Offer(0, 0, offer.uri, State.Closed, 0);

        emit OfferWithdrawn(msg.sender);
    }

    
    function commit(address buyer_)
        external
        virtual
        onlyState(buyer_, State.Open)
        onlySeller
    {
        // Deposit the stake required to commit to the offer
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= orderStake);
        bool result = token.transferFrom(msg.sender, address(this), orderStake);
        assert(result);

        // Update the status of the buyer's offer
        Offer memory offer = offers[buyer_];
        offers[buyer_] = Offer(
            offer.price,
            offer.stake,
            offer.uri,
            State.Committed,
            block.timestamp
        );

        emit OfferCommitted(buyer_);
    }

    
    function confirm() external virtual onlyState(msg.sender, State.Committed) {
        // Close the offer
        Offer memory offer = offers[msg.sender];
        offers[msg.sender] = Offer(
            0,
            0,
            offer.uri,
            State.Closed,
            block.timestamp
        );

        // Return the stake to the buyer
        bool result0 = token.transfer(msg.sender, offer.stake);
        assert(result0);

        // Return the stake to the seller
        bool result1 = token.transfer(seller, orderStake);
        assert(result1);

        uint256 toOrderBook = (offer.price * IOrderBook(orderBook).fee()) /
            ONE_MILLION;
        uint256 toSeller = offer.price - toOrderBook;

        // Transfer payment to the seller
        bool result2 = token.transfer(seller, toSeller);
        assert(result2);

        // Transfer payment to the order book
        bool result3 = token.transfer(
            IOrderBook(orderBook).owner(),
            toOrderBook
        );
        assert(result3);

        emit OfferConfirmed(msg.sender);
    }

    
    function enforce(address buyer_)
        external
        virtual
        onlyState(buyer_, State.Committed)
    {
        Offer memory offer = offers[buyer_];
        require(block.timestamp > timeout + offer.acceptedAt);

        // Close the offer
        offers[buyer_] = Offer(0, 0, offer.uri, State.Closed, block.timestamp);

        // Transfer the payment to the seller
        bool result0 = token.transfer(seller, offer.price);
        assert(result0);

        // Transfer the buyer's stake to address(dead).
        bool result1 = token.transfer(
            address(0x000000000000000000000000000000000000dEaD),
            offer.stake
        );
        assert(result1);

        // Transfer the seller's stake to address(dead).
        bool result2 = token.transfer(
            address(0x000000000000000000000000000000000000dEaD),
            orderStake
        );
        assert(result2);

        emit OfferEnforced(buyer_);
    }
}
