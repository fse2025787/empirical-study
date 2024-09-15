// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// 

pragma solidity ^0.8.4;



interface IRebelsRenderer is IERC165 {
  function tokenURI(uint256 id) external view returns (string memory);
  function beforeTokenTransfer(address from, address to, uint256 id) external;
}
// 

pragma solidity ^0.8.4;





contract FixedURIRenderer is IRebelsRenderer, ERC165 {
  string public uri;

  constructor(string memory uri_) {
    uri = uri_;
  }

  function tokenURI(uint256) external view override returns (string memory) {
    return uri;
  }

  function beforeTokenTransfer(
    address from,
    address to,
    uint256 id
  ) external pure override {}

  function supportsInterface(bytes4 interfaceId) public view
      override(ERC165, IERC165) returns (bool) {
    return interfaceId == type(IRebelsRenderer).interfaceId ||
           super.supportsInterface(interfaceId);
  }
}
