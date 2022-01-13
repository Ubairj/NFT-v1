//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../access/Controllable.sol";
import "./ITokenSale.sol";

/// tokensale implementation
contract TokenSale is ITokenSale, Controllable, Initializable {

    address private payee;
    address private token;

    TokenData[] private tokenData;

    TokenMinting[] private _purchasers;
    TokenMinting[] private _mintees;

    /// @notice Called to purchase some quantity of a token
    constructor() {

        _addController(msg.sender);
        payee = msg.sender;

    }

    /// @dev called after constructor once to init stuff
    function initialize(address _token) public initializer {
        token = _token;
    }

    /// @notice add a new token type to this token sale.
    /// only for controller of token
    /// @param tokenType - the token type definition
    function addTokenType(TokenData memory tokenType) external override onlyController{

        tokenData.push(tokenType);

    }


    /// @notice get the primary token sale payee
    /// @return tokenData_ the token sale payee
    function getTokenType(uint256 index) external view override returns (TokenData memory tokenData_)  {

        return tokenData[index];

    }

    /// @notice get the primary token sale payee
    /// @return length the token sale payee
    function getTokenTypeLength() external view override returns (uint256 length) {

        return tokenData.length;

    }

    /// @notice get the full list of token data configuration blocks
    /// @return tokenDatas_ the token datas
    function getTokenTypes() external view override returns (TokenData[] memory tokenDatas_){

            return tokenData;

    }

    /// @notice Called to purchase some quantity of a token
    /// @param receiver - the address of the account receiving the item
    /// @param quantity - the quantity to purchase. max 5.
    function purchase(uint256 tokenHash, address receiver, uint256 quantity) external payable override returns (TokenMinting[] memory mintings) {

        TokenData storage _tokenData = tokenData[tokenHash];
        require(_tokenData.id == tokenHash, "invalid object");

        require(_tokenData.minted + quantity <= _tokenData.supply, "cannot purchase more than supply");
        require(_tokenData.rate * quantity <= msg.value, "must attach funds to purchase items");
        require(_tokenData.openState, "cannot mint when tokensale is closed");

        require(quantity > 0 && quantity <= 3, "cannot purchase more than 3 items");

        // create the receipt for this minting
        TokenMinting memory _minting = TokenMinting(receiver, tokenHash, 0);

        // create a record of this new minting
        _purchasers.push(_minting);

        // emit an event to that respect
        emit TokenMinted(receiver, tokenHash, 0);

        // TODO: this might fail, if it does try
        // mintings = new mintings[](1);
        mintings[0] =_minting;
    }

    /// @notice returns the sale price in ETH for the given quantity.
    /// @param quantity - the quantity to purchase. max 5.
    /// @return price - the sale price for the given quantity
    function salePrice(uint256 tokenId, uint256 quantity) external view override returns (uint256 price) {

        price = tokenData[tokenId].rate * quantity;

    }

    /// @notice Mint a specific tokenhash to a specific address ( up to har-cap limit)
    /// only for controller of token
    /// @param receiver - the address of the account receiving the item
    /// @param tokenHash - token hash to mint to the receiver
    function mint(uint256 tokenHash, address receiver, uint256 quantity) external override onlyController {

        require(tokenData[tokenHash].openState, "cannot mint when tokensale is closed");
        require(tokenData[tokenHash].minted < tokenData[tokenHash].supply, "cannot mint more than supply");

        tokenData[tokenHash].minted += 1;
        _mintees.push(TokenMinting(receiver, tokenHash, tokenHash));

        IMintable(token).mint(receiver, tokenHash, quantity);

        // emit an event to that respect
        emit TokenMinted(receiver, tokenHash, 1);
    }


    /// @notice open / close the tokensale
    /// only for controller of token
    /// @param openState - the open state of the tokensale
    function setOpenState(uint256 tokenHash, bool openState) external override onlyController {
        tokenData[tokenHash].openState = openState;
    }

    /// @notice get the token sale open state
    /// @return openState - the open state of the tokensale
    function getOpenState(uint256 tokenHash) external view override returns (bool openState) {
        return tokenData[tokenHash].openState;
    }

    /// @notice get the token sale price
    /// @return salePrice - the open state of the tokensale
    function getSalePrice(uint256 tokenHash) external view override returns (uint256) {
        return tokenData[tokenHash].rate;
    }

    /// @notice set the psale price
    /// only for controller of token
    /// @param _payee - the open state of the tokensale
    function setPayee(address _payee) external override onlyController {
        require(_payee != address(0), "payee cannoot be zero address");
        payee = _payee;
        emit PayeeChanged(payee);
    }

    /// @notice get the token sale price
    /// @return salePrice - the open state of the tokensale
    function getPayee() external view  override returns (address) {
        return payee;
    }

    /// @notice get the total list of purchasers
    /// @return _list - total list of purchasers
    function purchaserList() external view override returns (TokenMinting[] memory _list) {
        _list = _purchasers;
    }

    /// @notice get the total list of minters
    /// @return _list - total list of purchasers
    function minterList() external view override returns (TokenMinting[] memory _list) {
        _list = _mintees;
    }

    /// @notice get the address of the sole token
    /// @return token - the address of the sole token
    function getSaleTokens() external view override returns(address[] memory) {

    }

    /// @notice set sale price
    function setSalePrice(uint256) external pure override {
        require(false, "this method is not implemented");
    }
}
