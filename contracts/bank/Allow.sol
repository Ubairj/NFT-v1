//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IAllow.sol";

// TODO fix comments, create tests

/// @notice tracks token allowances for accounts / tokens on behalf of a user
contract Allow is IAllow {

    mapping(address => mapping(address => mapping(uint256 => uint256))) internal _allowed;

    function _allow(address owner, address spender, uint256 id, uint256 value) internal {
        _allowed[owner][spender][id] = value;
    }

    /// @notice Get  all account tokens
    /// @param spender address of the account
    /// @param id address of the account
    /// @param value address of the account
    function allow(address spender, uint256 id, uint256 value) external virtual override {
        _allow(msg.sender, spender, id, value);
    }

    /// @notice Get get all account tokens
    /// @param owner address of the account
    /// @param spender address of the account
    /// @param id uint256 of the token index
    /// @return amount the account token record
    function _allowance(address owner, address spender, uint256 id)
    internal
    view
    returns (uint256 amount) {
        amount = _allowed[owner][spender][id];
    }

    /// @notice Get get all account tokens
    /// @param owner address of the account
    /// @param spender address of the account
    /// @param id uint256 of the token index
    /// @return amount the account token record
    function allowance(address owner, address spender, uint256 id)
    external
    virtual
    view
    override
    returns (uint256 amount) {
        amount = _allowance(owner, spender, id);
    }

}
