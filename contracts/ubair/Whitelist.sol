//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IERC1155Mint.sol";

//Create Whitelist
//remember to add MerkleWhitelist function to contract defination

abstract contract MerkleWhitelist {

    bytes32 internal _merkleRoot;
    uint256 internal supply;
    address internal tokenAddress;

    // Whitelist Mappings
    mapping(address => uint16) public addressToWhitelistMinted;
    mapping(address => uint16) public addressToPublicMinted;

	 // Whitelist Sale
    bool public whitelistSaleEnabled;
    uint256 public whitelistSaleTime;

    /// @notice event emitted when tokens are minted
    event MinterMinted(
        address target,
        uint256 tokenHash,
        uint256 amount
    );

    /// @notice set the Merkle root of the whitelist
    function _setMerkleRoot(bytes32 merkleRoot_) internal virtual {

        _merkleRoot = merkleRoot_;

    }

    /// @notice return whether an address is whitelisted
    function isWhitelisted(address _receiver, bytes32[] memory proof_) public view returns (bool) {

        bytes32 _leaf = keccak256(abi.encodePacked(_receiver));
        for (uint256 i = 0; i < proof_.length; i++) {
            _leaf = _leaf < proof_[i]
                ? keccak256(abi.encodePacked(_leaf, proof_[i]))
                : keccak256(abi.encodePacked(proof_[i], _leaf));
        }
        return _leaf == _merkleRoot;

    }

    /// @notice set the enabled state of the whitelist sale
    function setWhitelistSale(bool bool_, uint256 time_) internal {

        whitelistSaleEnabled = bool_;
        whitelistSaleTime = time_;

    }

    /// @notice enforce the enabled state of the whitelist sale
    modifier whitelistSale {

        require(whitelistSaleEnabled && block.timestamp >= whitelistSaleTime, "Whitelist sale not open yet!");
        _;

    }

    /// @notice get the enabled state of the whitelist sale
    function whitelistSaleIsEnabled() public view returns (bool) {

        return (whitelistSaleEnabled && block.timestamp >= whitelistSaleTime);

    }

    /// @notice get the enabled state of the whitelist sale
	function whitelistMint(uint256 tokenHash, bytes32[] memory proof_, uint256 quantity) external payable whitelistSale {

        require(isWhitelisted(msg.sender, proof_), "You are not whitelisted!");
        require(addressToWhitelistMinted[msg.sender] == 0, "You have no whitelist mints remaining!");
        require(msg.value == _salePrice(tokenHash), "Invalid Value Sent!");
        require(_maxTokens(tokenHash) > supply, "No more remaining tokens!");
        require(quantity <= 3, "Too many mints!");

        addressToWhitelistMinted[msg.sender]++;
        supply++;

        IERC1155Mint(tokenAddress).mint(msg.sender, tokenHash, quantity);
        emit MinterMinted(msg.sender, tokenHash, quantity);

    }

    /// @notice ale price
    function _salePrice(uint256 price) internal virtual returns(uint256);

    /// @notice max tokens
    function _maxTokens(uint256 price) internal virtual returns(uint256);

}
