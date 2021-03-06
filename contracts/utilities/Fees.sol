// (c) Kallol Borah, 2020
// Implementation of utility functions for fee payments
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

import "../interfaces/ViaFactory.sol";
import "../interfaces/ViaCash.sol";
import "abdk-libraries-solidity/ABDKMathQuad.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "../interfaces/VerifiedClient.sol";

contract Fees is Initializable{

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    ViaFactory private factory;

    //verified client
    address private client;

    function initialize(address _factory) external initializer{
        require(address(factory)==address(0x0));
        factory = ViaFactory(_factory);
    } 

    function payRedemptionFee(bytes16 value) external returns (bytes16){
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBond");
        bytes16 fee = factory.getFee("redemption");
        bytes16 returnValue;
        if(ABDKMathQuad.toUInt(fee)!=0){
            address feeTo = factory.getFeeToSetter();
            if(feeTo!=address(0x0)){
                address(uint160(feeTo)).transfer(ABDKMathQuad.toUInt(ABDKMathQuad.mul(fee, value)));
                returnValue = ABDKMathQuad.sub(value, ABDKMathQuad.mul(fee, value));
            }
        }
        return returnValue;
    }

    //transfer ether balances to custodian
    function transferToCustody(uint percent, address transferFrom) external returns(bool){
        require(factory.getTreasury(msg.sender)==true);
        address custodian = factory.getCustodian();
        if(custodian!=address(0x0)){
            address(uint160(custodian)).transfer(ABDKMathQuad.toUInt(ABDKMathQuad.mul(ABDKMathQuad.fromUInt(transferFrom.balance),ABDKMathQuad.fromUInt(percent))));
            return true;
        }
        else
            return false;
    }

    function payIssuingFee(bytes16 value) external returns (bytes16){
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBond");
        bytes16 fee = factory.getFee("issuing");
        bytes16 returnValue;
        if(ABDKMathQuad.toUInt(fee)!=0){
            address feeTo = factory.getFeeToSetter();
            if(feeTo!=address(0x0)){
                address(uint160(feeTo)).transfer(ABDKMathQuad.toUInt(ABDKMathQuad.mul(fee, value)));
                returnValue = ABDKMathQuad.sub(value, ABDKMathQuad.mul(fee, value));
            }
        }
        return returnValue;
    }

    function payTradingFee(bytes16 value, address cashContract) external returns (bytes16){
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBond");
        bytes16 fee = factory.getFee("trading");
        bytes16 returnValue;
        if(ABDKMathQuad.toUInt(fee)!=0){
            address feeTo = factory.getFeeToSetter();
            if(feeTo!=address(0x0)){
                ViaCash(address(uint160(cashContract))).transferFrom(cashContract, feeTo, ABDKMathQuad.toUInt(ABDKMathQuad.mul(fee, value)));
                returnValue = ABDKMathQuad.sub(value, ABDKMathQuad.mul(fee, value));
            }
        }
        return returnValue;
    }

    //check AML status for account address
    function amlCheck(address account) external returns(bool){
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBond");
        if(client==address(0x0)){
            client = factory.getClient();
            if(client==address(0x0))
                return true;
        }
        if(VerifiedClient(client).getAMLStatus(account))
            return true;
        else
            return false;
    }

}
