// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./TokenPrice.sol";

contract TokenPriceOracle {
    TokenPrice public ethPrice;
    TokenPrice public usdtPrice;
    TokenPrice public arbPrice;

    constructor(address _ethFeed, address _usdtFeed, address _arbFeed) {
        ethPrice = new TokenPrice(_ethFeed);
        usdtPrice = new TokenPrice(_usdtFeed);
        arbPrice = new TokenPrice(_arbFeed);
    }

    function getEthPrice() external view returns (uint256) {
        return ethPrice.getPrice();
    }

    function getUsdtPrice() external view returns (uint256) {
        return usdtPrice.getPrice();
    }

    function getArbPrice() external view returns (uint256) {
        return arbPrice.getPrice();
    }
}
