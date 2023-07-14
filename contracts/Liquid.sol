// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./SelfToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Interface/IPair.sol";

contract Liquid {
    using SafeMath for uint;
    address private ARBtokenAddress;
    address private USDTtokenAddress;
    address private ETHtokenAddress;
    address private ArbLpaddress;
    address private UsdtLpaddress;
    address private EthLpaddress;
    uint256 private previousLp;
    uint256 private totalLpAmount;
    uint256 private withdrawtoken1;
    uint256 private withdrawAsd;
    uint256 public lpcalc;
    uint256 public count3;
    uint256 public count4;
    uint256 public totalAmount;
    uint256 private withdrawEth;
    uint decimals = 100000000000000000;

    /** 
    @dev Acoounts는 첫번째로 pool에 스테이킹을 하는 Lp토큰을 받는 mapping데이터에 대한 설명입니다. 
    address_1 user의 계정
    address_2 어떤 lp token을 받았는지 
    address_3 어떤 토큰들을 예치할것인지
    uint 그 토큰을 얼마나 예치했는지 확인하는 것 
    */
    mapping(address => mapping(address => mapping(address => uint)))
        public Accounts;
    /**
    @dev Lpcalc는 Lp를 총 계산하는데 쓰이는 객체입니다. 
    lp 총 계산하는데 쓰이는 객체
    address_1: address 는 어떤 Lp 풀인가
    address_2: 어떤 토큰인가
    uint256: 얼마나 예치했는지
     */
    mapping(address => mapping(address => uint256)) public Lpcalc;

    constructor() {}

    function makeLiquid(
        address _token1,
        uint256 amount1,
        address _token2,
        uint256 amount2,
        address _userAccount,
        address _factoryAddress,
        address _pairAddress
    ) external {
        SelfToken tokenA;
        SelfToken tokenB;
        tokenA = SelfToken(_token1);
        tokenB = SelfToken(_token2);
        (ArbLpaddress, UsdtLpaddress, EthLpaddress) = IPair(_pairAddress)
            .getLpAddress();

        tokenA.approve(_factoryAddress, amount1);
        tokenB.approve(_factoryAddress, amount2);
        tokenA.transferFrom(_userAccount, _factoryAddress, amount1);
        tokenB.transferFrom(_userAccount, _factoryAddress, amount2);
        if (
            keccak256(bytes(SelfToken(tokenA).name())) ==
            keccak256(bytes("ARB"))
        ) {
            ARBtokenAddress = _token1;
            Accounts[_userAccount][ArbLpaddress][_token1] += amount1;
            Accounts[_userAccount][ArbLpaddress][_token2] += amount2;
            uint256 calcLp = calclending(
                _token1,
                Accounts[_userAccount][ArbLpaddress][_token1],
                _token2,
                Accounts[_userAccount][ArbLpaddress][_token2]
            );
            Lpcalc[ArbLpaddress][_token1] += amount1;
            Lpcalc[ArbLpaddress][_token2] += amount2;
            ARBLpReward(_userAccount, calcLp, ArbLpaddress);
            totalLpAmount += (calcLp * (10 ** 18));
        } else if (
            keccak256(bytes(SelfToken(tokenA).name())) ==
            keccak256(bytes("USDT"))
        ) {
            USDTtokenAddress = _token1;
            Accounts[_userAccount][UsdtLpaddress][_token1] += amount1;
            Accounts[_userAccount][UsdtLpaddress][_token2] += amount2;
            uint256 calcLp = calclending(
                _token1,
                Accounts[_userAccount][UsdtLpaddress][_token1],
                _token2,
                Accounts[_userAccount][UsdtLpaddress][_token2]
            );
            Lpcalc[UsdtLpaddress][_token1] += amount1;
            Lpcalc[UsdtLpaddress][_token2] += amount2;
            USDTLpReward(_userAccount, calcLp, UsdtLpaddress);
            totalLpAmount += (calcLp * (10 ** 18));
        } else if (
            keccak256(bytes(SelfToken(tokenA).name())) ==
            keccak256(bytes("ETH"))
        ) {
            ETHtokenAddress = _token1;
            Accounts[_userAccount][EthLpaddress][_token1] += amount1;
            Accounts[_userAccount][EthLpaddress][_token2] += amount2;
            uint256 calcLp = calclending(
                _token1,
                Accounts[_userAccount][EthLpaddress][_token1],
                _token2,
                Accounts[_userAccount][EthLpaddress][_token2]
            );
            Lpcalc[EthLpaddress][_token1] += amount1;
            Lpcalc[EthLpaddress][_token2] += amount2;
            withdrawEth = Lpcalc[EthLpaddress][_token1];
            withdrawAsd = Lpcalc[EthLpaddress][_token2];
            ETHLpReward(_userAccount, calcLp, EthLpaddress);
            totalLpAmount += (calcLp * (10 ** 18));
        } else {
            revert("Unsupported token");
        }
    }

    function checkRefundAmount(
        address _lpaddress,
        uint256 _amount,
        address _ASDAddress
    ) public {
        require(
            SelfToken(_lpaddress).totalSupply() >= _amount,
            "insufficient lp amount"
        );

        uint256 lpcalcpercent = (totalLpAmount / _amount);
        if (
            keccak256(bytes(SelfToken(_lpaddress).name())) ==
            keccak256(bytes("ARBLP"))
        ) {
            withdrawtoken1 = (Lpcalc[_lpaddress][ARBtokenAddress] /
                lpcalcpercent);
            withdrawAsd = (Lpcalc[_lpaddress][_ASDAddress] / lpcalcpercent);
        } else if (
            keccak256(bytes(SelfToken(_lpaddress).name())) ==
            keccak256(bytes("USDTLP"))
        ) {
            withdrawtoken1 = (Lpcalc[_lpaddress][USDTtokenAddress] /
                lpcalcpercent);
            withdrawAsd = (Lpcalc[_lpaddress][_ASDAddress] / lpcalcpercent);
        } else if (
            keccak256(bytes(SelfToken(_lpaddress).name())) ==
            keccak256(bytes("ETHLP"))
        ) {
            withdrawtoken1 = (Lpcalc[_lpaddress][ETHtokenAddress] /
                lpcalcpercent);
            withdrawAsd = (Lpcalc[_lpaddress][_ASDAddress] / lpcalcpercent);
        } else {
            revert("Unsupported token");
        }
    }

    function doRemoveLiquid(
        address _lpaddress,
        uint256 _amount,
        address _userAccount,
        address _factoryAddress,
        address _ASDAddress
    ) external {
        require(
            SelfToken(_lpaddress).totalSupply() >= _amount,
            "insufficient lp amount"
        );
        SelfToken(_lpaddress).approve(_factoryAddress, _amount);
        uint256 lpcalcparams = _amount * 100;
        uint256 lpcalcpercent = (lpcalcparams / totalLpAmount);
        if (
            keccak256(bytes(SelfToken(_lpaddress).name())) ==
            keccak256(bytes("ARBLP"))
        ) {
            withdrawtoken1 =
                (Lpcalc[_lpaddress][ARBtokenAddress] * lpcalcpercent) /
                100;
            withdrawAsd =
                (Lpcalc[_lpaddress][_ASDAddress] * lpcalcpercent) /
                100;
            SelfToken(_lpaddress).transferFrom(
                _userAccount,
                _lpaddress,
                _amount
            );
            SelfToken(_lpaddress)._burn(_lpaddress, _amount);
            SelfToken(ARBtokenAddress).transferFrom(
                _factoryAddress,
                _userAccount,
                withdrawtoken1
            );
            SelfToken(_ASDAddress).transferFrom(
                _factoryAddress,
                _userAccount,
                withdrawAsd
            );
        } else if (
            keccak256(bytes(SelfToken(_lpaddress).name())) ==
            keccak256(bytes("USDTLP"))
        ) {
            withdrawtoken1 =
                (Lpcalc[_lpaddress][USDTtokenAddress] * lpcalcpercent) /
                100;
            withdrawAsd =
                (Lpcalc[_lpaddress][_ASDAddress] * lpcalcpercent) /
                100;
            SelfToken(_lpaddress).transferFrom(
                _userAccount,
                _lpaddress,
                _amount
            );
            SelfToken(_lpaddress).approve(_factoryAddress, _amount);

            SelfToken(_lpaddress)._burn(_lpaddress, _amount);
            SelfToken(USDTtokenAddress).transferFrom(
                _factoryAddress,
                _userAccount,
                withdrawtoken1
            );
            SelfToken(_ASDAddress).transferFrom(
                _factoryAddress,
                _userAccount,
                withdrawAsd
            );
        } else if (
            keccak256(bytes(SelfToken(_lpaddress).name())) ==
            keccak256(bytes("ETHLP"))
        ) {
            withdrawtoken1 =
                (Lpcalc[_lpaddress][ETHtokenAddress] * lpcalcpercent) /
                100;
            withdrawAsd =
                (Lpcalc[_lpaddress][_ASDAddress] * lpcalcpercent) /
                100;
            SelfToken(_lpaddress).transferFrom(
                _userAccount,
                _lpaddress,
                _amount
            );
            SelfToken(_lpaddress).approve(_factoryAddress, _amount);
            SelfToken(_lpaddress)._burn(_lpaddress, _amount);
            SelfToken(ETHtokenAddress).transferFrom(
                _factoryAddress,
                _userAccount,
                withdrawtoken1
            );
            SelfToken(_ASDAddress).transferFrom(
                _factoryAddress,
                _userAccount,
                withdrawAsd
            );
        } else {
            revert("Unsupported token");
        }
    }

    function calclending(
        address _token1,
        uint256 amount1,
        address _token2,
        uint256 amount2
    ) public returns (uint) {
        if (
            SelfToken(_token1).balanceOf(address(this)) > 0 &&
            SelfToken(_token2).balanceOf(address(this)) > 0
        ) {
            uint256 count1 = getDigitCount(
                SelfToken(_token1).balanceOf(address(this))
            );
            uint256 count2 = getDigitCount(
                SelfToken(_token2).balanceOf(address(this))
            );
            previousLp = ((SelfToken(_token1).balanceOf(address(this)) /
                (10 ** count1)) *
                (SelfToken(_token2).balanceOf(address(this)) / (10 ** count2)))
                .sqrt();
        }
        count3 = getDigitCount(
            SelfToken(_token1).balanceOf(address(this)) + amount1
        );
        count4 = getDigitCount(
            SelfToken(_token2).balanceOf(address(this)) + amount2
        );
        if (count3 < count4) {
            totalAmount =
                ((SelfToken(_token1).balanceOf(address(this)) + amount1) /
                    (10 ** count3)) *
                (((SelfToken(_token2).balanceOf(address(this)) + amount2) /
                    (10 ** count4)) * (10 ** (count4 - count3)));
        } else if (count3 > count4) {
            totalAmount =
                (((SelfToken(_token1).balanceOf(address(this)) + amount1) /
                    (10 ** count3)) * (10 ** (count3 - count4))) *
                ((SelfToken(_token2).balanceOf(address(this)) + amount2) /
                    (10 ** count4));
        }
        uint totallpAmount = totalAmount.sqrt() - previousLp;
        lpcalc = totallpAmount;
        return totallpAmount;
    }

    function ARBLpReward(
        address _userAccount,
        uint _lpamount,
        address _ArbLpaddress
    ) internal {
        SelfToken(_ArbLpaddress).mint(_lpamount);
        SelfToken(_ArbLpaddress).approve(
            _userAccount,
            (_lpamount * (10 ** 18))
        );
        SelfToken(_ArbLpaddress).transferFrom(
            ArbLpaddress,
            _userAccount,
            (_lpamount * (10 ** 18))
        );
    }

    function USDTLpReward(
        address _userAccount,
        uint _lpamount,
        address _UsdtLpaddress
    ) internal {
        SelfToken(_UsdtLpaddress).mint(_lpamount);
        SelfToken(_UsdtLpaddress).approve(
            _userAccount,
            (_lpamount * (10 ** 18))
        );
        SelfToken(_UsdtLpaddress).transferFrom(
            UsdtLpaddress,
            _userAccount,
            (_lpamount * (10 ** 18))
        );
    }

    function ETHLpReward(
        address _userAccount,
        uint _lpamount,
        address _Ethaddress
    ) internal {
        SelfToken(_Ethaddress).mint(_lpamount);
        SelfToken(_Ethaddress).approve(_userAccount, (_lpamount * (10 ** 18)));
        SelfToken(_Ethaddress).transferFrom(
            EthLpaddress,
            _userAccount,
            (_lpamount * (10 ** 18))
        );
    }

    function checkTest()
        public
        view
        returns (
            uint256 token1,
            uint256 asd1,
            uint256 lp,
            address arbtoken,
            address usdttoken,
            address ethtoken
        )
    {
        return (
            withdrawtoken1,
            withdrawAsd,
            totalLpAmount,
            ARBtokenAddress,
            USDTtokenAddress,
            ETHtokenAddress
        );
    }

    function provideAmount() public view returns (uint256, uint256) {
        return (withdrawtoken1, withdrawAsd);
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
