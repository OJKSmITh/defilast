// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Staking.sol";
import "./SelfToken.sol";
import "./TaxControl.sol";
import "./Sdeposit.sol";

contract Sdeploy {
    Staking stakingParam;
    TaxControl taxParam;
    Sdeposit depositParam;
    address private VASDtokenAddress;
    address private stakingAddress;
    address private taxAddress;
    address private depositAddress;
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
        depositParam = new Sdeposit();
        depositAddress = address(depositParam);
    }

    function tokenAddress() public view returns (address vasdToken) {
        return (VASDtokenAddress);
    }

    function getFeatureAddress()
        public
        view
        returns (address, address, address)
    {
        return (stakingAddress, taxAddress, depositAddress);
    }
}
