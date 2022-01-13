// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IERC1155Bridge.sol";

import "../interfaces/IERC1155Validator.sol";

/**
 * This contraxt implements the ERC1155 token bridge. The contract can receive
 * an NFT, burn an NFT, or generate an NFT. An instance of this contract is
 * deployed on every supported network
 */
contract ERC1155Bridge is IERC1155Bridge, Initializable {

    // reference to the next gem token on the chain this bridge contract is running
    address private token_;

    // mapping that maintains the receipt id to the corresponding transfer request
    mapping(uint256 => NetworkTransferRequest) private transferRequests;

    /// @notice only the validator shall pass
    modifier onlyValidator() {
        _;
    }

    /// @notice initialize the bridge with token information
    function initialize(address _token) public virtual initializer {
        token_ = _token;
    }

    /// @notice the token this bridge works with
    /// @return the address of the token this bridge works with
    function token() external view override returns (address
    ) {
        return token_;
    }

    /// @notice start the transfer of an NFT from one network/address to another. Called on the receiving network by the bridge contract
    /// @param id the transfer id
    /// @param request the network transfer request data
    function transfer(
        uint256 id,
        NetworkTransferRequest memory request
    ) external override onlyValidator {
        require(_validRequest(request), "Request for transfer is invalid");
        transferRequests[id] = request;
        // emit a network transfer started event
        emit NetworkTransferStarted(id, request);
    }

    /// @notice confirm the transfer of an NFT from one network/address to another. Called on the originating network by the bridge contract. This burns the banked source NFT being transferred
    /// @param id the transfer id
    function confirm(uint256 id) external override {
        require(_validRequest(transferRequests[id]), "Request for confirm is invalid");
        // TODO: burn the transfer source NFT
        delete transferRequests[id];
        // emit a network transfer confirmed event
        emit NetworkTransferConfirmed(id, transferRequests[id]);
    }

    /// @notice cancel the pending transfer. Can only be called x blocks after transfer initiation. Called by transfer requestor. Returns banked NFT to sender  and cancels the transfer
    /// @param id the transfer id
    function cancel(uint256 id) external override {
        // TODO: add a constant to the contract that defines the number of blocks after transfer initiation that the transfer can be cancelled
        // TODO: check if the request is valid
        // TODO: return the transfer source NFT to the sender
        // emit a network transfer cancelled event
        emit NetworkTransferCancelled(id, transferRequests[id]);
        require(_validRequest(transferRequests[id]), "Request for cancel is invalid");
    }

    function _validRequest(NetworkTransferRequest memory) internal pure  returns(bool) {
        // data and status is not checked if non 0
        return true; //req.id > 0 && req.from > 0 && req.to > 0 && req.network > 0 && req.token > 0 && req.amount > 0;
    }

    /// @notice get the transfer request data
    /// @param id the transfer id
    function get(uint256 id) external view override returns (NetworkTransferRequest memory) {
        return transferRequests[id];
    }

    ///  perform a network transfer operation. transfers the NFT from the user to the contract, then initiates a network transfer by emitting the transfer event
    function networkTransferFrom(
        address from,
        address to,
        uint256 network,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external virtual override {
        // TODO: implement
    }
}
