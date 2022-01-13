//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../bank/Bank.sol";

import "../interfaces/IStakingPool.sol";

import "../interfaces/IEarned.sol";

// TODO implement

/// @notice a pool of tokens that users can deposit into and withdraw from
contract StakingPool is
IStakingPool,
IEarned,
Bank {

    // the settings struct for this staking pool
    StakingPoolSettings internal _settings;

    // allowed staked token id and earned token id
    TokenSource internal stakedToken_;
    TokenDefinition internal earnedToken_;

    // the amount of tokens in the pool
    mapping(address => mapping(uint256 => uint256)) internal _earnedBalances;

    /// @notice initialize the token pool with the multitoken address.
    /// @param __token the multitoken to print on
    /// @param settingsIn the settings for the pool
    /// @param _stakedToken the staked token source. either static or a collection
    /// @param _earnedToken the earned token definition
    function initialize(
        address __token,
        StakingPoolSettings memory settingsIn,
        TokenSource memory _stakedToken,
        TokenDefinition memory _earnedToken) public virtual {

        _token = __token;
        _settings = settingsIn;
        stakedToken_ = _stakedToken;
        earnedToken_ = _earnedToken;

    }

    /// @notice return the staked token for this pool
    /// @return _stakedToken the staked token for this pool
    function stakedToken() external virtual view override returns (TokenSource memory _stakedToken) {

        return stakedToken_;

    }

    /// @notice return the earned token for this pool
    /// @return _earnedToken the earned token for this pool
    function earnedToken(uint256) external virtual view override returns (TokenDefinition memory _earnedToken) {

        return earnedToken_;

    }

    /// @notice not implemented in this contract
    function earnedBalance(uint256, uint256) external virtual view override returns (uint256 _result) {

        _result = 0;
        require(false, "not implemented");

    }

    /// @notice collect earnings for the current user - calls submitClainm
    /// @param id the id of the clasim to collect
    function collectEarnings(uint256, uint256 id) external virtual override {

    }

}
