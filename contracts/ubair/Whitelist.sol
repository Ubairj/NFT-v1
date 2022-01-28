Create Whitelist 
//remember to add MerkleWhitelist function to contract defination




abstract contract MerkleWhitelist {
    bytes32 internal _merkleRoot;
    function _setMerkleRoot(bytes32 merkleRoot_) internal virtual {
        _merkleRoot = merkleRoot_;
    }
    function isWhitelisted(address _receiver, bytes32[] memory proof_) public view returns (bool) {
        bytes32 _leaf = keccak256(abi.encodePacked(_receiver));
        for (uint256 i = 0; i < proof_.length; i++) {
            _leaf = _leaf < proof_[i] ? keccak256(abi.encodePacked(_leaf, proof_[i])) : keccak256(abi.encodePacked(proof_[i], _leaf));
        }
        return _leaf == _merkleRoot;
    }
	
    // Whitelist Mappings
    mapping(address => uint16) public addressToWhitelistMinted;
    mapping(address => uint16) public addressToPublicMinted;
	
	
	 // Whitelist Sale
    bool public whitelistSaleEnabled;
    uint256 public whitelistSaleTime;
    function setWhitelistSale(bool bool_, uint256 time_) external onlyOwner {
        whitelistSaleEnabled = bool_; whitelistSaleTime = time_; }
    modifier whitelistSale {
        require(whitelistSaleEnabled && block.timestamp >= whitelistSaleTime, "Whitelist sale not open yet!"); _; }
    function whitelistSaleIsEnabled() public view returns (bool) {
        return (whitelistSaleEnabled && block.timestamp >= whitelistSaleTime); }
		
		
	function whitelistMint(bytes32[] memory proof_) external payable onlySender whitelistSale {
        require(isWhitelisted(msg.sender, proof_), "You are not whitelisted!");
        require(addressToWhitelistMinted[msg.sender] == 0, "You have no whitelist mints remaining!");
        require(msg.value == salePrice_, "Invalid Value Sent!");
        require(maxTokens > supply, "No more remaining tokens!");

        addressToWhitelistMinted[msg.sender]++;
        supply++;

        _mint(msg.sender, __getTokenId());
        emit Mint(msg.sender, __getTokenId());
    }
	
	abstract contract MerkleWhitelist {
    bytes32 internal _merkleRoot;
    function _setMerkleRoot(bytes32 merkleRoot_) internal virtual {
        _merkleRoot = merkleRoot_;
    }
    function isWhitelisted(address _receiver, bytes32[] memory proof_) public view returns (bool) {
        bytes32 _leaf = keccak256(abi.encodePacked(_receiver));
        for (uint256 i = 0; i < proof_.length; i++) {
            _leaf = _leaf < proof_[i] ? keccak256(abi.encodePacked(_leaf, proof_[i])) : keccak256(abi.encodePacked(proof_[i], _leaf));
        }
        return _leaf == _merkleRoot;
    }
}