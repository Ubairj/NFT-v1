//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IMutationPool.sol";
import "../interfaces/IBank.sol";

import "./MutationPoolLib.sol";
import "./MutationPoolSet.sol";

/// @notice a mutation pool accepts ether and a token and then mutates one or more attributes of the token over time.
contract MutationPool is IMutationPool, IBank {

    using MutationPoolLib for IMutationPool.MutationPoolSettings;
    using MutationPoolSet for IMutationPool.MutationDepositSet;

    MutationPoolSettings internal _settings;

    /// @notice return a list of all mutation pool directives.
    function directives() external virtual view override returns (MutationDirective[] memory _directives) {

        _directives = _settings.directives;

    }

    /// @notice return a list of deposits for this mutation pool fpr the given depositor
    function depositsByDepositor(address _depositor) external virtual view override returns (MutationPoolDeposit[] memory _deposits) {

        _deposits = _settings.data.depositsByDepositors[_depositor].valueList;

    }

    function _createKey(IMutationPool.MutationPoolDeposit memory req) internal view returns(uint256 _hash) {

        _hash = uint256(
            keccak256(abi.encodePacked(
                req.depositor,
                req.tokenHash,
                req.quantity,
                req.depositTimestamp,
                req.etherAmount,
                block.timestamp
            ))
        );

    }

    /// @notice return a list of deposits for this mutation pool fpr the given depositor
    function deposits() external view override returns (MutationPoolDeposit[] memory _deposits) {

        _deposits = _settings.data.deposits.valueList;

    }

    /// @notice deposit tokens into the pool
    /// @param id the token id to deposit
    /// @param quantity the amount of tokens to deposit
    function deposit(uint256 id, uint256 quantity) external virtual payable override {

        // create the deposit record and assign a new key to it
        MutationPoolDeposit memory _mpd = MutationPoolDeposit(0, id, msg.sender, quantity, msg.value, block.number, block.timestamp, 0, 0);
        _mpd.id = _createKey(_mpd);

        // add to the deposits by depositor index
        _settings.data.deposits.insert(_mpd);
        _settings.data.depositsByDepositors[msg.sender].insert(_mpd);

    }

    /// @notice deposit tokens into the pool
    /// @param account the source account
    /// @param id the token id to deposit
    /// @param quantity the amount of tokens to deposit
    function depositFrom(address account, uint256 id, uint256 quantity) external virtual payable override {

        MutationPoolDeposit memory _mpd = MutationPoolDeposit(0, id, account, quantity, msg.value, block.number, block.timestamp, 0, 0);
        _mpd.id = _createKey(_mpd);

        // add to the deposits by depositor index
        _settings.data.deposits.insert(_mpd);
        _settings.data.depositsByDepositors[msg.sender].insert(_mpd);

    }

    /// @notice withdraw deposit with id from the pool
    /// @param id the token id to withdraw
    function withdraw(uint256 id, uint256) external virtual override {

        _settings.data.deposits.removeAt(id);
        _settings.data.depositsByDepositors[msg.sender].removeAt(id);

    }

    /// @notice get the deposited amount of tokens with id
    /// @param id the token id to get the amount of
    /// @return the amount of tokens with id
    function balance(address, uint256 id) external virtual view override returns (uint256) {

    }

}
