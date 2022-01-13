// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// the erc1155 base contract - the openzeppelin erc1155
import "../token/ERC1155.sol";
import "../utils/AddressSet.sol";
import "../utils/UInt256Set.sol";

import "../token/ProxyRegistry.sol";
import "../token/ERC1155Owners.sol";
import "../token/ERC1155Owned.sol";
import "../token/ERC1155TotalBalance.sol";


import "../interfaces/IMultiToken.sol";
import "../interfaces/IERC1155Mint.sol";
import "../interfaces/IERC1155Burn.sol";
import "../access/Controllable.sol";

/**
 * @title MultiToken
 * @notice the multitoken contract. All tokens are printed on this contract. The token has all the capabilities
 * of an erc1155 contract, plus network transfer, royallty tracking and assignment and other features.
 */
contract MultiToken is

ERC1155,
ProxyRegistryManager,
ERC1155Owners,
ERC1155Owned,
ERC1155TotalBalance,
IMultiToken,
Controllable
{

    // to work with token holder and held token lists
    using AddressSet for AddressSet.Set;
    using UInt256Set for UInt256Set.Set;

    uint256 private a;

    /**
     * @dev See {_setURI}.
     */
    function initialize(string memory uri_) public initializer {
        _setURI(uri_);
    }

    /// @notice Mint a specified amount the specified token hash to the specified receiver
    /// @param recipient the address of the receiver
    /// @param tokenHash the token id to mint
    /// @param amount the amount to mint
    function mint(
        address recipient,
        uint256 tokenHash,
        uint256 amount
    ) external override onlyController {
        _mint(recipient, tokenHash, amount, "");
    }

    /// @notice burn a specified amount of the specified token hash from the specified target
    /// @param target the address of the target
    /// @param tokenHash the token id to burn
    /// @param amount the amount to burn
    function burn(
        address target,
        uint256 tokenHash,
        uint256 amount
    ) external override onlyController {
        _burn(target, tokenHash, amount);
    }

    /// @notice override base functionality to check proxy registries for approvers
    /// @param _owner the owner address
    /// @param _operator the operator address
    /// @return isOperator true if the owner is an approver for the operator
    function isApprovedForAll(address _owner, address _operator)
    public
    view
    override
    returns (bool isOperator) {
        // check proxy whitelist
        bool _approved = _isApprovedForAll(_owner, _operator);
        return _approved || ERC1155.isApprovedForAll(_owner, _operator);
    }

    /// @notice See {IERC165-supportsInterface}. ERC165 implementor. identifies this contract as an ERC1155
    /// @param interfaceId the interface id to check
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155) returns (bool) {
        return
            interfaceId == type(IERC1155Owners).interfaceId ||
            interfaceId == type(IERC1155Owned).interfaceId ||
            interfaceId == type(IERC1155TotalBalance).interfaceId ||
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @notice override base functionality to process token transfers so as to populate token holders and held tokens lists
    /// @param operator the operator address
    /// @param from the address of the sender
    /// @param to the address of the receiver
    /// @param ids the token ids
    /// @param amounts the token amounts
    /// @param data the data
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        // let super process this first
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        //address royaltyPayee = _serviceRegistry.get("MultiToken", "RoyaltyPayee");

        // iterate through all ids in this transfer
        for (uint256 i = 0; i < ids.length; i++) {

            // if this is not a mint then remove the held token id from lists if
            // this is the last token if this type the sender owns
            if (from != address(0) && balanceOf(from, ids[i]) == amounts[i]) {
                // find and delete the token id from the token holders held tokens
                _owned[from].remove(ids[i]);
                _owners[ids[i]].remove(from);
            }

            // if this is not a burn and receiver does not yet own token then
            // add that account to the token for that id
            if (to != address(0) && balanceOf(to, ids[i]) == 0) {
                // insert the token id from the token holders held tokens\
                _owned[to].insert(ids[i]);
                _owners[ids[i]].insert(to);
            }

            // when a mint occurs, increment the total balance for that token id
            if (from == address(0)) {
                _totalBalances[uint256(ids[i])] =
                    _totalBalances[uint256(ids[i])] +
                    (amounts[i]);
            }
            // when a burn occurs, decrement the total balance for that token id
            if (to == address(0)) {
                _totalBalances[uint256(ids[i])] =
                    _totalBalances[uint256(ids[i])] -
                    (amounts[i]);
            }

        }
    }

}
