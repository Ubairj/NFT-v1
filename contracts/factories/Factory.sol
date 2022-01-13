// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/utils/Create2.sol";

import "../interfaces/IFactory.sol";

import "../utils/AddressSet.sol";

import "./FactorySet.sol";

/// @notice the manager of fees
abstract contract Factory is IFactory {

    using FactorySet for IFactory.FactoryInstanceSet;

    bytes internal _bytecode;

    FactorySettings internal _settings;

    /// @notice returns the contract bytecode
    /// @return _instances the contract bytecode
    function contractBytes() external virtual view override returns (bytes memory _instances) {
        return _bytecode;
    }

    /// @notice returns the contract instances as a list of instances
    /// @return _instances the contract instances
    function instances() external virtual view override returns (Instance[] memory _instances) {
        return _settings.data.instances.valueList;
    }

    /// @notice creates a new contract instance
    /// @param owner the owner of the new contract
    /// @param salt the salt to use for the new contract
    /// @return instanceOut the address of the new contract
    function create(address owner, uint256 salt)
    external virtual override
    returns (Instance memory instanceOut) {

        // use create2 to deploy the gem pool contract
        address _out  = payable(Create2.deploy(0, bytes32(salt), _bytecode));

        // set the owner of this element. Elements are owned by the account that creates them.
        IFactoryElement(_out).factoryCreated(owner);

        // create the new instance
        instanceOut = Instance(address(this), _out);

        // insert the new instance in the instance set
        _settings.data.instances.insert(instanceOut);

    }

    /// @notice returns the contract instance at the given index
    /// @param idx the index of the instance to return
    /// @return instance the instance at the given index
    function at(uint256 idx) external view override returns (Instance memory instance) {
        instance = _settings.data.instances.valueList[idx];
    }

    /// @notice returns the length of the already-created contracts list
    /// @return _length the length of the list
    function count() external view override returns (uint256 _length) {
        _length = _settings.data.instances.count();
    }
}
