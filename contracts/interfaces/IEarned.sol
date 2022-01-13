//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IToken.sol";

/// @notice check the balance of earnings and collect earnings
interface IEarned is IToken {

    /// @notice get the earned token definition
    /// @return _earnedToken the gem pool's current earned token. returns a token definiton
    function earnedToken(uint256 poolId) external view returns (TokenDefinition memory  _earnedToken);

    /// @notice get the earnings balance
    function earnedBalance(uint256 poolId, uint256 id) external view returns (uint256);

    /// @notice get the earnings balance
    function collectEarnings(uint256 poolId, uint256 id) external;

    /// @notice emitted when a token is added to the collection
    event EarningsCollected (
        address indexed account,
        uint256 indexed id,
        uint256 indexed amount
    );

}
