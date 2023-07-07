// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IDeploy {
    function featureAddress()
        external
        view
        returns (address pair, address liquid, address swap);
}
