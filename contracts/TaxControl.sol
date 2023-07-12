// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./SelfToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TaxControl {
    address[] private ArbLpaccounts;
    uint256 private ArbL;
    address[] private UsdtLpaccounts;
    uint256 private UsdtL;
    address[] private EthLpaccounts;
    uint256 private EthL;
    struct userInform {
        uint256 userPer;
        uint256 De;
    }

    mapping(address => userInform) ArbLpPer;
    mapping(address => userInform) UsdtLpPer;
    mapping(address => userInform) EthLpPer;

    constructor() {}

    function accountsMake(address _differLp) public {
        string memory tokenName = SelfToken(_differLp).name();
        if (Strings.equal(tokenName, "ETHLP")) {
            (EthLpaccounts, EthL) = SelfToken(_differLp).getAccounts();
        } else if (Strings.equal(tokenName, "ARBLP")) {
            (ArbLpaccounts, ArbL) = SelfToken(_differLp).getAccounts();
        } else if (Strings.equal(tokenName, "USDTLP")) {
            (UsdtLpaccounts, UsdtL) = SelfToken(_differLp).getAccounts();
        }
    }

    function claimFee(
        address _differLpToken,
        address _ArbAddress,
        address _UsdtAddress,
        address _EthAddress
    ) public {
        calculLpPer(_differLpToken);
        string memory tokenName = SelfToken(_differLpToken).name();
        if (Strings.equal(tokenName, "ETHLP")) {
            uint256 totalTokenAmount = SelfToken(_EthAddress).balanceOf(
                address(this)
            );
            for (uint256 i = 0; i < EthL; i++) {
                address userAccount = EthLpaccounts[i];
                uint256 userPer = EthLpPer[userAccount].userPer;
                uint256 userDe = EthLpPer[userAccount].De;
                uint256 userShare = (totalTokenAmount * userPer) /
                    (10 ** userDe);
                SelfToken(_EthAddress).transferFrom(
                    address(this),
                    userAccount,
                    userShare
                );
            }
        } else if (Strings.equal(tokenName, "ARBLP")) {
            uint256 totalTokenAmount = SelfToken(_ArbAddress).balanceOf(
                address(this)
            );
            for (uint256 i = 0; i < ArbL; i++) {
                address userAccount = ArbLpaccounts[i];
                uint256 userPer = ArbLpPer[userAccount].userPer;
                uint256 userDe = ArbLpPer[userAccount].De;
                uint256 userShare = (totalTokenAmount * userPer) /
                    (10 ** userDe);
                SelfToken(_ArbAddress).transferFrom(
                    address(this),
                    userAccount,
                    userShare
                );
            }
        } else if (Strings.equal(tokenName, "USDTLP")) {
            uint256 totalTokenAmount = SelfToken(_UsdtAddress).balanceOf(
                address(this)
            );
            for (uint256 i = 0; i < UsdtL; i++) {
                address userAccount = UsdtLpaccounts[i];
                uint256 userPer = UsdtLpPer[userAccount].userPer;
                uint256 userDe = UsdtLpPer[userAccount].De;
                uint256 userShare = (totalTokenAmount * userPer) /
                    (10 ** userDe);
                SelfToken(_UsdtAddress).transferFrom(
                    address(this),
                    userAccount,
                    userShare
                );
            }
        }
    }

    function calculLpPer(address _differLp) internal {
        string memory tokenName = SelfToken(_differLp).name();
        if (Strings.equal(tokenName, "ETHLP")) {
            uint256 totalLp = SelfToken(_differLp).totalSupply();
            for (uint256 i = 0; i < EthL; i++) {
                address userAccount = EthLpaccounts[i];
                uint256 userLp = SelfToken(_differLp).balanceOf(userAccount);
                uint256 userDe = getDigitCount(userLp);
                uint256 totalDe = getDigitCount(totalLp);
                uint256 subDe = totalDe - userDe + 2;
                uint256 userP = (userLp * (10 ** subDe)) / totalLp;
                EthLpPer[userAccount].userPer += userP;
                EthLpPer[userAccount].De = subDe;
            }
        } else if (Strings.equal(tokenName, "ARBLP")) {
            uint256 totalLp = SelfToken(_differLp).totalSupply();
            for (uint256 i = 0; i < ArbL; i++) {
                address userAccount = ArbLpaccounts[i];
                uint256 userLp = SelfToken(_differLp).balanceOf(userAccount);
                uint256 userDe = getDigitCount(userLp);
                uint256 totalDe = getDigitCount(totalLp);
                uint256 subDe = totalDe - userDe + 2;
                uint256 userP = (userLp * (10 ** subDe)) / totalLp;
                ArbLpPer[userAccount].userPer += userP;
                ArbLpPer[userAccount].De = subDe;
            }
        } else if (Strings.equal(tokenName, "USDTLP")) {
            uint256 totalLp = SelfToken(_differLp).totalSupply();
            for (uint256 i = 0; i < UsdtL; i++) {
                address userAccount = UsdtLpaccounts[i];
                uint256 userLp = SelfToken(_differLp).balanceOf(userAccount);
                uint256 userDe = getDigitCount(userLp);
                uint256 totalDe = getDigitCount(totalLp);
                uint256 subDe = totalDe - userDe + 2;
                uint256 userP = (userLp * (10 ** subDe)) / totalLp;
                UsdtLpPer[userAccount].userPer += userP;
                UsdtLpPer[userAccount].De = subDe;
            }
        }
    }

    function getDigitCount(uint256 number) public pure returns (uint256) {
        if (number == 0) {
            return 1;
        }

        uint256 digitCount = 0;
        while (number > 0) {
            digitCount++;
            number = number / 10;
        }

        return digitCount - 1;
    }
}
