// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;

import "./IEventEmitter.sol";

contract EventEmitter is IEventEmitter {
    uint256 private _numberValue;
    constructor() {
        _emitEvent('constructor', 'constructor');
    }
    function _emitEvent(string memory eventName, string memory stringValue) internal {
        emit EventEmitterEvent(eventName, stringValue, _numberValue++);
    }
    function emitEvent(string memory eventName, string memory stringValue) external override {
        _emitEvent(eventName, stringValue);
    }
}