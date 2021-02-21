//(c) Kallol Borah, 2020
// Via oracle interface definition
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

interface ViaOracle{

    function request(string calldata _currency, bytes32 _ratetype, bytes32 _tokenType, address payable _tokenContract)
        external
        payable
        returns (bytes32);
    
    function setCallbackId(bytes32 _queryId, bytes32 _callbackId) external;

    function payOut(bytes32 currency, bytes16 amount) external; 

}