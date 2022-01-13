// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./JanusRegistry.sol";
import "../access/Controllable.sol";

/// @title NextgemServiceRegistry
/// @notice implements a metadata (off-chain data) manager
contract ServiceRegistry is JanusRegistry, Initializable, Controllable {

    /// @notice initializer. sets owner
    function initialize(address _owner) public initializer {
        _addController(_owner);
    }

    /// @notice add a new service to the list.
    /// @param name the manager address
    /// @param service the manager address
    function setServiceNamed(string memory face, string memory name, address service) external onlyController {
        _add(face, name, service);
    }

}
