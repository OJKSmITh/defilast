// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ISwap {
    function differTokenSwap(
        address tokenA,
        address tokenB,
        address _userAccount,
        address _contractAddress,
        uint256 amountA
    ) external;

    function supplyPrice() external view returns (uint256, uint256, uint256);
}
