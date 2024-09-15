// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}
// 

/*                          
*                                          |`._         |\
*                                           `   `.  .    | `.    |`.
*                                            .    `.|`-. |   `-..'  \           _,.-'
*                                            '      `-. `.           \ /|   _,-'   /
*                                        .--..'        `._`           ` |.-'      /
*                                         \   |                                  /
*                                      ,..'   '                                 /
*                                      `.                                      /
*                                      _`.---                                 /
*                                  _,-'               `.                 ,-  /"-._
*                                ,"                   | `.             ,'|   `    `.           
*                              .'                     |   `.         .'  |    .     `.
*                            ,'                       '   ()`.     ,'()  '    |       `.
*'                          -.                    |`.  `.....-'    -----' _   |         .
*                           / ,   ________..'     '  `-._              _.'/   |         :
*                           ` '-"" _,.--"'         \   | `"+--......-+' //   j `"--.. , '
*                              `.'"    .'           `. |   |     |   / //    .       ` '
*                                `.   /               `'   |    j   /,.'     '
*                                  \ /                  `-.|_   |_.-'       /\
*                                   /                        `""          .'  \
*                                  j                                           .
*                                  |                                 _,        |
*                                  |             ,^._            _.-"          '
*                                  |          _.'    `'""`----`"'   `._       '
*                                  j__     _,'                         `-.'-."`
*                                     ',-.,' 
*                           ++======================================================++
*       `````^`                                                                                                                                        .'```'  
*       ``````^^                                                                                                                                      `````^` 
*       ^````^"^                                                                                                                                      `^^^""' 
*       ^````^"^                                                                                                                                       .''.   
*       ^````^"^                                                                                                                                              
*       ^````^"^                          `````^'                       `````^`      ..'```````````````````````^.  ``````^'                          .``````^`
*       ^````^"^         ..''.            ````^^`                       `````^^    .'`````^^"""""^^^``````````^^.  ``````^`                          ``'''``^^
*       ^`````^^      .'`````^^.          ^```^"`            .          ````^^"   .`````^",`'..     .`````````^^.  ``````^`                          ``'''``^^
*       ^`````^`...'``^^^^^^^"".          ^```^"`        `````^'        ````^^"   `````^,`        '``````''```^".  ``````^`                          ``'''``^^
*       ^`````^""""""""""",,"^.           ^```^"`        `````^`        `````^"  .````^"`       .```````.``'``^".  ``''``^`                         .``'''``^^
*       ^````^""                          ````^"`        ````^^`        `````^"  '````^"'     .```````` ``''``^^.  ``''``^`                         .``'''``^^
*       `````^""                 ......   ````^"`        ````^"`        `````^"  '````^"'    .```````^ '`''''``^.  ``''``^`                 ......  .``'''``^^
*       ``````^^            .''``````^^.  `````^`       .`````^`       .`````^"  '`````^.   '``'''``^' ``''''``^.  ``''``^`            .''```````^  .``'''``^^
*       ``````^`         .'``````````^^.  `````^'      '````````     .'``''``^"  '``''``'..'`''''```^..``''''``^.  ``''``^`         .'```'''''``^^  .``'''``^^
*       ^```````.  ...'``````````````^".  ^``````.''````````````''```````````^"  '````````````````^^^ .```````^".  ^```````......'``````````````^"  .```````^^
*       ^"^^^^^^^^^^^^^^^^^^^^^"""""",,.  "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"",,  ."^^^^^^^^^^^^^"",,' '"^^^^^"",.  ""^^^^^^^^^^^^^^^^^^^^^^^^^"",,  ."^^^^""""
*/

pragma solidity ^0.8.13;



                                                                                                                                                                                            

