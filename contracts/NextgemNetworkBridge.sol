// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./bridge/ERC1155Bridge.sol";
import "./service/Service.sol";

/// @title NextgemNetworkBridge
/// @notice implements a metadata (off-chain data) manager
contract NextgemNetworkBridge is Service, ERC1155Bridge {

    function initialize(address registry) public override initializer {
        _setRegistry(registry);
        ERC1155Bridge.initialize(_serviceRegistry.get("NetworkBridge", "MultiToken"));
    }

}
