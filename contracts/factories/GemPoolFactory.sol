// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./Factory.sol";
import "../staking/GemPool.sol";
import "../service/Service.sol";

import "../interfaces/IGemPool.sol";
import "../interfaces/IControllable.sol";

import "hardhat/console.sol";

/// @notice the manager of fees
contract GemPoolFactory is Factory, Service, Initializable {

    mapping(uint256 => address) internal _isDeployed;

    // set the bytecode for the factory
    constructor() {

        _bytecode = type(GemPool).creationCode;

    }

    function initialize(address registry) public initializer {

        _setRegistry(registry);

    }

    /// @notice creates a new contract instance
    /// @param gemPoolName the owner of the new contract
    /// @return instanceOut the address of the new contract
    function createGemPool(string memory gemPoolName)
    external
    returns (Instance memory instanceOut) {


        uint256 _hash = collectionHash(gemPoolName);
        require(_isDeployed[_hash] == address(0), "collection already deployed");
        instanceOut = Factory(this).create(
            msg.sender, _hash
        );
        GemPool(instanceOut.contractAddress).initialize(address(_serviceRegistry));
        IControllable(instanceOut.contractAddress).addController(msg.sender);
        _isDeployed[_hash] = instanceOut.contractAddress;

        console.log("sol isDeployed", _hash, _isDeployed[_hash]);

    }

    /// @notice create a hash given owner and collection name
    function collectionHash(string memory gemPoolName) public pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked("GemPoolFactory", gemPoolName)));

    }

    /// @notice get the collection address given hash or zero if not deployed
    function collectionByHash(uint256 tcHash) public view returns (address) {

        return _isDeployed[tcHash];

    }

}
