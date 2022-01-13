// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./Factory.sol";
import "../staking/StakingPool.sol";
import "../service/Service.sol";

/// @notice the manager of fees
contract StakingPoolFactory is Factory, Service, Initializable {

    // set the bytecode for the factory
    constructor() {
        _bytecode = type(StakingPool).creationCode;
    }

    function initialize(address registry) public initializer {
        _setRegistry(registry);
    }

    /// @notice creates a new contract instance
    /// @param owner the owner of the new contract
    /// @param salt the salt to use for the new contract
    /// @return instanceOut the address of the new contract
    function create(address owner, uint256 salt)
    external override
    returns (Instance memory instanceOut) {

        instanceOut = Factory(this).create(owner, salt);

    }


}
