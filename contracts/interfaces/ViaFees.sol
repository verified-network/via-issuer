// (c) Kallol Borah, 2020
// Interface of the Via fee payer
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

interface ViaFees{

    function payRedemptionFee(bytes16 value) external returns (bytes16);

    function transferToCustody(uint percent, address transferFrom) external returns(bool);

    function payIssuingFee(bytes16 value) external returns (bytes16);

    function payTradingFee(bytes16 value, address cashContract) external returns (bytes16);

    function amlCheck(address account) external returns(bool);

}