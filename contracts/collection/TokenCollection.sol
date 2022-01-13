//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/ICollection.sol";
import "../interfaces/IERC1155.sol";
import "../interfaces/IERC1155Mint.sol";
import "../interfaces/IERC1155Burn.sol";
import "../interfaces/IJanusRegistry.sol";
import "../interfaces/ITokenMinter.sol";

import  "../service/Service.sol";
import  "../utils/UInt256Set.sol";
import  "../utils/AddressSet.sol";
import "../token/ERC1155Owned.sol";
import "../token/ERC1155Owners.sol";
import "../access/AllowList.sol";

///
/// @notice interface for a collection of tokens. lists members of collection,
/// @notice allows for querying of collection members, and for minting and burning of tokens.
///

contract TokenCollection is
Service,
ERC1155Owned,
ERC1155Owners,
ICollection,
IERC1155,
IERC1155Mint,
IERC1155Burn {

    using UInt256Set for UInt256Set.Set;
    using AddressSet for AddressSet.Set;

    // the tokens in this collection
    UInt256Set.Set internal _tokens;
    mapping(address => AddressSet.Set) internal _allowLists;

    /// @notice set the registry for this collection
    /// @param registry the registry
    function setRegistry(address registry) external virtual {
        if(address(_serviceRegistry) != address(0)) {
            address systemManager = IJanusRegistry(_serviceRegistry).get("TokenCollection", "SystemAdmin");
            require(systemManager == msg.sender, "not system admin");
        }
        _setRegistry(registry);
    }

    function itemHash(uint256 idIn) public pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked("TokenCollection", idIn)));
    }

    /// @notice returns whether the given item is a member of the collection
    /// @param token the token hash
    /// @return _member true if the token is a member of the collection, false otherwise
    function isMemberOf(uint256 token) external virtual view override returns (bool _member) {
        return _tokens.exists(token);
    }

    /// @notice returns all the tokens in the collection as an array
    /// @return _members the collection tokens
    function members() external virtual view override returns (uint256[] memory _members) {
        return _tokens.keyList;
    }

    /// @notice mint tokens of specified amount to the specified address
    /// @param recipient the mint target
    /// @param tokenHash the token hash to mint
    /// @param amount the amount to mint
    function mint(
        address recipient,
        uint256 tokenHash,
        uint256 amount
    ) external virtual override {
        address mintingManager = IJanusRegistry(_serviceRegistry).get("TokenCollection", "MintingManager");
        ITokenMinter(mintingManager).mint(recipient, uint256(uint160(address(this))), tokenHash, amount);
    }

    /// @notice burn tokens of specified amount from the specified address
    /// @param target the burn target
    /// @param tokenHash the token hash to burn
    /// @param amount the amount to burn
    function burn(
        address target,
        uint256 tokenHash,
        uint256 amount
    ) external virtual override {
        address mintingManager = IJanusRegistry(_serviceRegistry).get("TokenCollection", "MintingManager");
        ITokenMinter(mintingManager).burn(target, tokenHash, amount);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(ICollection).interfaceId;
    }

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view override returns (uint256) {
        address multiToken = IJanusRegistry(_serviceRegistry).get("TokenCollection", "MultiToken");
        require(multiToken != address(0), "MultiToken not found");
        return IERC1155(multiToken).balanceOf(account, id);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        override
        returns (uint256[] memory) {
        address multiToken = IJanusRegistry(_serviceRegistry).get("TokenCollection", "MultiToken");
        require(multiToken != address(0), "MultiToken not found");
        return IERC1155(multiToken).balanceOfBatch(accounts, ids);
    }

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function _setApprovalForAll(address operator, bool approved) internal {
        if(!_allowLists[msg.sender].exists(operator)) {
            if(approved) _allowLists[msg.sender].insert(operator);
        } else {
            if(!approved) _allowLists[msg.sender].remove(operator);
        }
    }

    function setApprovalForAll(address operator, bool approved) external override {
        _setApprovalForAll(operator, approved);
    }

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view  override returns (bool) {
        return _allowLists[account].exists(operator);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external override {
        require(to != address(0), "invalid address");
        require(amount > 0, "invalid amount");
        address multiToken = IJanusRegistry(_serviceRegistry).get("TokenCollection", "MultiToken");
        require(IERC1155(multiToken).balanceOf(from, id) >= amount, "insufficient balance");
        IERC1155(multiToken).safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external override {
        require(to != address(0), "invalid address");
        require(amounts.length > 0, "invalid amounts");
        address multiToken = IJanusRegistry(_serviceRegistry).get("TokenCollection", "MultiToken");
        IERC1155(multiToken).safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}

