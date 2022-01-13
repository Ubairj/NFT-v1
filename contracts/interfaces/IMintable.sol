//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IERC1155Mint.sol";

/// @dev extends IERC1155Mint and adds getMinter
interface IMintable is IERC1155Mint {

    function getMinter() external view returns (address);

}
