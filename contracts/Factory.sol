// (c) Kallol Borah, 2020
// Implementation of the Via cash and bond factory
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

import "./interfaces/ViaFactory.sol";
import "abdk-libraries-solidity/ABDKMathQuad.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/upgrades/contracts/upgradeability/ProxyFactory.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

contract Factory is ViaFactory, ProxyFactory, Initializable, Ownable {

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    //data structure for token proxies
    struct via{
        bytes32 tokenType;
        bytes32 name;        
    }

    //fee structure for payments
    struct payments{
        bytes16 remittance;
        bytes16 redemption;
    }

    mapping(address => payments) private paymentFees;

    //fee structure for bond issuing
    struct issues{
        bytes16 issuing;
        bytes16 trading;
    }

    mapping(address => issues) private issuingFees;

    //address of who gets Via fees
    address feeToSetter;

    //address of custodian
    address custodian;

    //address of client contract
    address client;

    //Via oracle url address
    address ViaOracle;
    string ViaOracleUrl;

    //addresses of all Via proxies
    mapping(address => via) public token;

    address[] public tokens;

    //list of issued token products
    mapping(bytes32 => address) products;

    //list of token product issuers
    mapping(bytes32 => mapping(bytes32 => address)) issuers;

    //list of assets and their margins
    mapping(bytes32 => bytes16) assets;

    //list of treasury managers
    address[] public managers;

    event IssuerCreated(address indexed _address, bytes32 tokenName, bytes32 tokenType);
    event TokenCreated(address indexed _address, bytes32 tokenName, bytes32 tokenType);

    function initialize() public initializer{
        Ownable.initialize(msg.sender);
        feeToSetter = msg.sender;
        managers.push(msg.sender);
        custodian = msg.sender;
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

    //get margin for asset 
    function getMargin(bytes32 asset) external view returns(bytes16) {
        return assets[asset];
    }

    function getNameAndType(address viaAddress) external view returns(bytes32, bytes32){
        return (token[viaAddress].name, token[viaAddress].tokenType);
    }

    function getTokenByNameType(bytes32 tokenName, bytes32 tokenType) external view returns(address){
        for(uint256 q=0; q<tokens.length; q++){
            if(token[tokens[q]].name == tokenName && token[tokens[q]].tokenType == tokenType)
                return tokens[q];
        }
    }

    //retrieve token product address for given identifier (symbol)
    function getProduct(bytes32 symbol) external view returns(address){
        return products[symbol];
    }

    //retrieve token product issuer address for given token name and type
    function getIssuer(bytes32 tokenType, bytes32 tokenName) external view returns(address){
        return issuers[tokenType][tokenName];
    }

    //retrieves address and type of token for name specified
    function getAddressAndType(bytes32 tokenName) external view returns (address, bytes32){
        bool found = false;
        uint256 i=0;
        for(i=0; i<tokens.length; i++){
            if(token[tokens[i]].name==tokenName){
                found == true;
                break;
            }
        }
        if(found)
            return (tokens[i], token[tokens[i]].tokenType);
        else
            return (address(0x0), "");
    }

    //get fee for different services
    function getFee(bytes32 feeType) external view returns(bytes16){
        if(feeType=="issuing"){
            return (issuingFees[msg.sender].issuing);
        }
        else if(feeType=="trading"){
            return (issuingFees[msg.sender].trading);
        }
        else if(feeType=="remittance"){
            return (paymentFees[msg.sender].remittance);
        }
        else if(feeType=="redemption"){
            return (paymentFees[msg.sender].redemption);
        }
    }

    //gets address to which fee income has to be transferred
    function getFeeToSetter() external view returns(address){
        require(token[msg.sender].tokenType == "ViaCash" || token[msg.sender].tokenType == "ViaBond", 'Get fee setter : FORBIDDEN');
        return feeToSetter;
    }

    //verifies if sender (who requests issue of cash tokens against fiat / bond tokens against non-ether assets) is a treasurer
    function getTreasury(address sender) external view returns(bool){
        require(token[msg.sender].tokenType == "ViaCash" || token[msg.sender].tokenType == "ViaBond", 'Get treasury : FORBIDDEN');
        bool found = false;
        uint256 i=0;
        for(i=0; i<managers.length; i++){
            if(managers[i]==sender){
                found == true;
                break;
            }
        }
        return found;
    }

    //get Custodian address for transferring (backing up) assets
    function getCustodian() external view returns(address){
        require(token[msg.sender].tokenType == "ViaCash" || token[msg.sender].tokenType == "ViaBond", 'Get custodian : FORBIDDEN');
        return custodian;
    }

    //get Verified client address for AML check
    function getClient() external view returns(address){
        //require(token[msg.sender].tokenType == "ViaCash" || token[msg.sender].tokenType == "ViaBond", 'Get client : FORBIDDEN');
        return client;
    }

    function getViaOracleUrl() external view returns(string memory){
        require(msg.sender == ViaOracle);
        return ViaOracleUrl;
    }

    //token issuer factory 
    function createIssuer(address _target, bytes32 tokenName, bytes32 tokenType, address _oracle, address _token, address _fee) external{
        address _owner = address(this);
        ViaOracle = _oracle;
        bytes memory _payload = abi.encodeWithSignature("initialize(bytes32,bytes32,address,address,address,address)", tokenName, tokenType, _owner, _oracle, _token, _fee);

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

        bytes memory _payload = abi.encodeWithSignature("initialize(address,bytes32,address,bytes32,bytes32)", address(this), tokenName, _owner, tokenProduct, tokenSymbol);

        // Deploy proxy
        address _token = deployMinimal(_target, _payload);
        
        token[_token] = via("ViaBondToken", tokenName);
        tokens.push(_token);
        products[tokenSymbol] = _token;       
        emit TokenCreated(_token, tokenName, tokenProduct);
        return _token;
    }

    function setFeeTo(address feeTo, uint256 fee, bytes32 feeType) external {
        require(msg.sender == feeToSetter, 'Via: FORBIDDEN');
        if(feeType=="issuing"){
            issuingFees[feeTo].issuing = ABDKMathQuad.fromUInt(fee);
        }
        else if(feeType=="trading"){
            issuingFees[feeTo].trading = ABDKMathQuad.fromUInt(fee);
        }
        else if(feeType=="remittance"){
            paymentFees[feeTo].remittance = ABDKMathQuad.fromUInt(fee);
        }
        else if(feeType=="redemption"){
            paymentFees[feeTo].redemption = ABDKMathQuad.fromUInt(fee);
        }
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Set fee to setter: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setViaOracleUrl(string calldata _url) external {
        require(msg.sender == feeToSetter, 'FORBIDDEN : Setting Via oracle url');
        ViaOracleUrl = _url;
    }

    function setMargin(uint256 _margin, bytes32 _asset) external {
        require(msg.sender == feeToSetter, 'Set margin : FORBIDDEN');
        assets[_asset] = ABDKMathQuad.fromUInt(_margin);
    }

    function setTreasury(address _treasury) external {
        require(msg.sender == feeToSetter, 'Set treasury : FORBIDDEN');
        bool found = false;
        uint256 i=0;
        for(i=0; i<managers.length; i++){
            if(managers[i]==_treasury){
                found == true;
                break;
            }
        }
        if(!found)
            managers.push(_treasury);
    }

    function setCustodian(address _custodian) external {
        require(msg.sender == feeToSetter, 'Set custodian : FORBIDDEN');
        custodian = _custodian;
    }

    function setClient(address _client) external {
        require(msg.sender == feeToSetter, 'Set client : FORBIDDEN');
        client = _client;
    }

}






