// (c) Kallol Borah, 2020
// Interface definition of the Via bond token.

pragma solidity >=0.5.0 <0.7.0;

interface ViaBond{

    function convert(bytes32 txId, bytes16 result, bytes32 rtype) external;

    function transferFoward(bytes32 _symbol, address _forwarder, address _sender, address _receiver, uint256 _tokens) external returns (bool);

    function requestIssue(bytes16 amount, address payer, bytes32 currency, address cashContract) external returns(bool);

}