// (c) Kallol Borah, 2020
// Implementation of the Via cash and bond factory.
// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.7.0;

import "./interfaces/ViaFactory.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/upgrades/contracts/upgradeability/ProxyFactory.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

contract Factory is ViaFactory, ProxyFactory, Initializable, Ownable {

    //data structure for token proxies
    struct via{
        bytes32 tokenType;
        bytes32 name;
    }

    //addresses of all Via proxies
    mapping(address => via) public token;

    address[] public tokens;

    //list of issued token products
    mapping(bytes32 => address) products;

    //list of token product issuers
    mapping(bytes32 => mapping(bytes32 => address)) issuers;

    event IssuerCreated(address indexed _address, bytes32 tokenName, bytes32 tokenType);
    event TokenCreated(address indexed _address, bytes32 tokenName, bytes32 tokenType);

    function initialize() public initializer{
        Ownable.initialize(msg.sender);
    }

    function getTokenCount() external view returns(uint tokenCount) {
        return tokens.length;
    }

    function getToken(uint256 n) external view returns(address){
        return tokens[n];
    }

    function getName(address viaAddress) external view returns(bytes32) {
        return token[viaAddress].name;
    }

    function getType(address viaAddress) external view returns(bytes32) {
        return token[viaAddress].tokenType;
    }

    function getNameAndType(address viaAddress) external view returns(bytes32, bytes32){
        return (token[viaAddress].name, token[viaAddress].tokenType);
    }

    //retrieve token product address for given identifier (symbol)
    function getProduct(bytes32 symbol) external view returns(address){
        return products[symbol];
    }

    //retrieve token product issuer address for given token name and type
    function getIssuer(bytes32 tokenType, bytes32 tokenName) external view returns(address){
        return issuers[tokenType][tokenName];
    }

    //token issuer factory 
    function createIssuer(address _target, bytes32 tokenName, bytes32 tokenType, address _oracle, address _token) external{
        address _owner = address(this);

        bytes memory _payload = abi.encodeWithSignature("initialize(bytes32,bytes32,address,address,address)", tokenName, tokenType, _owner, _oracle, _token);

        // Deploy proxy
        address _issuer = deployMinimal(_target, _payload);
        emit IssuerCreated(_issuer, tokenName, tokenType);

        if(tokenType == "Cash"){
                token[_issuer] = via("ViaCash", tokenName);
                tokens.push(_issuer);
                issuers["ViaCash"][tokenName] = _issuer;
        }
        else if(tokenType == "Bond"){
                token[_issuer] = via("ViaBond", tokenName);
                tokens.push(_issuer);
                issuers["ViaBond"][tokenName] = _issuer;
        }
    }
    
    //token factory
    function createToken(address _target, bytes32 tokenName, bytes32 tokenProduct, bytes32 tokenSymbol) external returns(address){
        require(token[msg.sender].tokenType == "ViaBond");
        address _owner = msg.sender;

        bytes memory _payload = abi.encodeWithSignature("initialize(bytes32,address,bytes32,bytes32)", tokenName, _owner, tokenProduct, tokenSymbol);

        // Deploy proxy
        address _token = deployMinimal(_target, _payload);
        products[tokenSymbol] = _token;       
        emit TokenCreated(_token, tokenName, tokenProduct);
        return _token;
    }
}