contract TwaliContract is Initializable, ReentrancyGuard {
  
    address public owner;
    // expert address that is completion contract and recieving payment
    address payable public contract_expert;
    // SOW metadata for work agreed terms 
    string public contract_sowMetaData;

    bool private isInitialized;
    // Werk is approved or not approved yet
    bool public contract_werkApproved; // unassigned variable has default value of 'false'
    // Werk has been paid out 
    bool public contract_werkPaidOut;
    // Werk was refunded 
    bool public contract_werkRefunded;
    // contract creation date
    uint contract_created_on;
    // experts start date in contract
    uint public contract_start_date;
    // End date for werk completion 
    uint public contract_end_date;
    // Completion Date for submitted werk
    // Contract amount to be paid 
    uint256 public contract_payment_amount = 0.0 ether;

    
    /// Draft: Contract is in draft stage awaiting for applications and selection.
    /// Active: Contract is active and funded with pay out amount with a selected Contract Expert to complete werk.
    /// Complete: Contract werk is completed, approved by client, and Expert has recieved payment.
    /// Killed: Contract werk is canceled in draft stage or no longer active and client is refunded.
    enum Status { 
        Draft, Active, Complete, Killed
    }

    
    Status private contract_currentStatus;
  
    // Events
    event ReceivedPayout(address, bool, bool);
    event RefundedPayment(address, uint);
    event ContractActivated(address, uint, uint);
    event DepoistedExpertPaynment(address, uint);


    
    error InvalidCurrentStatus();


    /// Execute on a call to contract if no other functions match given function signature.
    fallback() external payable{}


    receive() external payable{}


    
    
    
    
    
    function initialize(
        address _adminClient,
        string memory _sowMetaData,
        uint _contract_payment_amount,
        uint _contract_start_date,
        uint _contract_end_date,
        uint _creationDate
    ) public initializer {
        require(!isInitialized, "Contract is already initialized");
        require(owner == address(0), "Can't do that the contract already initialized");
        owner = _adminClient;
        contract_sowMetaData = _sowMetaData;
        contract_payment_amount = _contract_payment_amount;
        contract_start_date = _contract_start_date;
        contract_end_date = _contract_end_date;
        contract_created_on = _creationDate;
        isInitialized = true;
    }

    /*
    *  Modifiers
    */ 

    
    modifier onlyOwner() {
        require(
            msg.sender == owner, 
            "Only owner can call this function"
            );
        _;
    }

    
    
    
    modifier isExpert(address _expert) {
        require(_expert == contract_expert, "Not contract expert address");
        _;
    }

    
    
    
    modifier isValid(address _addr) {
        require(_addr != address(0), "Not a valid address");
        _;
    }

    
    
    
    modifier isStatus(Status _contract_currentStatus) {
        if (contract_currentStatus != _contract_currentStatus)
            revert InvalidCurrentStatus();
        _;
    }

    
    modifier werkNotPaid() {
        require(contract_werkPaidOut != true, "Werk already paid out!");
        _;
    }

    
    modifier werkNotApproved() {
        require(contract_werkApproved != true, "Werk already approved!");
        _;
    }

    
    modifier isNotRefunded() {
        require(contract_werkRefunded != true, "Refunded already!");
        _;
    }

    
    
    modifier setNextStage() {
        _;
        nextStage();
    }



    
    function getCurrentStatus() public view returns (Status) {
        return contract_currentStatus;
    }

     
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    
    
    function refundClient() 
        internal 
    {
        contract_werkRefunded = true;
        emit RefundedPayment(owner, contract_payment_amount);
        uint256 balance = address(this).balance;
        contract_payment_amount = 0;
        payable(owner).transfer(balance);
    }

    
    function nextStage() internal {
        contract_currentStatus = Status(uint(contract_currentStatus)+1);
    }

    
    function killDraftContract() 
        external 
        onlyOwner
        isStatus(Status.Draft)
    {
        contract_currentStatus = Status.Killed;
    }

    
    
    
    function depositExpertPayment(uint _amount) public payable {
        require(_amount <= msg.value, "Wrong amount of ETH sent");

        emit DepoistedExpertPaynment(msg.sender, msg.value);
    }

    
    
    
    function activateContract(
        address _contract_expert)
        external
        payable 
        onlyOwner
        isValid(_contract_expert)
        isStatus(Status.Draft)
        setNextStage 
    { 
        emit ContractActivated(contract_expert, 
                               contract_start_date, 
                               contract_payment_amount);
        contract_expert = payable(_contract_expert); 
        depositExpertPayment(contract_payment_amount);
    }

    
    
    function killActiveContract() 
        external 
        onlyOwner
        isNotRefunded 
        nonReentrant 
        isStatus(Status.Active) 
    {
        contract_currentStatus = Status.Killed;
        refundClient();
    }


    
    
    /// 
    function approveWorkSubmitted() 
        public 
        onlyOwner
        werkNotApproved
        werkNotPaid
        isStatus(Status.Active) 
        nonReentrant
        setNextStage 
    {
        contract_werkApproved = true;
        contract_werkPaidOut = true;
        emit ReceivedPayout(contract_expert, 
                            contract_werkPaidOut, 
                            contract_werkApproved);
                            
        uint256 balance = address(this).balance;
        contract_expert.transfer(balance);     
    }

  
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}