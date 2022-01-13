// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./bank/Bank.sol";
import "./interfaces/IJanusRegistry.sol";

/// @title MetadataManager
/// @notice implements a metadata (off-chain data) manager
contract NextgemBank is Bank, Initializable {

    // the service registry controls everything. It tells all objects
    // what service address they are registered to, who the owner is,
    // and all other things that are good in the world.
    IJanusRegistry private _serviceRegistry;

    function initialize(address registry) public initializer {
        _serviceRegistry = IJanusRegistry(registry);
    }

}
