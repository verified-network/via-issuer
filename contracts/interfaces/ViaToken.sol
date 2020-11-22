// (c) Kallol Borah, 2020
// Interface definition of the token issued by Bond issuer

pragma solidity >=0.5.0 <0.7.0;

interface ViaToken{

    function transferToken(address sender, address receiver, uint256 tokens) external returns (bool);

    function reduceSupply(bytes16 amount) external;

    function reduceBalance(address party, bytes16 amount) external;

    function addBalance(address party, bytes16 amount) external;

    function addTotalSupply(bytes16 amount) external;

    function requestTransfer(address receiver, uint tokens) external returns (bool);

    function requestIssue(bytes16 amount, address payer, bytes32 currency, address cashContract) external returns(bool);

}