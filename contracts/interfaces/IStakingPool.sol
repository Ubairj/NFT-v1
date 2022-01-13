//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IToken.sol";

/// @notice check the balance of earnings and collect earnings
interface IStakingPool is IToken {

    /// @notice staking pool settings - used to confignure a staking pool
    struct StakingPoolSettings {

        // the host token
        address token;

        // min and max token amounts to stake
        uint256 minStakeAmount;
        uint256 maxStakeAmount;

        // minimum stake duration in blocks
        uint256 minStakeDuration;

        // earn rate for this staking pool
        uint256 earnRatePerPeriod;
        uint256 earnPeriodBlocks;
        bool payPartialBlocks;

        // minting
        bool mintEarnedToken;
        uint256 maxTotalEarnedAmount;

    }

    function stakedToken() external view returns (TokenSource memory _stakedToken);

}
