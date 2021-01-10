// (c) Kallol Borah, 2020
// Interface of the Via cash token.
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

interface ViaCash{

    function convert(bytes32 txId, bytes16 result, bytes32 rtype) external;

    function requestAddToBalance(bytes16 tokens, address sender) external returns (bool);

    function requestDeductFromBalance(bytes16 tokens, address receiver) external returns (bytes16);

    function transferFrom(address sender, address receiver, uint256 tokens) external returns (bool);

    function payIn(uint256 tokens, address sender) external returns(bool);

    function transferToCustody(uint percent) external returns(bool);

}