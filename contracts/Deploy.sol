// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Pool.sol";
import "./SelfToken.sol";
import "./Pair.sol";
import "./Liquid.sol";
import "./Swap.sol";

contract Deploy {
    Pair pairParam;
    Liquid liquidParam;
    Swap swapParam;

    address private pairAddress;
    address private liquidAddress;
    address private swapAddress;

    constructor(uint256 _feePercent) {
        pairParam = new Pair();
        pairAddress = address(pairParam);
        liquidParam = new Liquid();
        liquidAddress = address(liquidParam);
        swapParam = new Swap(_feePercent);
        swapAddress = address(swapParam);
    }

    function featureAddress()
        public
        view
        returns (address pair, address liquid, address swap)
    {
        return (pairAddress, liquidAddress, swapAddress);
    }
}
