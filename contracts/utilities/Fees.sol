// (c) Kallol Borah, 2020
// Implementation of utility functions for fee payments
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

import "../interfaces/ViaFactory.sol";
import "../interfaces/ViaCash.sol";
import "abdk-libraries-solidity/ABDKMathQuad.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract Fees is Initializable{

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    ViaFactory private factory;

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
        require(factory.getTreasury()==msg.sender);
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
        bytes16 fee = ABDKMathQuad.add(factory.getFee("purchasing"),factory.getFee("selling"));
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

}
