// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;

interface IEventEmitter {
    event EventEmitterEvent(string indexed eventName, string indexed stringValue, uint256 numberValue);
    function emitEvent(string memory eventName, string memory stringValue) external;
}