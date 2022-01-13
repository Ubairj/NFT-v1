//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../service/Service.sol";

import "./Requirement.sol";

/// @notice a list of addresses.
contract RequirementsManager is Requirement, Initializable, Service {

    function initialize(address registry) public initializer {

        _setRegistry(registry);

    }

}
