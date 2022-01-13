// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../interfaces/ITokenPrice.sol";

// TODO write tests

/// @notice the price of a token and how it changes. price can be increased in steps which are determined by the price increase algorithm
contract TokenPrice is ITokenPrice {

    TokenPriceData internal _tokenPrice;

    /// @notice get the increased price of the token
    /// @return _price the increased price of the token
    function _getIncreasedPrice() internal view returns (uint256 _price) {
        PriceModifier pm = _tokenPrice.priceModifier;
        uint256 factor = _tokenPrice.priceModifierFactor;
        uint256 price = _tokenPrice.price;

        // exponential increase
        if (pm == PriceModifier.Exponential) {
            uint256 diffIncrease =  price / factor;
            price = price + diffIncrease;
        }

        // inverse log increase
        else if (pm == PriceModifier.InverseLog) {
            uint256 diffIncrease = factor / price;
            price = price + diffIncrease;
        }

        // fixed amount
        else if (pm == PriceModifier.Fixed) {
            uint256 diffIncrease = factor;
            price = price + diffIncrease;
        }

        // if max price is set, and price exceeds it, set it to max
        if(_tokenPrice.maxPrice != 0) {
            if(_tokenPrice.maxPrice < price) {
                price = _tokenPrice.maxPrice;
            }
        }

        // return new price
        _price = price;
    }

    /// @notice get the increased price of the token
    /// @return _price the increased price of the token
    function getIncreasedPrice() external virtual view override returns (uint256 _price) {
        return _getIncreasedPrice();
    }

    /// @notice get the increased price of the token
    /// @return _price the price of the token
    function getTokenPrice() external virtual view override returns (TokenPriceData memory _price) {
        return _tokenPrice;
    }
    /// @notice get the increased price of the token
    function _increasePrice() internal {
        _tokenPrice.price = _getIncreasedPrice();
    }

    /// @notice get the increased price of the token
    // function increasePrice() external virtual override {
    //     _increasePrice();
    // }

}
