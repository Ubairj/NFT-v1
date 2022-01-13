// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../requirements/RequirementsManager.sol";

/// @title BankDeployer
/// @notice this contract it used to deploy the components of the system. In order to endure the address is the same on all networks, we deploy using create2.
contract RequirementsManagerDeployer {

    // deployment made by this deployer
    mapping(uint256 => address) private deployments;

    // the currently deployed token
    address private _deployedToken;
    // the deployment controller
    bytes32 private _salt;
    // the deployment controller
    address private controller;

    /// @notice event to announce deploy
    /// @param deploymentSalt the salt used to deploy
    /// @param deployedAddress the deployed address
    event Deployed(uint256 deploymentSalt, address deployedAddress);

    /// @notice only authorized controllers shall pass
    modifier onlyDeployer() {
        require(msg.sender == controller, "not authorized for this call");
        _;
    }

    constructor() {
        controller = msg.sender;
    }

    /// @notice deploy the token contract
    /// @param amount the amount
    /// @param salt the input salt for create2
    function deploy(uint256 amount, uint256 salt) public onlyDeployer {
        bytes memory craetionCode = type(RequirementsManager).creationCode;
        address newAddress = computeAddress(bytes32(salt), keccak256(craetionCode));
        require(deployments[salt] != newAddress, "bytecode/salt already deployed");
        _deployedToken = c2(amount, salt, craetionCode);
        require(_deployedToken == newAddress, "Unexpected CREATE2 output!");
        _deployedToken = newAddress;
        deployments[salt] != newAddress;
        emit Deployed(salt, newAddress);
    }

    /// @notice get the deployed token address
    /// @return the deployed token address
    function deployedToken() public view returns(address) {
        return _deployedToken;
    }

    /// @dev perform a CREATE2 deploy
    /// @param amount the initial token amount to include in the new contract
    /// @param salt the salt to use for the new contract
    /// @param bytecode the code to deploy
    /// @return the address of the new contract
    function c2(
        uint256 amount,
        uint256 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        bytes32 salt_ = bytes32(salt);
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt_)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /// @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the `bytecodeHash` or `salt` will result in a new destination address.
    /// @param salt The salt to use for the CREATE2.
    /// @param bytecodeHash The hash of the contract's bytecode.
    /// @return deployedAddress The address where the contract will be stored.
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) public view returns (address deployedAddress) {
        return computeDeploymentAddress(salt, bytecodeHash, address(this));
    }

    /// @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
    /// @param salt The salt to use for the CREATE2.
    /// @param bytecodeHash The hash of the contract's bytecode.
    /// @param deployer The address of the deployer.
    /// @return deployedAddress The address where the contract will be stored.
    function computeDeploymentAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) public pure returns (address deployedAddress) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}
