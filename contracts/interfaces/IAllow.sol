//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @notice a bank. allows deposits of any token and tracks balance by depositor and only allows withdraw from depositor or assigned agent, disallows negative balances.
interface IAllow {

    event Approved(address indexed owner, address spender, uint256 id, uint256 amount);

    /// @notice Get  all account tokens
    /// @param spender address of the account
    /// @param id address of the account
    /// @param amount address of the account
    function allow(address spender, uint256 id, uint256 amount) external;

    /// @notice Get get all account tokens
    /// @param owner address of the account
    /// @param spender address of the account
    /// @param id uint256 of the token index
    /// @return amount the account token record
    function allowance(address owner, address spender, uint256 id)
    external
    view
    returns (uint256 amount);

}
