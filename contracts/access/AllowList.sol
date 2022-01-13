//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IAllowList.sol";

// TODO comment, add tests

contract AllowList is IAllowList {

    mapping(address => bool)internal _allowed;

    function setAllowed(address addr, bool allowed) virtual external override {
        _allowed[addr] = allowed;
        emit AllowedSet(address(this), addr, allowed);
    }

    function isAllowed(address addr) external view override returns (bool) {
        return _allowed[addr];
    }

}
