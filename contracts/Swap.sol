// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./TokenPriceOracle.sol";
import "./SelfToken.sol";

contract Swap {
    using SafeMath for uint256;
    address public feeRecipient;
    uint public feePercentage;
    uint256 public EthPrice;
    uint256 public UsdtPrice;
    uint256 public ArbPrice;
    uint256 public EthSwapPercent;
    uint256 public UsdtSwapPercent;
    uint256 public ArbSwapPercent;
    uint256 public ASDSwapPercent;
    uint256 public testValue;

    TokenPriceOracle public priceOracle;

    address public EthAddress = 0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08;
    address public UsdtAddress = 0x0a023a3423D9b27A0BE48c768CCF2dD7877fEf5E;
    address public ArbAddress = 0x2eE9BFB2D319B31A573EA15774B755715988E99D;

    mapping(string => uint256) public tokenInfo;

    constructor(uint _feePercentage) {
        feeRecipient = address(this);
        feePercentage = _feePercentage;
        // priceOracle = new TokenPriceOracle(EthAddress, UsdtAddress, ArbAddress);
        // EthPrice = priceOracle.getEthPrice();
        // UsdtPrice = priceOracle.getUsdtPrice();
        // ArbPrice = priceOracle.getArbPrice();
        // tokenInfo["ETH"] = EthPrice;
        // tokenInfo["ARB"] = ArbPrice;
        // tokenInfo["USDT"] = UsdtPrice;
        // tokenInfo["ASD"] = UsdtPrice;
        tokenInfo["ETH"] = 188278970000;
        tokenInfo["ARB"] = 112709586;
        tokenInfo["USDT"] = 100005156;
        tokenInfo["ASD"] = 100005156;
    }

    function differTokenSwap(
        address tokenA,
        address tokenB,
        address _userAccount,
        address _contractAddress,
        uint256 amountA
    ) public {
        uint256 amountB;
        uint256 feeAmount;
        uint256 amountToSwap;
        string memory tokenAName = SelfToken(tokenA).name();
        string memory tokenBName = SelfToken(tokenB).name();
        uint256 valueA = tokenInfo[tokenAName];
        uint256 valueB = tokenInfo[tokenBName];

        (feeAmount, amountToSwap) = calculateFeesAndAmountToSwap(amountA);

        amountB = calculateAmountB(amountToSwap, valueA, valueB);

        conductTransfer(
            tokenA,
            tokenB,
            _userAccount,
            _contractAddress,
            amountA,
            amountB,
            feeAmount,
            amountToSwap
        );
    }

    function calculateFeesAndAmountToSwap(
        uint256 amountA
    ) public view returns (uint256 feeAmount, uint256 amountToSwap) {
        uint256 _feePercentage = feePercentage * (10 ** 15);
        feeAmount = (amountA / 10 ** 18) * _feePercentage;
        amountToSwap = amountA - feeAmount;
        return (feeAmount, amountToSwap);
    }

    function calculateAmountB(
        uint256 _amountToSwap, // a의 개수
        uint256 _valueA,
        uint256 _valueB
    ) public pure returns (uint256) {
        uint256 amountB;
        uint256 aPer;
        uint256 bPer;
        if (_valueA < _valueB) {
            aPer = _valueB / _valueA;
            bPer = 1;
            amountB = (bPer * _amountToSwap) / aPer;
        } else if (_valueA > _valueB) {
            aPer = 1;
            bPer = _valueA / _valueB;
            amountB = (bPer * _amountToSwap) / aPer;
        }
        return amountB;
    }

    function conductTransfer(
        address tokenA,
        address tokenB,
        address _userAccount,
        address _contractAddress,
        uint256 amountA,
        uint256 amountB,
        uint256 feeAmount,
        uint256 amountToSwap
    ) public payable {
        SelfToken(tokenA).approve(_contractAddress, amountA);
        SelfToken(tokenB).approve(_contractAddress, amountB);
        SelfToken(tokenA).transferFrom(
            _userAccount,
            _contractAddress,
            amountToSwap
        );
        SelfToken(tokenA).transferFrom(
            _userAccount,
            _contractAddress,
            feeAmount
        );
        SelfToken(tokenB).transferFrom(_contractAddress, _userAccount, amountB);
    }

    function supplyPrice() public view returns (uint256, uint256, uint256) {
        return (ArbPrice, UsdtPrice, EthPrice);
    }
}
