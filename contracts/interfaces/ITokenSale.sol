//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

///
/// @dev Interface for the NFT Royalty Standard
///
interface ITokenSale {


    struct TokenData {
        uint256 id;
        uint256 supply;
        uint256 minted;
        uint256 rate;
        bool openState;
    }

    struct TokenMinting {
        address recipient;
        uint256 tokenHash;
        uint256 definitonHash;
    }

    event PayeeChanged(address indexed receiver);
    event Purchased(address indexed receiver, uint256 tokenHash, uint256 quantity, uint256 price);
    event TokenMinted(address indexed receiver, uint256 tokenHash, uint256 mintType);


    /// @notice Called to purchase some quantity of a token
    /// @param receiver - the address of the account receiving the item
    /// @param quantity - the quantity to purchase. max 5.
    function purchase(uint256 tokenId, address receiver, uint256 quantity) external payable returns (TokenMinting[] memory mintings);

    /// @notice returns the sale price in ETH for the given quantity.
    /// @param quantity - the quantity to purchase. max 5.
    /// @return price - the sale price for the given quantity
    function salePrice(uint256 tokenId, uint256 quantity) external view returns (uint256 price);

    /// @notice Mint a specific tokenhash to a specific address ( up to har-cap limit)
    /// only for controller of token
    /// @param receiver - the address of the account receiving the item
    /// @param tokenHash - token hash to mint to the receiver
    function mint(uint256 tokenId, address receiver, uint256 tokenHash) external;

    /// @notice open / close the tokensale
    /// only for controller of token
    /// @param openState - the open state of the tokensale
    function setOpenState(uint256 tokenId, bool openState) external;

    /// @notice get the token sale open state
    /// @return openState - the open state of the tokensale
    function getOpenState(uint256 tokenId) external view returns (bool);

    /// @notice set the psale price
    /// only for controller of token
    /// @param _salePrice - the open state of the tokensale
    function setSalePrice(uint256 _salePrice) external;

    /// @notice get the address of the sole token
    /// @return token - the address of the sole token
    function getSaleTokens() external view returns(address[] memory);

    /// @notice get the primary token sale payee
    /// @return payee_ the token sale payee
    function getPayee() external view returns (address payee_);

    /// @notice set the primary token sale payee
    /// @param _payee - the token sale payee
    function setPayee(address _payee) external;

    /// @notice return the mintee list
    /// @return _list the token sale payee
    function minterList() external view returns (TokenMinting[] memory _list);

    /// @notice return the purchaser list
    /// @return _list the token sale payee
    function purchaserList() external view returns (TokenMinting[] memory _list);

    /// @notice add a new token type to this token sale.
    /// only for controller of token
    /// @param tokenType - the token type definition
    function addTokenType(TokenData memory tokenType) external;

    /// @notice get the primary token sale payee
    /// @return tokenData_ the token sale payee
    function getTokenType(uint256 index) external view returns (TokenData memory tokenData_);

    // /// @notice get the primary token sale payee
    // /// @return length the token sale payee
    // function getTokenTypeLength() external view returns (uint256 length);

    // /// @notice get the full list of token data configuration blocks
    // /// @return tokenDatas_ the token datas
    // function getTokenTypes() external view returns (TokenData[] memory tokenDatas_);

}

interface IMintable {
    function mint(address receiver, uint256 tokenHash, uint256 quantity) external;
    function getMinter() external view returns (address);
}