//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./Bank.sol";
import "./Allow.sol";

import "../flashloan/FlashLender.sol";
import "../interfaces/ITransfer.sol";

// TODO write tests (overriding contracts)

/// @notice a bank. allows deposits of any token and tracks balance by depositor and only allows withdraw from depositor or assigned agent, disallows negative balances.
contract LendingBank is Bank, Allow, FlashLender, ITransfer {

    /// @param to address of the account
    /// @param id id of the token, 0 for ether, or address or erc20 token
    /// @param amount address of the account
    function transfer(address to, uint256 id, uint256 amount) external virtual override {

        _withdrawTo(address(this), to, id, amount);
        // emit an event about the withdraw
        emit Transfer(address(this), to, id, amount);

    }

    /// @notice transfer funds from msg.sender to recipient
    /// @param from address of the sender account
    /// @param to address of the recipient account
    /// @param id id of the token, 0 for ether, or address or erc20 token
    /// @param amount address of the account
    function transferFrom(address from, address to, uint256 id, uint256 amount) external virtual override {

        if(msg.sender != from) {
            uint256 allowance = _allowance(from, msg.sender, id);
            if(allowance < amount) {
                revert("not enough allowance or sender is not the owner");
            }
            _allow(from, msg.sender, id, allowance - amount);
        }

        _withdrawTo(from, to, id, amount);
        // emit an event about the withdraw
        emit Transfer(from, to, id, amount);

    }

}
