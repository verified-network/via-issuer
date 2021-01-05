// (c) Kallol Borah, 2020
// Interface definition of the Via cash and bond factory.
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

interface ViaFactory{

    function getTokenCount() external view returns(uint tokenCount);

    function getToken(uint256 n) external view returns(address);

    function getName(address viaAddress) external view returns(bytes32);

    function getType(address viaAddress) external view returns(bytes32);

    function getNameAndType(address viaAddress) external view returns(bytes32, bytes32);

    function getProduct(bytes32 symbol) external view returns(address);

    function getIssuer(bytes32 tokenType, bytes32 tokenName) external view returns(address);

    function getAddressAndType(bytes32 tokenName) external view returns (address, bytes32);

    function getFee(bytes32 feeType) external view returns(bytes16);

    function createToken(address _target, bytes32 tokenName, bytes32 tokenProduct, bytes32 tokenSymbol) external returns(address);

    function setFeeTo(address feeTo, bytes16 fee, bytes32 feeType) external;

    function setFeeToSetter(address _feeToSetter) external;

    function getFeeToSetter() external returns(address);

    function getViaOracleUrl() external returns(bytes32);

    function setViaOracleUrl(bytes32 _url) external;

}