// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// the erc1155 base contract - the openzeppelin erc1155
import "../token/ERC1155.sol";
import "../royalties/ERC2981.sol";
import "../utils/AddressSet.sol";
import "../utils/UInt256Set.sol";

import "./ProxyRegistry.sol";
import "./ERC1155Owners.sol";
import "./ERC1155Owned.sol";
import "./ERC1155TotalBalance.sol";

import "../utils/PaymentForwarder.sol";

import "../interfaces/IMultiToken.sol";
import "../interfaces/IERC1155Mint.sol";
import "../interfaces/IERC1155Burn.sol";
import "../interfaces/IERC1155Multinetwork.sol";
import "../interfaces/IJanusRegistry.sol";
import "../interfaces/IERC1155Bridge.sol";

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
IERC1155Multinetwork,
IMultiToken,
ERC2981
{

    // the service registry controls everything. It tells all objects
    // what service address they are registered to, who the owner is,
    // and all other things that are good in the world.
    IJanusRegistry private _serviceRegistry;

    // to work with token holder and held token lists
    using AddressSet for AddressSet.Set;
    using UInt256Set for UInt256Set.Set;

    function initialize(address registry) public initializer {
        _serviceRegistry = IJanusRegistry(registry);
    }

    /// @notice only allow owner of the contract
    modifier onlyOwner() {
        require(_serviceRegistry.get("MultiToken", "owner") == msg.sender, "You shall not pass");
        _;
    }
    /// @notice only allow owner of the contract
    modifier onlyMinter() {
        require(_serviceRegistry.get("MultiToken", "MintingManager") == msg.sender, "You shall not pass");
        _;
    }

    /// @notice Mint a specified amount the specified token hash to the specified receiver
    /// @param recipient the address of the receiver
    /// @param tokenHash the token id to mint
    /// @param amount the amount to mint
    function mint(
        address recipient,
        uint256 tokenHash,
        uint256 amount
    ) external override onlyMinter {
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
    ) external override onlyMinter {
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
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return
            interfaceId == type(IERC1155Multinetwork).interfaceId ||
            interfaceId == type(IERC1155Owners).interfaceId ||
            interfaceId == type(IERC1155Owned).interfaceId ||
            interfaceId == type(IERC1155TotalBalance).interfaceId ||
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @notice perform a network token transfer. Transfer the specified quantity of the specified token hash to the destination address on the destination network.
    function networkTransferFrom(
        address from,
        address to,
        uint256 network,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external virtual override {

        address _bridge = _serviceRegistry.get("MultiToken", "NetworkBridge");
        require(_bridge != address(0), "No network bridge found");

        // call the network transfer on the bridge
        IERC1155Multinetwork(_bridge).networkTransferFrom(from, to, network, id, amount, data);

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

            // if(royaltyReceiversByHash[ids[i]] == address(0)) {
            //     address royaltyTarget;
            //     if(from == address(0)) {
            //         royaltyTarget = to;
            //     } else {

            //     }
            //     royaltyReceiversByHash[ids[i]] = _createPaymentForwarder(royaltyPayee, royaltyTarget);
            //     royaltyFeesByHash[ids[i]] = 2000;
            // }
        }
    }

    /// create a new payment forwarder contract using craete2. All deployed contracts in
    /// the system are deployed with create2 so that addresses are fully deterministic
    function _createPaymentForwarder(address _payee, address _receiver) internal returns (address) {

        address paymentForwarder;
        bytes memory bytecode = type(PaymentForwarder).creationCode;
        bytes32 salt = keccak256(abi.encodePacked("forwarder", address(this), _receiver));
        assembly {
            paymentForwarder := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        PaymentForwarder(payable(paymentForwarder)).initialize(_payee, _receiver);
        return paymentForwarder;

    }
}
