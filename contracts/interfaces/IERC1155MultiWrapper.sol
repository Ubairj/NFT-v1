//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// @notice a bank. allows deposits of any token and tracks balance by depositor and only allows withdraw from depositor or assigned agent, disallows negative balances.
interface IERC1155MultiWrapper {

    /// @notice event emitted when tokens are minted
    event TokenConverted(
        address target,
        uint256 tokenHash,
        uint256 amount
    );

}

