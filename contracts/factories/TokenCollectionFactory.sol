// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./Factory.sol";
import "../collection/TokenCollection.sol";
import "../service/Service.sol";

/// @notice the manager of fees
contract TokenCollectionFactory is Factory, Service, Initializable {

    mapping(uint256 => address) internal _isDeployed;

    // set the bytecode for the factory
    constructor() {

        _bytecode = type(TokenCollection).creationCode;

    }

    function initialize(address registry) public initializer {

        _setRegistry(registry);

    }

    /// @notice creates a new contract instance
    /// @return instanceOut the address of the new contract
    function create(string memory tcName)
    external
    returns (Instance memory instanceOut) {

        uint256 tcHash = collectionHash(msg.sender, tcName);

        require(_isDeployed[tcHash] == address(0), "collection already deployed");

        instanceOut = Factory(this).create(
            msg.sender, tcHash
        );
        _isDeployed[tcHash] = instanceOut.contractAddress;

    }

    /// @notice create a hash given owner and collection name
    function collectionHash(address owner, string memory collectionName) public pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked("TokenCollectionFactory", collectionName, owner)));

    }

    /// @notice get the collection address given hash or zero if not deployed
    function collectionByHash(uint256 tcHash) public view returns (address) {

        return _isDeployed[tcHash];

    }

}
