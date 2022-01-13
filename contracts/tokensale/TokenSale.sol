// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../token/TokenDefinitions.sol";

import "../utils/ChainId.sol";

import "../token/ERC1155Owned.sol";

import "../token/ERC1155Owners.sol";

import "./PurchaseRecordList.sol";

import "./TokenPrice.sol";

import "../interfaces/ITokenSale.sol";

import "../interfaces/ICollection.sol";

contract TokenSale is
ITokenSale, // token sale interface
TokenDefinitions, // implements a container with token definitions in it
PurchaseRecordList, // implements a list of purchase records
TokenPrice, // implement a token price that can rise over time
ICollection, // implements a collection of tokens
ERC1155Owned,
ERC1155Owners,
ChainId { // returns the chain id

    using UInt256Set for UInt256Set.Set;

    // token sale settings
    TokenSaleSettings internal _settings;

    // is token sale initiallzed
    bool internal tokenSaleInitialized;
    // is token sale open
    bool internal tokenSaleOpen;
    // total purchased tokens
    uint256 internal totalPurchased;

    /// @notice intialize the contract. should be called by overriding contract
    /// @param tokenSaleInit struct with tokensale data
    function initTokenSale(
        ITokenSale.TokenSaleSettings memory tokenSaleInit
    ) internal {
        // sanity check input values
        require(
            tokenSaleInit.token != address(0),
            "Multitoken address must be set"
        );
        require(tokenSaleInit.initialPrice.price != 0, "Price must be set");
        // set settings object
        _settings = tokenSaleInit;
        _tokenPrice = tokenSaleInit.initialPrice;
        _settings.contractAddress = address(this);
        tokenSaleInitialized = true;
    }

    /// @notice get whether the contract is initialized
    /// @return inited inited
    function isTokenSaleInitialized()
    external
    view
    returns (bool inited) {
        inited = tokenSaleInitialized;
    }


    /// @notice Called to purchase some quantity of a token
    /// @param receiver - the address of the account receiving the item
    /// @param quantity - the seed
    function purchase(address receiver, uint256 quantity)
    external
    virtual
    payable
    override
    returns (PurchaseRecord memory minting) {

        // sanity check the purchase
        require(tokenSaleOpen == true, "The token seller is closed");
        // make sure there are still tokens to purchase
        require(
            totalPurchased < _settings.maxQuantity,
            "The maximum amount of tokens has been bought."
        );
        // make sure enough funds are attached to the transaction
        require(
            msg.value >= _tokenPrice.price * quantity,
            "Insufficient base currency"
        );
        // make sure the max qty per sale is not exceeded
        require(
            _settings.maxQuantityPerSale == 0 || (_settings.maxQuantityPerSale > 1 && quantity <= _settings.maxQuantityPerSale),
            "Amount exceeds maximum buy amount"
        );
        // make sure max qty per account is not exceeded
        require(
            _settings.maxQuantityPerSale == 0 || (_settings.maxQuantityPerSale > 0 &&
            quantity <= _settings.maxQuantityPerAccount - _owned[receiver].count()),
            "Amount exceeds maximum buy total"
        );
        // make sure token sale is started
        require(
            block.timestamp >= _settings.startTime ||
                _settings.startTime == 0,
            "The sale has not started yet"
        );
        // make sure token sale is not over
        require(
            block.timestamp <= _settings.endTime ||
                _settings.endTime == 0,
            "The sale has ended"
        );

        // request (mint) the tokens. This method must be overridden
        uint256 tokenHash = _request(
            receiver,
            _settings.tokenHash,
            quantity
        );

        // increase total bought
        totalPurchased += quantity;

        // add account token to the account token list
        _addOwned(receiver, tokenHash);
        _addOwner(tokenHash, receiver);

        // create a purchase record
        PurchaseRecord memory pr = PurchaseRecord(
            _settings.token,
            receiver,
            tokenHash,
            0,
            _getChainID(),
            quantity,
            block.number,
            block.timestamp
        );

        // add the purchase record to the list and record the numbering
        pr.numbering = _addPurchaseRecord(pr);

        // emit a message about the purchase
        emit TokenPurchased(
            _settings,
            pr
        );

        // increase the purchase price if it's not fixed
        _increasePrice();

        // return the amount of tokens that were bought
        return pr;
    }

    /// @notice request some quantity of a token. This method must be overridden. Implementers may either mint on demand or distribute pre-minted tokens.
    /// @param _tokenHashIn the hash of the token
    /// @return _tokenHashOut the hash of the minted token
    function _request(
        address,
        uint256 _tokenHashIn,
        uint256
    )
    internal
    virtual
    returns (uint256 _tokenHashOut) {
        /// TODO: if tokenHashIn is 0 autocreate a hash
        _tokenHashOut = _tokenHashIn;
    }

    /// @dev Request tokens from the token provider.
    /// @param _recipient The address of the token receiver.
    /// @param quantity The amount of erc1155 tokens to buy.
    /// @return _tokenHashOut The amount of erc1155 tokens that were requested.
    function request(address _recipient, uint256 quantity)
        external
        virtual
        override
        returns (uint256 _tokenHashOut) {
        require(
            totalPurchased < _settings.maxQuantity,
            "The maximum amount of tokens has been bought."
        );
        _tokenHashOut = _request(_recipient, _settings.tokenHash, quantity);
    }

    /// @notice Get the token sale settings
    function getTokenSaleSettings()
    external
    virtual
    view
    override
    returns (TokenSaleSettings memory settings) {
        settings = _settings;
    }

    /// @notice Updates the token sale settings
    /// @param _info - the token sake settings
    function updateTokenSaleSettings(TokenSaleSettings memory _info)
    external
    virtual
    override {
        _settings = _info;
    }

    /// @notice returns whether the given item is a member of the collection
    /// @param token the token hash
    /// @return _member true if the token is a member of the collection, false otherwise
    function isMemberOf(uint256 token) external virtual view override  returns (bool _member) {

    }

    /// @notice returns all the tokens in the collection as an array
    /// @return _members the collection tokens
    function members() external virtual view override returns (uint256[] memory _members) {

    }

}




