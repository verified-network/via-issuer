// (c) Kallol Borah, 2020
// Implementation of utility functions for cash and bond tokens
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

import "abdk-libraries-solidity/ABDKMathQuad.sol";

library paymentutils {

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    //get Via exchange rates from oracle and convert given currency and amount to via cash token
    function convertToVia(bytes32 tokenName, bytes16 amount, bytes32 paid_in_currency, bytes16 ethusd, bytes16 viarate) public pure returns(bytes16){
        if(paid_in_currency=="ether"){
            //to first convert amount of ether passed to this function to USD
            bytes16 amountInUSD = ABDKMathQuad.div(ABDKMathQuad.mul(amount, ethusd), ABDKMathQuad.fromUInt(1000000000000000000));
            //bytes16 amountInUSD = ABDKMathQuad.mul(ABDKMathQuad.div(amount, ABDKMathQuad.fromUInt(1000000000000000000)), ethusd);
            //to then convert USD to Via-currency if currency of this contract is not USD itself
            if(tokenName!="Via_USD"){
                bytes16 inVia = ABDKMathQuad.mul(amountInUSD, viarate);
                return inVia;
            }
            else{
                return amountInUSD;
            }
        }
        //if currency paid in another via currency
        else{
            bytes16 inVia = ABDKMathQuad.mul(amount, viarate);
            return inVia;
        }
    }

    //convert Via-currency (eg, Via-EUR, Via-INR, Via-USD) to Ether or another Via currency
    //viarate is 1 if pay out currency is ether and this via cash token to redeem is Via-USD, otherwise viarate is exchange rate between this cash token to Via-USD
    //if pay out currency is not ether, then viarate is exchange rate between this cash token and cash token to pay out 
    function convertFromVia(bytes16 amount, bytes32 payout_currency, bytes16 ethusd, bytes16 viarate) public pure returns(bytes16){
        //if currency to convert to is ether
        if(payout_currency=="ether"){
            bytes16 amountInViaUSD = ABDKMathQuad.mul(amount, viarate);
            bytes16 inEth = ABDKMathQuad.div(amountInViaUSD, ethusd);
            return inEth;
        }
        //else convert to another via currency
        else{
            return ABDKMathQuad.mul(viarate, amount);
        }
    }   

}