// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IPair {
    function makeLpPool(
        address _token1,
        address _token2,
        address _contractAddress
    ) external;

    function getLpAddress()
        external
        view
        returns (address arblp, address usdtlp, address ethlp);

    function getLpLv()
        external
        view
        returns (
            uint256 _ArbpoolLv,
            uint256 _ArbLpLv,
            uint256 _UsdtpoolLv,
            uint256 _UsdtLpLv,
            uint256 _EthpoolLv,
            uint256 _EthLpLv
        );

    function poolLvManagement(address _lptoken, uint256 _level) external;

    function LptokenLvManagement(address _lptoken, uint256 _level) external;
}
