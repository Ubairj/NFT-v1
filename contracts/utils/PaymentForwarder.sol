
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../interfaces/IPaymentForwarder.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// payment forwarder for splitting royalty payments. Forwards
/// incoming payments to two receivers, and also makes a controller
/// privileged to withdraw funds from the contract in case a send
/// fails and payments need to be retreived remotely. controller
/// is also privileged to change receiver2 in order to allow for
/// transferring royalties by receiver2. receiver1 is fixed and is
/// a system receiver.
contract PaymentForwarder is IPaymentForwarder, Initializable {
    address private controller;
    address private receiver1;
    address private receiver2;
    /// constructor. both receivers must be passed on contract creation.
    constructor() {
        controller = msg.sender;
    }
    /// Initializer since we deploy using create2
    function initialize(address _receiver1, address _receiver2) public initializer {
        receiver1 = _receiver1;
        receiver2 = _receiver2;
    }
    /// receive method for the contract. splits payment into 2
    /// equal parts - 2 satoshi and forwards each payment
    receive() external payable {
        payable(receiver1).transfer((msg.value / 2) - 1);
        payable(receiver2).transfer((msg.value / 2) - 1);
    }
    /// withdraw the balance of the contract
    function withdraw() external override {
        require(msg.sender == controller, "not allowed");
        payable(msg.sender).transfer(address(this).balance);
    }
    /// change receiver 2. Can only be performed by the controller
    function changeReceiver(address _newReceiver) external override {
        require(msg.sender == controller, "not authorized");
        receiver2 = _newReceiver;
    }
}
