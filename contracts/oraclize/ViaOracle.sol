//(c) Kallol Borah, 2020
// Via oracle client
// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.7.0;

import "./provableAPI.sol";
import "../interfaces/Oracle.sol";
import "../utilities/StringUtils.sol";
import "../interfaces/ViaFactory.sol";
import "../interfaces/ViaCash.sol";
//import "../Cash.sol";
import "../Bond.sol";
//import "../interfaces/ViaBond.sol";
import "../abdk-libraries-solidity/ABDKMathQuad.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract ViaOracle is Oracle, usingProvable, Initializable {

    using stringutils for *;

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    //via factory address
    ViaFactory private factory;

    struct params{
        address payable caller;
        bytes32 tokenType;
        bytes32 rateType;
        bytes32 callbackId;
    }

    uint constant CUSTOM_GASLIMIT = 500000;

    mapping (bytes32 => params) public pendingQueries;

    event LogNewProvableQuery(string description);
    event LogResult(address payable caller, bytes32 myid, bytes32 tokenType, bytes32 rateType, string result);

    constructor()
        public
        payable
    {
        // note : replace OAR if you are testing Oracle with ethereum-bridge (https://github.com/provable-things/ethereum-bridge)
        OAR = OracleAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475); 
        provable_setProof(proofType_TLSNotary | proofStorage_IPFS);
        provable_setCustomGasPrice(4000000000); // i.e. 4 GWei
    }

    function initialize(address _factory) external initializer{
        require(address(factory)==address(0x0));
        factory = ViaFactory(_factory);
    }                              

    function __callback(
        bytes32 _myid,
        string memory _result,
        bytes memory _proof
    )
        public 
    {
        //to do : lines below throw error
        require(msg.sender == provable_cbAddress());

        bytes32 callbackId = _myid;
        if(pendingQueries[_myid].callbackId!="")
            callbackId = pendingQueries[_myid].callbackId;

        emit LogResult(pendingQueries[_myid].caller, callbackId, pendingQueries[_myid].tokenType, pendingQueries[_myid].rateType, _result);
        
        if(pendingQueries[_myid].tokenType == "Cash"){
            ViaCash(pendingQueries[_myid].caller).convert(callbackId, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
        }
        else if(pendingQueries[_myid].tokenType == "Bond"){
            Bond(pendingQueries[_myid].caller).convert(callbackId, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
        }
        else if(pendingQueries[_myid].tokenType == "EthCash"){
            ViaCash(pendingQueries[_myid].caller).convert(callbackId, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
        }
        else if(pendingQueries[_myid].tokenType == "EthBond"){
            Bond(pendingQueries[_myid].caller).convert(callbackId, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
        }

        delete pendingQueries[_myid]; 
    }

    function request(bytes32 _currency, bytes32 _ratetype, bytes32 _tokenType, address payable _tokenContract)
        external
        payable
        returns (bytes32)
    {  
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBond");
        if (provable_getPrice("URL", CUSTOM_GASLIMIT) > address(this).balance) {
            emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee!");
        } else {
            string memory currency = _currency.bytes32ToString();
            if(_ratetype == "er" || _ratetype == "ver"){
                bytes32 queryId = provable_query("URL", string(abi.encodePacked("json(https://via-oracle.azurewebsites.net/rates/er/",currency,").rate")),CUSTOM_GASLIMIT);  
                //bytes32 queryId = provable_query("URL", "json(https://via-oracle.azurewebsites.net/rates/er/Via_USD_to_Via_EUR).rate",CUSTOM_GASLIMIT);
                pendingQueries[queryId] = params(_tokenContract, _tokenType, _ratetype,"");
                emit LogNewProvableQuery(string(abi.encodePacked("Provable query was sent for Via exchange rates for ",_currency)));
                return queryId;
            }
            else if(_ratetype == "ir"){
                bytes32 queryId = provable_query("URL", string(abi.encodePacked("json(https://via-oracle.azurewebsites.net/rates/ir/",_currency,").rate")),CUSTOM_GASLIMIT);
                pendingQueries[queryId] = params(_tokenContract, _tokenType, _ratetype,"");
                emit LogNewProvableQuery(string(abi.encodePacked("Provable query was sent for Via interest rates for ",_currency)));
                return queryId;
            }
            else if(_ratetype == "ethusd"){
                bytes32 queryId = provable_query("URL", "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).price",CUSTOM_GASLIMIT);
                pendingQueries[queryId] = params(_tokenContract, _tokenType, _ratetype,"");
                emit LogNewProvableQuery(string(abi.encodePacked("Provable query was sent for ETH-USD, standing by for the answer...")));
                return queryId;
            }
        }        
    }

    function setCallbackId(bytes32 _queryId, bytes32 _callbackId) external {
        require(pendingQueries[_queryId].caller==msg.sender);
        pendingQueries[_queryId].callbackId = _callbackId;
    }

}