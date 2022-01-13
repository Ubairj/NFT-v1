//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IEarned.sol";
import "./IToken.sol";

/// @notice a mutation pool accepts ether and a token and then mutates one or more attributes of the token over time.
interface IMutationPool is IToken {

    /// @notice the action taken by the mutation directive
    enum MutationDirectiveAction {
        Add, Subtract, Multiply, Divide, Set, NoOp
    }

    /// @notice a directive tells the mutation pool how to mutate the token.
    struct MutationDirective {
        MutationDirectiveAction action;
        string attribute;
        uint256 value;
        bool mustExist;
    }

    /// @notice represents a single deposit into the mutation pool.
    struct MutationPoolDeposit {
        uint256 id;
        uint256 tokenHash;
        address depositor;
        uint256 quantity;
        uint256 etherAmount;
        uint256 depositBlock;
        uint256 depositTimestamp;
        uint256 withdrawBlock;
        uint256 withdrawTimestamp;
    }

    /// @notice the mutation pool's data including settings and deposits
    struct MutationPoolData {

        MutationDepositSet deposits;
        mapping(address => MutationDepositSet) depositsByDepositors;
        mapping(address => mapping(uint256 => uint256)) allowances;

    }

    /// @notice staking pool settings - used to confignure a staking pool
    struct MutationPoolSettings {

        // mutable data
        MutationPoolData data;

        // the host token
        address token;

        // min token amount to stake
        uint256 minStakeAmount;

        // max token amount to stake
        uint256 maxStakeAmount;

        // minimum stake duration in blocks
        uint256 minStakeDuration;

        // earn rate for this staking pool
        uint256 earnRatePerPeriod;

        // block length of period
        uint256 earnPeriodBlocks;

        // credit partial blocks
        bool creditPartialBlocks;

        // the directives that tell the pool how to change the token attributes
        MutationDirective[] directives;

    }

    /// @notice a set of requirements. used for random access
    struct MutationDepositSet {
        mapping(uint256 => uint256) keyPointers;
        uint256[] keyList;
        MutationPoolDeposit[] valueList;
    }

    /// @notice emitted when a mutation pool deposit is made
    event MutationPoolDeposited(address depositor, MutationPoolDeposit deposit);

    /// @notice emitted when a mutation pool withdrawal is withdrawn
    event MutationPoolWithdrew(address depositor, MutationPoolDeposit deposit);

    /// @notice return a list of all mutation pool directives.
    function directives() external view returns (MutationDirective[] memory _directives);

    /// @notice return a list of deposits for this mutation pool fpr the given depositor
    function deposits() external view returns (MutationPoolDeposit[] memory _deposits);

    /// @notice return a list of deposits for this mutation pool fpr the given depositor
    function depositsByDepositor(address _depositor) external view returns (MutationPoolDeposit[] memory _deposits);

}
