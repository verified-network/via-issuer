// (c) Kallol Borah, 2020
// Interface definition of the Via cash and bond factory.

pragma solidity >=0.5.0 <0.7.0;

interface ViaFactory{

    function getTokenCount() external view returns(uint tokenCount);

    function getToken(uint256 n) external view returns(address);

    function getName(address viaAddress) external view returns(bytes32);

    function getType(address viaAddress) external view returns(bytes32);

    function getProduct(bytes32 symbol) external view returns(address);

    function getIssuer(bytes32 tokenType, bytes32 tokenName) external view returns(address);

    function createToken(address _target, bytes32 tokenName, bytes32 tokenProduct, bytes32 tokenSymbol) external returns(address);

}