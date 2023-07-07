// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ISdeploy {
    function getFeatureAddress() external view returns (address staking);

    function tokenAddress() external view returns (address vasdToken);
}
