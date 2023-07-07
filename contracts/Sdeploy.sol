// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Staking.sol";
import "./SelfToken.sol";

contract Sdeploy {
    Staking stakingParam;
    address private VASDtokenAddress;
    address private stakingAddress;
    SelfToken deployAsdtoken;
    SelfToken deployVasdtoken;
    SelfToken deployArbtoken;
    SelfToken deployUsdttoken;
    SelfToken deployEthtoken;

    constructor() {
        stakingParam = new Staking();
        stakingAddress = address(stakingParam);
        deployVasdtoken = new SelfToken("VASD", "VASD");
        VASDtokenAddress = address(deployVasdtoken);
    }

    function tokenAddress() public view returns (address vasdToken) {
        return (VASDtokenAddress);
    }

    function getFeatureAddress() public view returns (address staking) {
        return stakingAddress;
    }
}
