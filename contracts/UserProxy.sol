// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.9;

// import "./Proxy.sol";
// import "./Factory_v1.sol";

// contract Factory_v1 {
//     address public proxyAdmin;
//     address public poolImplementation;

//     constructor(address _poolImplementation) {
//         proxyAdmin = msg.sender;
//         poolImplementation = _poolImplementation;
//     }

//     function createPool(
//         address _feeRecipient,
//         uint _feePercentage
//     ) public returns (address) {
//         // Create new proxy
//         Proxy proxy = new Proxy();

//         // Set the admin of the proxy
//         proxy.changeAdmin(proxyAdmin);

//         // Set the implementation of the proxy
//         proxy.upgradeTo(poolImplementation);

//         Pool_v1(address(proxy)).initialize(_feeRecipient, _feePercentage);

//         return address(proxy);
//     }
// }
