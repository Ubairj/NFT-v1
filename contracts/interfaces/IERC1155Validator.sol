// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// manage the network bridge validators
interface IERC1155Validator {

    /// The validator structure. contains address and bond information
    struct Validator {
        address operatorAddress;
        address validatorAddress;
        uint256 bondedAmount;
    }

    /// emitted when a validator is registered on the network
    event ValidatorRegistered(
        address indexed _validator,
        uint256 bondAmount,
        uint256 newTotalValidators
    );

    /// emitted when a validator is unregistered from the network
    event ValidatorUnregistered(
        address indexed _validator,
        uint256 newTotalValidators
    );

    /// emitted when a validator's status is updated
    event Updated(address indexed _validator, Validator validatorData);

    /// emitted when a validator is penalized for failing to perform their task
    event Penalized(address indexed _validator, uint256 penalty);

    /// emitted when a validator has been banned from the network
    event Banned(address indexed _validator);

    /// register as a validator on the network. registration requires a
    /// registration bond
    function register(address _validator)
        external payable;

    /// unregister an active validator from the network and receive the input bond back
    function unregister(address _validator)
        external;

    /// get the required bond amount to be a validator
    function registered(address _validator)
        external
        view
        returns (bool);

    /// get the validator data object
    function validator(address _validator)
        external
        view
        returns (Validator memory);

    /// get the required bond amount to be a validator
    function bondAmount()
        external
        view
        returns (uint256);

}