//     function _request(
//         address _recipient,
//         uint256 _token,
//         uint256 quantity
//     ) internal returns (uint256) {
//         // mint the target token directly into the user's account
//         INFTGemMultiToken(_settings.multitoken).mint(
//             _recipient,
//             _token,
//             quantity
//         );
//         // set the token data - it's not a claim or gem and it was minted here
//         INFTGemMultiToken(_settings.multitoken).setTokenData(
//             _token,
//             INFTGemMultiToken.TokenType.GOVERNANCE,
//             address(this)
//         );
//         return quantity;
//     }


//     function receivePayout(address payable _recipient) external override {
//         require(
//             this.isController(msg.sender) || msg.sender == _settings.owner,
//             "Only the token seller can receive payouts"
//         );
//         uint256 balance = payable(address(this)).balance;
//         if (balance == 0) {
//             return;
//         }
//         address feeManager = _settingsData.getFeeManager();
//         require(
//             feeManager != address(this),
//             "The token seller has no fee manager"
//         );
//         uint256 fee = INFTGemFeeManager(feeManager).fee(
//             uint256(keccak256(abi.encodePacked("lootbox")))
//         );
//         _recipient = _recipient != address(0)
//             ? _recipient
//             : payable(msg.sender);
//         fee = fee != 0 ? fee : 333;
//         uint256 feeAmount = balance / fee;
//         uint256 userPortion = balance - feeAmount;
//         require(payable(_recipient).send(userPortion), "Failed to send");
//         require(
//             payable(feeManager).send(feeAmount),
//             "Failed to send to fee manager"
//         );
//         emit FundsCollected(_recipient, userPortion);
//     }
// }
