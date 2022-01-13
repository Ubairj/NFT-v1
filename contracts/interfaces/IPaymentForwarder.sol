//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/// payment forwarder for splitting royalty payments. Forwards
/// incoming payments to two receivers, and also makes a controller
/// privileged to withdraw funds from the contract in case a send
/// fails and payments need to be retreived remotely. controller
/// is also privileged to change receiver2 in order to allow for
/// transferring royalties by receiver2. receiver1 is fixed and is
/// a system receiver.
interface IPaymentForwarder {

    /// withdraw the balance of the contract
    function withdraw() external;

    /// change receiver 2. Can only be performed by the controller
    function changeReceiver(address _newReceiver) external;

}
