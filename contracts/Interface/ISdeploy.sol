// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ISdeploy {
    function getFeatureAddress()
        external
        view
        returns (address, address, address);

    function tokenAddress() external view returns (address vasdToken);
}
