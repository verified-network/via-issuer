//(c) Kallol Borah, 2020
// Via oracle client

pragma solidity >=0.5.0 <0.7.0;

import "./provableAPI.sol";
import "./Oracle.sol";
import "../utilities/StringUtils.sol";
import "../ViaFactory.sol";
import "../ViaCash.sol";
import "../ViaBond.sol";
import "../abdk-libraries-solidity/ABDKMathQuad.sol";

contract ViaOracle is Oracle, usingProvable {

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

    function initialize(address _factory) external {
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

        emit LogResult(pendingQueries[_myid].caller, _myid, pendingQueries[_myid].tokenType, pendingQueries[_myid].rateType, _result);
        
        if(pendingQueries[_myid].tokenType == "Cash"){
            ViaCash(pendingQueries[_myid].caller).convert(_myid, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
        }
        else if(pendingQueries[_myid].tokenType == "Bond"){
            ViaBond(pendingQueries[_myid].caller).convert(_myid, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
        }
        else if(pendingQueries[_myid].tokenType == "EthCash"){
            ViaCash(pendingQueries[_myid].caller).convert(_myid, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
        }
        else if(pendingQueries[_myid].tokenType == "EthBond"){
            ViaBond(pendingQueries[_myid].caller).convert(_myid, ABDKMathQuad.fromUInt(_result.stringToUint()), pendingQueries[_myid].rateType);
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
            if(_ratetype == "er" || _ratetype == "ver"){
                bytes32 queryId = provable_query("URL", string(abi.encodePacked("json(https://via-oracle.azurewebsites.net/rates/er/",_currency,").rate")),CUSTOM_GASLIMIT);  
                pendingQueries[queryId] = params(_tokenContract, _tokenType, _ratetype);
                emit LogNewProvableQuery("Provable query was sent for Via exchange rates...");
                return queryId;
            }
            else if(_ratetype == "ir"){
                bytes32 queryId = provable_query("URL", string(abi.encodePacked("json(https://via-oracle.azurewebsites.net/rates/ir/",_currency,").rate")),CUSTOM_GASLIMIT);
                pendingQueries[queryId] = params(_tokenContract, _tokenType, _ratetype);
                emit LogNewProvableQuery("Provable query was sent for Via interest rates...");
                return queryId;
                
            }
            else if(_ratetype == "ethusd"){
                bytes32 queryId = provable_query("URL", "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).price",CUSTOM_GASLIMIT);
                pendingQueries[queryId] = params(_tokenContract, _tokenType, _ratetype);
                emit LogNewProvableQuery("Provable query was sent for ETH-USD, standing by for the answer...");
                return queryId;
            }
        }        
    }
}