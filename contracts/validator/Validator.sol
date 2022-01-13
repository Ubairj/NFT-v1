//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IERC1155Validator.sol";

///
/// @notice implements validator methods
///
contract Validator is IERC1155Validator {

    // mapping that maintains the validator status of "all" addresses
    mapping(address => bool) private _addressToValidator;

    // amount of validators on the network this contract has been deployed to
    uint256 _validatorCount = 0;

    /// @notice only the validator may call
    modifier onlyValidator() {
        require(_addressToValidator[msg.sender], "Bridge: Sender is no bridge validator.");
        _;
    }

    /// register as a validator on the network. registration requires a
    /// registration bond

    /// @notice register a new validator that can validate transfers
    /// @param validatorAddress address of the validator
    function register(address validatorAddress) external payable override {
        // todo: add validator bond payment
        // todo: should everybody be able to register as validator?
        require(!_addressToValidator[validatorAddress], "Bridge: Address is already a validator.");
        _addressToValidator[validatorAddress] = true;
        _validatorCount = _validatorCount + 1;
        emit IERC1155Validator.ValidatorRegistered(validatorAddress, 0, _validatorCount);
    }

    /// @notice unregister a validator from the bridge
    /// @param validatorAddress address of the validator
    function unregister(address validatorAddress) external override {
        // todo: who should be able to unregister a validor?
        // todo: can you only unregister yourself?
        require(_addressToValidator[validatorAddress], "Bridge: Address is not a validator.");
        _addressToValidator[validatorAddress] = false;
        _validatorCount = _validatorCount - 1;
        emit IERC1155Validator.ValidatorUnregistered(validatorAddress, _validatorCount);
        // todo: what happens to the validator bonds when the validator is unregistered?
    }

    /// @notice returns whether or not this address is registered as a validator
    /// @param _validator address of the validator
    /// @return whether or not this address is registered as a validator
    function registered(address _validator) external view override returns (bool) {}

    /// @notice get the validator data object
    /// @param _validator address of the validator
    /// @return validator data object
    function validator(address _validator) external view override returns (Validator memory) {}

    /// @notice get the required bond amount to be a validator. This bond must be includeed with registration
    /// @return the required bond amount to be a validator
    function bondAmount() external view override returns (uint256) {}

}
