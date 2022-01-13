// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IERC1155MultiWrapper.sol";
import "../interfaces/IERC1155Mint.sol";
import "../interfaces/IERC1155Burn.sol";
import "../access/Controllable.sol";

import "../utils/AddressSet.sol";
import "../utils/UInt256Set.sol";
import "../utils/Strings.sol";

import "./ProxyRegistry.sol";
import "./ERC1155.sol";
import "./ERC1155Owners.sol";
import "./ERC1155Owned.sol";
import "./ERC1155TotalBalance.sol";
import "../royalties/ERC2981.sol";

interface ILegacyToken {

    function heldTokens(address holder)
        external
        view
        returns (uint256[] memory);

    function allHeldTokens(address holder, uint256 _idx)
        external
        view
        returns (uint256);

    function allHeldTokensLength(address holder)
        external
        view
        returns (uint256);

    function tokenHolders(uint256 _token)
        external
        view
        returns (address[] memory);

    function allTokenHolders(uint256 _token, uint256 _idx)
        external
        view
        returns (address);

    function allTokenHoldersLength(uint256 _token)
        external
        view
        returns (uint256);

}

contract ERC1155MultiWrapper is
ERC1155,
ERC2981,
ERC1155Owners,
ERC1155Owned,
ERC1155TotalBalance,
IERC1155Mint,
IERC1155Burn,
Controllable,
IERC1155MultiWrapper,
ProxyRegistryManager {

    using AddressSet for AddressSet.Set;
    using UInt256Set for UInt256Set.Set;
    using Strings for string;

    address[] internal _legacyTokens;

    mapping(uint256 => string) internal _uris;
    mapping(uint256 => mapping(address => uint256)) internal _convertedAmounts;


    function initialize(string memory _uri, address[] memory legacyTokens) public initializer {
        _addController(msg.sender);
        registryManagers[msg.sender] = true;
        _legacyTokens = legacyTokens;
        initialize_ERC1155(_uri);
        _mint(msg.sender, 1, 1, "");
    }


    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _balanceOf(address account, uint256 id) internal view returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        uint256 _bal = _balances[id][account];
        if(_bal == 0) {
            for(int256 i = int256(_legacyTokens.length) - 1; i >= 0; i--) {
                _bal = ERC1155(_legacyTokens[uint256(i)]).balanceOf(account, id);
                if(_bal != 0) {
                    break;
                }
            }
        }
        return _bal;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        return _balanceOf(account, id);
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        if(_balances[id][from] < amount && _convertedAmounts[id][from] == 0) {
            uint256 __bal = 0;
            for(int256 i = int256(_legacyTokens.length) - 1; i >= 0; i--) {
                __bal = ERC1155(_legacyTokens[uint256(i)]).balanceOf(from, id);
                if(__bal != 0) {
                    break;
                }
            }
            if(__bal != 0) {
                _convertedAmounts[id][from] = __bal;
                _mint(from, id, __bal, data);
            }
        }
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            if(_balances[id][from] < amount && _convertedAmounts[id][from] == 0) {
                uint256 __bal = 0;
                for(int256 j = int256(_legacyTokens.length) - 1; j >= 0; j--) {
                    __bal = ERC1155(_legacyTokens[uint256(j)]).balanceOf(from, id);
                    if(__bal != 0) {
                        break;
                    }
                }
                if(__bal != 0) {
                    _convertedAmounts[id][from] = __bal;
                    _mint(from, id, __bal, data);
                }
            }

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /// @notice Get all owned tokens
    /// @param account the owner
    /// @return ownedList all tokens for owner
    function owned(address account)
    external
    virtual
    view
    override
    returns (uint256[] memory ownedList) {

        // first compute the return array length which is the sum of all token lengths
        uint256 heldLens = _owned[account].keyList.length;
        for(uint256 i = 0; i < _legacyTokens.length; i++) {
            heldLens += ILegacyToken(_legacyTokens[i]).allHeldTokensLength(account);
        }

        // instanciate the return array
        ownedList = new uint256[](heldLens);

        // populate the return array with the owned token ids
        for(uint256 i = 0; i < _owned[account].keyList.length; i++) {
            ownedList[i] = _owned[account].keyList[i];
        }

        // record the offset into the array that we have populated
        uint256 offset = _owned[account].keyList.length;
        uint256 skip = 0; // how many tokens we have skipped

        // iterate over all tokens and add their ids to the return array
        for(uint256 i = 0; i < _legacyTokens.length; i++) {

            // get the held tokens length for the current token
            uint256 jlen = ILegacyToken(_legacyTokens[i]).allHeldTokensLength(account);

            // iterate over all held tokens and add them to the return array if valid
            for(uint256 j = 0; j < jlen; j++) {

                // get the token id and whether its already been converted
                uint256 ownedId = ILegacyToken(_legacyTokens[i]).allHeldTokens(account, j);
                bool converted = _convertedAmounts[ownedId][account] != 0;

                // if the token id is less than 2 or it has been converted, skip it
                if(ownedId < 2 || converted == true) {
                    skip++;
                    continue;
                }

                // add the token id to the return array
                ownedList[j + offset - skip] = ownedId;
            }

            // increment the offset by the number of tokens we have processed
            offset += jlen - skip;
            skip = 0;
        }

    }

    /// @param id the token id
    /// @return ownersList all token holders for id
    function ownersOf(uint256 id)
    external
    virtual
    view
    override
    returns (address[] memory ownersList) {

        // first compute the return array length which is the sum of all token lengths
        uint256 holdersLens = _owners[id].keyList.length;
        for(uint256 i = 0; i < _legacyTokens.length; i++) {
            holdersLens += ILegacyToken(_legacyTokens[i]).allTokenHoldersLength(id);
        }

        // instanciate the return array
        ownersList = new address[](holdersLens);

        // populate the return array with the owned token ids
        for(uint256 i = 0; i < _owners[id].keyList.length; i++) {
            ownersList[i] = _owners[id].keyList[i];
        }

        // record the offset into the array that we have populated
        uint256 offset = _owners[id].keyList.length;
        uint256 skip = 0; // how many tokens we have skipped

        // iterate over all tokens and add their ids to the return array
        for(uint256 i = 0; i < _legacyTokens.length; i++) {

            // get the held tokens length for the current token
            uint256 jlen = ILegacyToken(_legacyTokens[i]).allTokenHoldersLength(id);

            // iterate over all held tokens and add them to the return array if valid
            for(uint256 j = 0; j < jlen; j++) {

                // get the token id and whether its already been converted
                address hodler = ILegacyToken(_legacyTokens[i]).allTokenHolders(id, j);
                bool converted = _convertedAmounts[id][hodler] != 0;

                // if the token id is less than 2 or it has been converted, skip it
                if(converted == true) {
                    skip++;
                    continue;
                }

                // add the token id to the return array
                ownersList[j + offset - skip] = hodler;
            }

            // increment the offset by the number of tokens we have processed
            offset += jlen - skip;
            skip = 0;

        }

    }

    /**
     * @dev set the URI of the token. 0 for the global URI returned for tokens with no explicit URI.
     */
    function setUri(uint256 id, string memory _uri) public virtual {

        bool isAllowed = _controllers[msg.sender] == true || _owned[msg.sender].exists(id);
        require(isAllowed, "ERC1155: only controller or owner can set URI");
        if(id == 0) {
            _setURI(_uri);
        } else {
            _uris[id] = _uri;
        }

    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        if(_isApprovedForAll(account, operator)) return true;
        else return _operatorApprovals[account][operator];

    }

    /**
     * @dev Returns the metadata URI for this token type
     */
    function uri(uint256 _id)
        public
        view
        override(ERC1155)
        returns (string memory)
    {

        // the URI override is here to support IPFS addresses - we need to do the
        // id concat here because IPFS can't do it. This makes this call take a little
        // longer but the advantage is that the call returns an already-formed URI
        require(
            _totalBalances[_id] != 0,
            "NFTGemMultiToken#uri: NONEXISTENT_TOKEN"
        );

        string memory tokenUri = _uris[_id];
        if(bytes(tokenUri).length == 0) {
            tokenUri = _uri;
        }

        return
            Strings.strConcat(
                tokenUri,
                Strings.uint2str(_id)
            );

    }

    /// @notice burn tokens of specified amount from the specified address
    /// @param receiver the burn target
    /// @param tokenHash the token hash to burn
    /// @param amount the amount to burn
    function mint(
        address receiver,
        uint256 tokenHash,
        uint256 amount
    ) external override onlyController {

        _mint(receiver, tokenHash, amount, "");

    }


    /// @notice burn tokens of specified amount from the specified address
    /// @param target the burn target
    /// @param tokenHash the token hash to burn
    /// @param amount the amount to burn
    function burn(
        address target,
        uint256 tokenHash,
        uint256 amount
    ) external override onlyController {

        _burn(target, tokenHash, amount);

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
