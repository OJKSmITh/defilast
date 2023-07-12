// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Staking.sol";
import "./SelfToken.sol";
import "./TaxControl.sol";

contract Sdeploy {
    Staking stakingParam;
    TaxControl taxParam;
    address private VASDtokenAddress;
    address private stakingAddress;
    address private taxAddress;
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
        taxParam = new TaxControl();
        taxAddress = address(taxParam);
    }

    function tokenAddress() public view returns (address vasdToken) {
        return (VASDtokenAddress);
    }

    function getFeatureAddress() public view returns (address, address) {
        return (stakingAddress, taxAddress);
    }
}
