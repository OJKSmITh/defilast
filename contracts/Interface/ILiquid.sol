// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ILiquid {
    function makeLiquid(
        address _token1,
        uint256 amount1,
        address _token2,
        uint256 amount2,
        address _userAccount,
        address _factoryAddress,
        address pairAddress
    ) external;

    function doRemoveLiquid(
        address _lpaddress,
        uint256 _amount,
        address _userAccount,
        address _factoryAddress,
        address _ASDAddress
    ) external;

    function calclending(
        address _token1,
        uint256 amount1,
        address _token2,
        uint256 amount2
    ) external returns (uint);

    function checkTest()
        external
        view
        returns (
            uint with,
            uint asd,
            uint lp,
            address arbtoken,
            address usdttoken,
            address ethtoken
        );

    function checkRefundAmount(
        address _lpaddress,
        uint256 _amount,
        address _ASDAddress
    ) external;

    function provideAmount() external view returns (uint256, uint256);
}
