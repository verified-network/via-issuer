// File: contracts/interfaces/Oracle.sol

//(c) Kallol Borah, 2020
// Via oracle interface definition

pragma solidity >=0.5.0 <0.7.0;

interface Oracle{

    function request(bytes32 _currency, bytes32 _ratetype, bytes32 _tokenType, address payable _tokenContract)
        external
        payable
        returns (bytes32);
    
    function setCallbackId(bytes32 _queryId, bytes32 _callbackId) external;

}
