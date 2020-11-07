// (c) Kallol Borah, 2020
// Interface of the Via cash token.

pragma solidity >=0.5.0 <0.7.0;


interface ViaCash{

    function convert(bytes32 txId, bytes16 result, bytes32 rtype) external;

    function addToBalance(bytes16 tokens, address sender) external returns (bool);

    function deductFromBalance(bytes16 tokens, address receiver) external returns (bytes16);

}