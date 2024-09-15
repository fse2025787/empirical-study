// SPDX-License-Identifier: AGPL-3.0-only

// 
pragma solidity >=0.8.0;



abstract contract ERC1155 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    /*//////////////////////////////////////////////////////////////
                             ERC1155 STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                             METADATA LOGIC
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                              ERC1155 LOGIC
    //////////////////////////////////////////////////////////////*/

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public virtual {
        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, from, id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public virtual {
        require(ids.length == amounts.length, "LENGTH_MISMATCH");

        require(msg.sender == from || isApprovedForAll[from][msg.sender], "NOT_AUTHORIZED");

        // Storing these outside the loop saves ~15 gas per iteration.
        uint256 id;
        uint256 amount;

        for (uint256 i = 0; i < ids.length; ) {
            id = ids[i];
            amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, from, ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        require(owners.length == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        // Unchecked because the only math done is incrementing
        // the array index counter which cannot possibly overflow.
        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(msg.sender, address(0), id, amount, data) ==
                    ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(msg.sender, address(0), ids, amounts, data) ==
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

// 
pragma solidity ^0.8.0;

interface IOptionToken {
    /**
     * @dev mint option token to an address. Can only be called by corresponding margin engine
     * @param _recipient    where to mint token to
     * @param _tokenId      tokenId to mint
     * @param _amount       amount to mint
     *
     */
    function mint(address _recipient, uint256 _tokenId, uint256 _amount) external;

    /**
     * @dev burn option token from an address. Can only be called by corresponding margin engine
     * @param _from         account to burn from
     * @param _tokenId      tokenId to burn
     * @param _amount       amount to burn
     *
     */
    function burn(address _from, uint256 _tokenId, uint256 _amount) external;

    /**
     * @dev burn option token from an address. Can only be called by grappa, used for settlement
     * @param _from         account to burn from
     * @param _tokenId      tokenId to burn
     * @param _amount       amount to burn
     *
     */
    function burnGrappaOnly(address _from, uint256 _tokenId, uint256 _amount) external;

    /**
     * @dev burn batch of option token from an address. Can only be called by grappa
     * @param _from         account to burn from
     * @param _ids          tokenId to burn
     * @param _amounts      amount to burn
     *
     */
    function batchBurnGrappaOnly(address _from, uint256[] memory _ids, uint256[] memory _amounts) external;
}



abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}

// 
pragma solidity ^0.8.0;


uint8 constant UNIT_DECIMALS = 6;


uint256 constant UNIT = 10 ** 6;


int256 constant sUNIT = int256(10 ** 6);


uint256 constant BPS = 10000;


uint256 constant MAX_DISPUTE_PERIOD = 6 hours;

// 
pragma solidity ^0.8.0;

enum TokenType {
    PUT,
    PUT_SPREAD,
    CALL,
    CALL_SPREAD
}

/**
 * @dev action types
 */
enum ActionType {
    AddCollateral,
    RemoveCollateral,
    MintShort,
    BurnShort,
    MergeOptionToken,
    SplitOptionToken,
    AddLong,
    RemoveLong,
    SettleAccount,
    // actions that influece more than one subAccounts:
    MintShortIntoAccount, // increase short (debt) position in one subAccount, increase long token directly to another subAccount
    TransferCollateral, // transfer collateral direclty to another subAccount
    TransferLong, // transfer long directly to another subAccount
    TransferShort // transfer short directly to another subAccount
}

// 
pragma solidity ^0.8.0;

// for easier import





/* ------------------------ *
 *      Shared Errors       *
 * -----------------------  */

error NoAccess();

/* ------------------------ *
 *      Grappa Errors       *
 * -----------------------  */


error GP_AssetAlreadyRegistered();


error GP_EngineAlreadyRegistered();


error GP_OracleAlreadyRegistered();


error GP_BadOracle();


error GP_WrongArgumentLength();


error GP_NotExpired();


error GP_PriceNotFinalized();


error GP_InvalidExpiry();


error GP_BadStrikes();


error GP_Not_Authorized_Engine();

/* ---------------------------- *
 *   Common BaseEngine Errors   *
 * ---------------------------  */


error BM_CannotMergeSpread();


error BM_CanOnlySplitSpread();


error BM_MergeTypeMismatch();


error BM_MergeProductMismatch();


error BM_MergeExpiryMismatch();


error BM_MergeWithSameStrike();


error BM_AccountUnderwater();


error BM_InvalidFromAddress();

// 
pragma solidity ^0.8.0;



/**
 * @dev struct representing the current balance for a given collateral
 * @param collateralId grappa asset id
 * @param amount amount the asset
 */
struct Balance {
    uint8 collateralId;
    uint80 amount;
}

/**
 * @dev struct containing assets detail for an product
 * @param underlying    underlying address
 * @param strike        strike address
 * @param collateral    collateral address
 * @param collateralDecimals collateral asset decimals
 */
struct ProductDetails {
    address oracle;
    uint8 oracleId;
    address engine;
    uint8 engineId;
    address underlying;
    uint8 underlyingId;
    uint8 underlyingDecimals;
    address strike;
    uint8 strikeId;
    uint8 strikeDecimals;
    address collateral;
    uint8 collateralId;
    uint8 collateralDecimals;
}

// todo: update doc
struct ActionArgs {
    ActionType action;
    bytes data;
}

struct BatchExecute {
    address subAccount;
    ActionArgs[] actions;
}

/**
 * @dev asset detail stored per asset id
 * @param addr address of the asset
 * @param decimals token decimals
 */
struct AssetDetail {
    address addr;
    uint8 decimals;
}

// 
pragma solidity ^0.8.0;

// external libraries


// interfaces




// constants and types




/**
 * @title   OptionToken
 * @author  antoncoding
 * @dev     each OptionToken represent the right to redeem cash value at expiry.
 *             The value of each OptionType should always be positive.
 */
contract OptionToken is ERC1155, IOptionToken {
    
    IGrappa public immutable grappa;
    IOptionTokenDescriptor public immutable descriptor;

    constructor(address _grappa, address _descriptor) {
        // solhint-disable-next-line reason-string
        if (_grappa == address(0)) revert();
        grappa = IGrappa(_grappa);

        descriptor = IOptionTokenDescriptor(_descriptor);
    }

    /**
     *  @dev return string as defined in token descriptor
     *
     */
    function uri(uint256 id) public view override returns (string memory) {
        return descriptor.tokenURI(id);
    }

    /**
     * @dev mint option token to an address. Can only be called by corresponding margin engine
     * @param _recipient    where to mint token to
     * @param _tokenId      tokenId to mint
     * @param _amount       amount to mint
     */
    function mint(address _recipient, uint256 _tokenId, uint256 _amount) external override {
        grappa.checkEngineAccessAndTokenId(_tokenId, msg.sender);

        _mint(_recipient, _tokenId, _amount, "");
    }

    /**
     * @dev burn option token from an address. Can only be called by corresponding margin engine
     * @param _from         account to burn from
     * @param _tokenId      tokenId to burn
     * @param _amount       amount to burn
     *
     */
    function burn(address _from, uint256 _tokenId, uint256 _amount) external override {
        grappa.checkEngineAccess(_tokenId, msg.sender);

        _burn(_from, _tokenId, _amount);
    }

    /**
     * @dev burn option token from an address. Can only be called by grappa, used for settlement
     * @param _from         account to burn from
     * @param _tokenId      tokenId to burn
     * @param _amount       amount to burn
     *
     */
    function burnGrappaOnly(address _from, uint256 _tokenId, uint256 _amount) external override {
        _checkIsGrappa();
        _burn(_from, _tokenId, _amount);
    }

    /**
     * @dev burn batch of option token from an address. Can only be called by grappa, used for settlement
     * @param _from         account to burn from
     * @param _ids          tokenId to burn
     * @param _amounts      amount to burn
     *
     */
    function batchBurnGrappaOnly(address _from, uint256[] memory _ids, uint256[] memory _amounts) external override {
        _checkIsGrappa();
        _batchBurn(_from, _ids, _amounts);
    }

    /**
     * @dev check if msg.sender is the marginAccount
     */
    function _checkIsGrappa() internal view {
        if (msg.sender != address(grappa)) revert NoAccess();
    }
}

// 
pragma solidity ^0.8.0;

/* ------------------------ *
 *  Advanced Margin Errors
 * -----------------------  */


error AM_UnsupportedAction();


error AM_WrongCollateralId();


error AM_ShortDoesNotExist();


error AM_MergeAmountMisMatch();


error AM_SplitAmountMisMatch();


error AM_InvalidToken();


error AM_NoConfig();


error AM_AccountIsHealthy();


error AM_AccountIsNotEmpty();


error AM_WrongRepayAmounts();


error AM_ExpiredShortInAccount();

// Vol Oracle


error VO_AggregatorAlreadySet();


error VO_AggregatorNotSet();

// 
pragma solidity ^0.8.0;

/* --------------------- *
 *  Cross Margin Errors
 * --------------------- */


error CM_UnsupportedAction();


error CM_AccountIsNotEmpty();


error CM_UnsupportedTokenType();


error CM_Option_Expired();


error CM_Not_Authorized_Engine();


error CM_WrongCollateralId();


error CM_CannotMintOptionWithThisCollateral();


error CM_InvalidToken();

/* --------------------- *
 *  Cross Margin Math Errors
 * --------------------- */


error CMM_InvalidPutLengths();


error CMM_InvalidCallLengths();


error CMM_InvalidPutWeight();


error CMM_InvalidCallWeight();

// 
pragma solidity ^0.8.0;

/* ------------------------ *
 *    Full Margin Errors
 * -----------------------  */


error FM_UnsupportedAction();


///         call can only be collateralized by underlying
///         put can only be collateralized by strike
error FM_CannotMintOptionWithThisCollateral();


error FM_WrongCollateralId();


error FM_InvalidToken();


error FM_ShortDoesNotExist();


error FM_MergeAmountMisMatch();


error FM_SplitAmountMisMatch();


error FM_CollateralMisMatch();


error FM_AccountIsNotEmpty();


error FM_ExpiredShortInAccount();

// 
pragma solidity ^0.8.0;

error OC_CannotReportForFuture();

error OC_PriceNotReported();

error OC_PriceReported();


error OC_DisputePeriodOver();


error OC_GracePeriodNotOver();


error OC_PriceDisputed();


error OC_InvalidDisputePeriod();

// Chainlink oracle

error CL_AggregatorNotSet();

error CL_StaleAnswer();

error CL_RoundIdTooSmall();

// 
pragma solidity ^0.8.0;



interface IGrappa {
    function getDetailFromProductId(uint40 _productId)
        external
        view
        returns (
            address oracle,
            address engine,
            address underlying,
            uint8 underlyingDecimals,
            address strike,
            uint8 strikeDecimals,
            address collateral,
            uint8 collateralDecimals
        );

    function checkEngineAccess(uint256 _tokenId, address _engine) external view;

    function checkEngineAccessAndTokenId(uint256 _tokenId, address _engine) external view;

    function engineIds(address _engine) external view returns (uint8 id);

    function assets(uint8 _id) external view returns (address addr, uint8 decimals);

    function engines(uint8 _id) external view returns (address engine);

    function oracles(uint8 _id) external view returns (address oracle);

    function getPayout(uint256 tokenId, uint64 amount)
        external
        view
        returns (address engine, address collateral, uint256 payout);

    /**
     * @notice burn option token and get out cash value at expiry
     * @param _account who to settle for
     * @param _tokenId  tokenId of option token to burn
     * @param _amount   amount to settle
     * @return payout amount paid out
     */
    function settleOption(address _account, uint256 _tokenId, uint256 _amount) external returns (uint256 payout);

    /**
     * @notice burn array of option tokens and get out cash value at expiry
     * @param _account who to settle for
     * @param _tokenIds array of tokenIds to burn
     * @param _amounts   array of amounts to burn
     */
    function batchSettleOptions(address _account, uint256[] memory _tokenIds, uint256[] memory _amounts)
        external
        returns (Balance[] memory payouts);

    function batchGetPayouts(uint256[] memory _tokenIds, uint256[] memory _amounts) external returns (Balance[] memory payouts);
}

// 
pragma solidity ^0.8.0;


interface IOptionTokenDescriptor {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}