// (c) Kallol Borah, 2020
// Implementation of the Via zero coupon bond.
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

import "./erc/ERC20.sol";
import "./interfaces/Oracle.sol";
import "./abdk-libraries-solidity/ABDKMathQuad.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "./interfaces/ViaFactory.sol";
import "./interfaces/ViaCash.sol";
import "./interfaces/ViaBond.sol";
import "./interfaces/ViaToken.sol";
import "./utilities/StringUtils.sol";

contract Bond is ViaBond, ERC20, Initializable, Ownable {

    using stringutils for *;

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    //via token factory address
    ViaFactory private factory;

    //via oracle
    Oracle private oracle;
    address viaoracle;

    //name of Via token (eg, Via-USD)
    string public name;
    string public symbol;
    bytes32 public bondName;
    
    //token address
    address private token;

    //a Via bond has some value, corresponds to a fiat currency
    //can have many purchasers and a issuer that have agreed to a zero coupon rate which determines the start price of the bond
    //and a tenure in unix timestamps of seconds counted from 1970-01-01. Via bonds are of one year tenure.
    struct bond{
        address[] counterParties;
        bytes16 parValue;
        bytes16 price;
        bytes16 purchasedIssueAmount;
        bytes16 paidInAmount;
        bytes32 paidInCurrency;
        uint256 timeIssuedOrSubscribed;
    }

    //mapping issuer (address) to address of bond token (address) which acts as identifier for bonds on offer
    mapping(address => mapping (address => bond)) public issues;

    //mapping purchaser (address) to address of bond token (address) which acts as identifier for bonds subscribed
    mapping(address => mapping (address => bond)) public purchases;

    //array of issues of this via bond, where bond IDs are their addresses of their token issues
    address[] private bondsIssued;

    //array of issuers
    address[] private issuers;

    //data structure holding details of currency conversion requests pending on oraclize
    struct conversion{
        bytes32 operation;
        address token;
        address party;
        bytes16 amount;
        bytes32 paid_in_currency;
        bytes32 EthXid;
        bytes16 EthXvalue;
        bytes32 bond_currency;
        bytes16 ViaXvalue;
        bytes32 ViaRateId;
        bytes16 ViaRateValue;
    }

    //queue of pending conversion requests with each pending request mapped to a request_id returned by oraclize
    mapping(bytes32 => conversion) private conversionQ;

    //events to capture and report to Via oracle
    event ViaBondIssued(address indexed token, bytes32 currency, uint256 value, uint256 price, uint256 tenure);
    event ViaBondRedeemed(bytes32 currency, uint256 value, uint256 price, uint256 tenure);
    event Log(bytes32 message);
    
    //mutex
    bool lock;

    //initiliaze proxies
    function initialize(bytes32 _name, bytes32 _type, address _owner, address _oracle, address _token) public initializer {
        Ownable.initialize(_owner);
        factory = ViaFactory(_owner);
        oracle = Oracle(_oracle);
        viaoracle = _oracle;
        name = string(abi.encodePacked(_name));
        symbol = string(abi.encodePacked(_type));
        bondName = _name;
        token = _token;
        lock = false;
        decimals = 2;
    }

    //handling pay in of ether for issue of via bond tokens
    function() external payable{
        //ether paid in
        require(msg.value !=0);
        //only to pay in ether
        require(msg.data.length==0);
        //issue via bond tokens
        issue(ABDKMathQuad.fromUInt(msg.value), msg.sender, "ether", address(this), address(0x0));
    }

    //forwarding call from issued bond token if at all such a call arrives
    function transferForward(bytes32 _symbol, address _forwarder, address _sender, address _receiver, uint256 _tokens) external returns (bool){
        require(factory.getProduct(_symbol)==_forwarder);
        if(transferFrom(_sender, _receiver, _tokens, _forwarder, _symbol))
            return true;
        else
            return false;
    }

    //overriding this function of ERC20 standard
    function transferFrom(address sender, address receiver, uint256 tokens, address forwarder, bytes32 bondSymbol) public returns (bool){
        //check if tokens are being transferred to this bond contract
        if(receiver == address(this) || receiver == forwarder){
            //if token name is the same, this transfer has to be redeemed
            if(redeem(ABDKMathQuad.fromUInt(tokens), sender, bondName, "ViaBond", forwarder))
                return true;
            else
                return false;
        }
        else if(factory.getProduct(bondSymbol)==forwarder){
            //bond tokens are being sent to a user account
            //sender is transferring its full purchase amount of bonds
            address issuedBond = factory.getProduct(bondSymbol);
            if(issuedBond!=address(0x0)){
                //transfer of bond token to another user has to be of the exact amount purchased earlier by sender
                if(ABDKMathQuad.cmp(purchases[sender][issuedBond].purchasedIssueAmount, ABDKMathQuad.fromUInt(tokens))==0){
                    if(ViaToken(issuedBond).transferToken(sender, receiver, tokens)){
                        purchases[receiver][issuedBond] = issues[sender][issuedBond];
                        delete purchases[sender][issuedBond];
                        return true;
                    }
                    else
                        return false;
                }
                return false;
            }
            return false;
        }
    }

    function requestIssue(bytes16 amount, address payer, bytes32 currency, address cashContract) external returns(bool){
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBondToken");
        if(factory.getType(msg.sender) == "ViaCash")
            return(issue(amount, payer, currency, cashContract, address(0x0)));
        else if(factory.getType(msg.sender) == "ViaBondToken")
            return(issue(amount, payer, currency, cashContract, msg.sender));
        else
            return false;
    }

    //requesting issue of Via bonds to payer (issuer) that can pay in ether, or 
    //requesting transfer of Via bonds to payer (buyer) that can pay in via cash tokens
    function issue(bytes16 amount, address payer, bytes32 currency, address cashContract, address tokenContract) private returns(bool){
        //ensure that brought amount is not zero
        require(amount != 0);
        //adds paid in amount to the paid in currency's cash balance
        if(currency!="ether")
            //non ether currency (or via cash tokens) can be paid in to purchase bonds by non-issuers or redeem bonds by issuer
            if(factory.getType(cashContract)=="ViaCash")
                if(!ViaCash(address(uint160(cashContract))).requestAddToBalance(amount, payer))
                    return false;
            else
                return false;
        //call Via Oracle to fetch data for bond pricing
        if(currency=="ether"){
            //if ether is paid into a non Via-USD bond contract, the bond contract will issue bond tokens of an equivalent face value.
            //To derive the bond's face value, the exchange rate of ether to Via-USD and then to the currency paid in is applied.
            if(bondName!="Via_USD"){
                //bytes32 EthXid = oracle.request("eth","ethusd","EthBond", address(this));
                //bytes32 ViaXid = oracle.request(string(abi.encodePacked("Via_USD_to_", bondName)).stringToBytes32(),"ver","EthBond", address(this));
                //oracle.setCallbackId(EthXid,ViaXid);
                bytes32 EthXid = "11";
                bytes32 ViaXid = "22";
                conversion memory c = conversionQ[ViaXid];
                c.operation = "issue";
                c.party = payer;
                c.amount = amount;
                c.paid_in_currency = currency;
                c.EthXid = EthXid;
                c.EthXvalue = ABDKMathQuad.fromUInt(0);
                c.bond_currency = bondName;
                c.ViaXvalue =ABDKMathQuad.fromUInt(0);
                emit Log("calling convert");
                convert("22","1.2","ver");
                convert("22","451.25","ethusd");
            }
            //if ether is paid into a Via-USD bond contract, issuing the bond token will only require the ether to Via-USD exchange rate. 
            else{
                //bytes32 EthXid = oracle.request("eth","ethusd","EthBond", address(this));
                bytes32 EthXid = "11";
                conversion memory c = conversionQ[EthXid];
                c.operation = "issue";
                c.party = payer;
                c.amount = amount;
                c.paid_in_currency = currency;
                c.EthXid = EthXid;
                c.EthXvalue = ABDKMathQuad.fromUInt(0);
                c.bond_currency = bondName;
                c.ViaXvalue =ABDKMathQuad.fromUInt(1);
                emit Log("calling convert");
                convert("11","451.25","ethusd");
            }
        }
        //if a via cash token is paid into this bond contract
        else{
            //if the via cash token paid in is different from the denomination of this bond, 
            //tokens of this bond need to be transferred from an issuers' account after pricing the bond with applicable coupon rates
            if(currency!=bondName){
                //bytes32 ViaXid = oracle.request(string(abi.encodePacked(currency, "_to_", bondName)).stringToBytes32(),"er","Bond", address(this));                
                //bytes32 ViaRateId;
                //if(currency!="Via_USD"){
                //    ViaRateId = oracle.request(string(abi.encodePacked("Via_USD_to_", currency)).stringToBytes32(), "ir","Bond",address(this));
                //}
                //else{
                //    ViaRateId = oracle.request("USD", "ir","Bond",address(this));
                //}
                bytes32 ViaXid = "33";
                bytes32 ViaRateId = "44";
                conversion memory c = conversionQ[ViaXid];
                c.operation = "purchase";
                c.token = tokenContract;
                c.party = payer;
                c.amount = amount;
                c.paid_in_currency = currency;
                c.bond_currency = bondName;
                c.ViaXvalue =ABDKMathQuad.fromUInt(0);
                c.ViaRateId = ViaRateId; 
                c.ViaRateValue = ABDKMathQuad.fromUInt(0);
                emit Log("calling convert");
                convert("33","7.6","er");
                convert("33","1.5","ir");
            }
            //if the via cash token paid in is the same denomination of this bond, we need to first find out if the pay in is for a purchase of bonds or repayment of an earlier issue
            else{
                if(tokenContract!=address(0x0)){
                    if(ABDKMathQuad.cmp(issues[payer][tokenContract].parValue, amount)==0 &&
                        issues[payer][tokenContract].counterParties[0]!=payer){
                        //if the paying in is for repayment of a bond already issued, then
                        //transfer the paid in amount to the bond holders, release the collateral back to the issuer and extinguish the bond
                        if(!redeem(amount, payer, currency, "ViaCash", tokenContract))
                            return false;
                    }
                }
                //if the paying in is not for repayment of a bond already issued, then
                //tokens of this bond need to be transferred from an issuer's account after pricing the bond with the domestic (paid in currency) coupon rates
                else{
                    //bytes32 ViaRateId = oracle.request(currency, "ir","Bond",address(this));
                    bytes32 ViaRateId = "44";
                    conversion memory c = conversionQ[ViaRateId];
                    c.operation = "purchase";
                    c.token = tokenContract;
                    c.party = payer;
                    c.amount = amount;
                    c.paid_in_currency = currency;
                    c.bond_currency = bondName;
                    c.ViaXvalue =ABDKMathQuad.fromUInt(1);
                    c.ViaRateId = ViaRateId; 
                    c.ViaRateValue = ABDKMathQuad.fromUInt(0);
                    emit Log("calling convert");
                    convert("44","1.5","ir");
                }                
            }
        }
        return true;
    }

    //requesting redemption of Via bonds and transfer of ether or via cash collateral to issuer 
    function redeem(bytes16 amount, address payer, bytes32 tokenName, bytes32 tokenType, address tokenContract) private returns(bool){
        //if Via bond holder redeems bond on day of expiry, issuer collateral is transferred to bond holder
        if(tokenType=="ViaBond"){
            bool status = false;
            //find if the bond was issued to payer (purchaser) earlier
            if(ABDKMathQuad.cmp(purchases[payer][tokenContract].purchasedIssueAmount, amount)==0){
                //calculate redemption amount based on duration of holding by bond subscriber
                uint256 subscribedDays = (purchases[payer][tokenContract].timeIssuedOrSubscribed - now)/ 60 / 60 / 24;
                bytes16 redemptionAmount = ABDKMathQuad.mul(ABDKMathQuad.mul(ABDKMathQuad.div(purchases[payer][tokenContract].parValue, purchases[payer][tokenContract].price), 
                                            ABDKMathQuad.div(ABDKMathQuad.fromUInt(subscribedDays),ABDKMathQuad.fromUInt(365))), purchases[payer][tokenContract].purchasedIssueAmount);
                require(!lock);
                lock = true;
                //if collateral is ether, transfer ether from issuer to purchaser (redeemer) of bond
                if(purchases[payer][tokenContract].paidInCurrency=="ether"){
                    //send redeemed ether to payer
                    address(uint160(payer)).transfer(ABDKMathQuad.toUInt(redemptionAmount));
                    status = true;
                }
                if(status){
                    //adjust total supply of this via bond
                    ViaToken(tokenContract).reduceSupply(amount);
                    //reduce payer's balance of bond held
                    ViaToken(tokenContract).reduceBalance(payer, amount);
                    //generate event
                    emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(redemptionAmount), ABDKMathQuad.toUInt(purchases[payer][tokenContract].purchasedIssueAmount), subscribedDays);
                    delete(purchases[payer][tokenContract]);
                    //delete(issues[payer][tokenContract].counterParties[p]);
                    lock = false;
                }
                else
                    lock = false;
            }
            //find if the bond was issued to payer (issuer) earlier
            if(ABDKMathQuad.cmp(ABDKMathQuad.sub(issues[payer][tokenContract].parValue, issues[payer][tokenContract].purchasedIssueAmount), amount)==0){
                require(!lock);
                lock = true;
                //calculate redemption amount based on how much collateral is not encumbered
                uint256 issuedDays = (issues[payer][tokenContract].timeIssuedOrSubscribed - now)/ 60 / 60 / 24;
                bytes16 uncumberedAmount = ABDKMathQuad.sub(issues[payer][tokenContract].parValue, issues[payer][tokenContract].purchasedIssueAmount);
                //if collateral is ether, transfer ether from issuer to issuer (redeemer) of bond
                if(issues[payer][tokenContract].paidInCurrency=="ether"){
                    //adjust total supply of this via bond
                    ViaToken(tokenContract).reduceSupply(amount);
                    //reduce payer's balance of bond held
                    ViaToken(tokenContract).reduceBalance(payer, amount);
                    //send redeemed ether to payer
                    address(uint160(payer)).transfer(ABDKMathQuad.toUInt(uncumberedAmount));
                    //generate event
                    emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(uncumberedAmount), ABDKMathQuad.toUInt(amount), issuedDays);
                    status = true;
                    lock = false;
                }
                if(status && ABDKMathQuad.cmp(issues[payer][tokenContract].paidInAmount, amount)==0){
                    //if bond is redeemed in full by issuer, then remove issue from list of issues
                    delete(issues[payer][tokenContract]);
                }
                else{
                    //else, if bond is redeemed partially by issuer, then adjust redeemed amount with collateral balance in purchaser accounts
                    for(uint256 p=0; p<issues[payer][tokenContract].counterParties.length; p++){
                        purchases[issues[payer][tokenContract].counterParties[p]][tokenContract].paidInAmount = 
                        ABDKMathQuad.sub(purchases[issues[payer][tokenContract].counterParties[p]][tokenContract].paidInAmount, uncumberedAmount);
                    }
                }   
            }
            return status;
        }
        //if Via bond issuer pays in cash for redemption, it is paid back to Via bond holders and collateral paid back to issuers
        else if(tokenType=="ViaCash"){
            address viaAddress;
            bool status = false;
            bytes16 totalToRedeem;
            //find the bond that was issued by payer (issuer) earlier
            if(ABDKMathQuad.cmp(amount, issues[payer][tokenContract].purchasedIssueAmount)==1){
                for(uint256 p=0; p<issues[payer][tokenContract].counterParties.length; p++){
                    address cp = issues[payer][tokenContract].counterParties[p];
                    //if collateral is ether, release collateral and transfer ether to issuer of bond
                    //and send paid in amount to purchaser of bond
                    if(issues[payer][tokenContract].paidInCurrency=="ether"){
                        //calculate redemption amount based on duration of holding by bond subscriber
                        uint256 subscribedDays = (purchases[cp][tokenContract].timeIssuedOrSubscribed - now)/ 60 / 60 / 24;
                        bytes16 redemptionAmount = ABDKMathQuad.mul(ABDKMathQuad.mul(ABDKMathQuad.div(purchases[cp][tokenContract].parValue, 
                                                    purchases[cp][tokenContract].price), 
                                                    ABDKMathQuad.div(ABDKMathQuad.fromUInt(subscribedDays),ABDKMathQuad.fromUInt(365))), 
                                                    purchases[cp][tokenContract].purchasedIssueAmount);
                        require(!lock);
                        lock = true;
                        //if amount available for redemption is more or equal to redemption amount for the purchaser
                        if(amount >= redemptionAmount){
                            //send paid in amount to bond purchaser
                            viaAddress = factory.getIssuer("ViaCash", tokenName);
                            if(viaAddress!=address(0x0)){
                                bytes16 balanceToRedeem = ViaCash(address(uint160(viaAddress))).requestDeductFromBalance(redemptionAmount, cp);
                                //adjust total supply of this via bond
                                ViaToken(tokenContract).reduceSupply(redemptionAmount);     
                                //reduce counter party's balance of bond held
                                ViaToken(tokenContract).reduceBalance(cp, redemptionAmount);
                                totalToRedeem = ABDKMathQuad.add(totalToRedeem, balanceToRedeem);
                                //if balance left to redeem is 0
                                if(balanceToRedeem==0){
                                    //adjust amount available for redemption 
                                    amount = ABDKMathQuad.sub(amount, redemptionAmount);
                                    //generate event
                                    emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(redemptionAmount), ABDKMathQuad.toUInt(purchases[cp][tokenContract].purchasedIssueAmount), subscribedDays);
                                    status = true; 
                                }
                                else{
                                    //adjust amount available for redemption 
                                    amount = ABDKMathQuad.sub(amount, ABDKMathQuad.sub(redemptionAmount, balanceToRedeem));
                                    //generate event
                                    emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(balanceToRedeem), ABDKMathQuad.toUInt(purchases[cp][tokenContract].purchasedIssueAmount), subscribedDays);
                                }
                            }
                            lock = false;
                        }
                        else
                            lock = false;  
                    }
                    if(status)
                        //if a purchaser is redeemed, then delete its record from list of purchases
                        delete(purchases[cp][tokenContract]);
                    if(p==issues[payer][tokenContract].counterParties.length-1)
                        //if all bond purchasers are redeemed, then delete the issuer record
                        delete(issues[payer][tokenContract]);
                }
                if(status){
                    //find proportion to redeem
                    bytes16 proportionToRedeem = ABDKMathQuad.div(totalToRedeem, issues[payer][tokenContract].purchasedIssueAmount);
                    //returned redeemed proportion of collateral to payer (issuer)
                    bytes16 etherToRedeem = ABDKMathQuad.mul(issues[payer][tokenContract].paidInAmount, ABDKMathQuad.sub(ABDKMathQuad.fromUInt(1), proportionToRedeem));
                    //send redeemed ether to payer
                    address(uint160(payer)).transfer(ABDKMathQuad.toUInt(etherToRedeem));   
                    //if any balance amount remains after redemptions, return the balance to the issuer
                    if(amount>0){
                        address(uint160(payer)).transfer(ABDKMathQuad.toUInt(amount));
                    }
                }
            }
            return status;
        }
    }

    //function called back from Oraclize
    function convert(bytes32 txId, bytes16 result, bytes32 rtype) public {
        //require(viaoracle == msg.sender);
        //check type of result returned
        if(rtype =="ethusd"){
            conversionQ[txId].EthXvalue = result;
        }
        if(rtype == "ir"){
            conversionQ[txId].ViaRateValue = result;
        }
        if(rtype == "er"){
            conversionQ[txId].EthXvalue = result;
        }
        if(rtype == "ver"){
            conversionQ[txId].ViaXvalue = result;
        }
        //check if bond needs to be issued
        if(conversionQ[txId].operation=="issue"){
            if(rtype == "ethusd" || rtype == "ver"){
                if(ABDKMathQuad.cmp(conversionQ[txId].EthXvalue, ABDKMathQuad.fromUInt(0))!=0 &&
                    ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0){
                    emit Log("converted");
                    //calculate par value of via bond by applying exchange rates from via oracle    
                    bytes16 parValue = convertToVia(conversionQ[txId].amount, conversionQ[txId].paid_in_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    //calculate price of via bond by applying interest rates from via oracle
                    bytes16 viaBondPrice = ABDKMathQuad.div(parValue, ABDKMathQuad.add(ABDKMathQuad.fromUInt(1), ABDKMathQuad.fromUInt(0)))^ABDKMathQuad.fromUInt(1);
                    //issue bond to issuer
                    finallyIssue(conversionQ[txId].party, parValue, viaBondPrice, conversionQ[txId].amount, conversionQ[txId].paid_in_currency, conversionQ[txId].token);
                }
            }
        }
        else if(conversionQ[txId].operation=="purchase"){
            if(rtype == "er" || rtype =="ir"){
                if(ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0 && 
                    ABDKMathQuad.cmp(conversionQ[txId].ViaRateValue, ABDKMathQuad.fromUInt(0))!=0){
                    //calculate par value of via bond by applying exchange rates from via oracle
                    bytes16 parValue = convertToVia(conversionQ[txId].amount, conversionQ[txId].paid_in_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    //calculate price of via bond by applying interest rates from via oracle
                    bytes16 viaBondPrice = ABDKMathQuad.div(parValue, ABDKMathQuad.add(ABDKMathQuad.fromUInt(1), conversionQ[txId].ViaRateValue))^ABDKMathQuad.fromUInt(1);
                    //transfer bond from issuer to purchaser, and transfer paid in cash token from purchaser to issuer
                    finallyIssue(conversionQ[txId].party, parValue, viaBondPrice, conversionQ[txId].amount, conversionQ[txId].paid_in_currency, conversionQ[txId].token);
                }
            }
        }
    }

    //issue bond tokens if ether is paid in, or transfer bond tokens if via cash tokens are paid in
    function finallyIssue(address payer, bytes16 parValue, bytes16 bondPrice, bytes16 paidInAmount, bytes32 paidInCashToken, address tokenContract) private {
        bool found = false;
        address issuedBond;
        if(paidInCashToken=="ether"){
            //issue bond tokens with paid in ether
            uint256 issueTime = now;
            //issue bond which initializes a token with the attributes of the bond
            issuedBond = factory.createToken(token, bondName, "ViaBond", string(abi.encodePacked(address(this),issueTime)).stringToBytes32());
            //adjust issued bonds to total supply first
            ViaToken(issuedBond).addTotalSupply(parValue);
            //first, add bond balance
            ViaToken(issuedBond).addBalance(issuedBond, parValue);
            emit Log("finally issuing");
            //issue bond to payer if ether is paid in as collateral
            if(ViaToken(issuedBond).requestTransfer(payer, ABDKMathQuad.toUInt(parValue))){    
                //keep track of issues
                storeBond("issue", payer, payer, parValue, bondPrice, ABDKMathQuad.fromUInt(0), paidInAmount, paidInCashToken, issueTime, issuedBond);
                bondsIssued.push(issuedBond);
                //keep track of issuers
                for(uint256 i=0; i<issuers.length; i++){
                    if(issuers[i]==payer){
                        found = true;
                        break;
                    }
                }
                if(!found)
                    issuers.push(payer);
            }
            //generate event
            emit ViaBondIssued(issuedBond, bondName, ABDKMathQuad.toUInt(parValue), ABDKMathQuad.toUInt(paidInAmount), 1);
        }
        //paid in amount is Via cash with which via bond tokens are purchased
        else{
            uint256 i;
            if(tokenContract!=address(0x0)){
                for(i=0; i<issuers.length; i++){
                    for(uint256 q=0; q<bondsIssued.length; q++){
                        if(bondsIssued[q]==tokenContract){
                            found = true;
                            break;
                        }
                    }
                }
            }
            else{
                //check if there are enough issued bonds to be purchased
                for(i=0; i<issuers.length; i++){
                    for(uint256 q=0; q<bondsIssued.length; q++){
                        if(ABDKMathQuad.cmp(ABDKMathQuad.sub(issues[issuers[i]][bondsIssued[q]].parValue, issues[issuers[i]][bondsIssued[q]].purchasedIssueAmount), paidInAmount)==0 ||
                        ABDKMathQuad.cmp(ABDKMathQuad.sub(issues[issuers[i]][bondsIssued[q]].parValue, issues[issuers[i]][bondsIssued[q]].purchasedIssueAmount), paidInAmount)==1){
                            found = true;
                            tokenContract = bondsIssued[q];
                            break;
                        }
                    }
                }
            }        
            if(found){
                require(!lock);
                lock = true;
                //if there is enough issued bonds, transfer bond from issuer to payer
                if(ViaToken(tokenContract).transferToken(issuers[i], payer, ABDKMathQuad.toUInt(paidInAmount))){
                    //transfer cash paid in by purchaser to issuer from whom bond is transferred to purchaser
                    address viaAddress = factory.getIssuer("ViaCash", paidInCashToken);
                    if(viaAddress!=address(0x0)){
                        //deduct paid out cash token from purchaser cash balance and transfer to issuer
                        ViaCash(address(uint160(viaAddress))).transferFrom(address(uint160(viaAddress)), issuers[i], ABDKMathQuad.toUInt(bondPrice));
                        //add purchaser as counter party in issuer's record
                        if(issues[issuers[i]][tokenContract].counterParties.length==1)
                            issues[issuers[i]][tokenContract].counterParties[0] = payer;
                        else
                            issues[issuers[i]][tokenContract].counterParties[issues[issuers[i]][tokenContract].counterParties.length] = payer;
                        //reduce issuable value of bond by amount transferred to purchaser
                        issues[issuers[i]][tokenContract].purchasedIssueAmount = ABDKMathQuad.add(issues[issuers[i]][tokenContract].purchasedIssueAmount, paidInAmount); 
                        //add bond to purchaser's record
                        storeBond("purchase", payer, issuers[i], parValue, bondPrice, issues[issuers[i]][tokenContract].purchasedIssueAmount, bondPrice, paidInCashToken, now, tokenContract);
                        lock = false;
                    }
                    else
                        lock = false;         
                }
                else
                    lock = false;
            }    
            //emit bond purchased event    
        }
    }

    //convert given currency and amount to via cash token
    function convertToVia(bytes16 amount, bytes32 currency, bytes16 ethusd, bytes16 viarate) private view returns(bytes16){
        if(currency=="ether"){
            //to first convert amount of ether passed to this function to USD
            bytes16 amountInUSD = ABDKMathQuad.mul(ABDKMathQuad.div(amount, ABDKMathQuad.fromUInt(1000000000000000000)), ethusd);
            //to then convert USD to Via-currency if currency of this contract is not USD itself
            if(bondName!="Via_USD"){
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

    //stores issued and purchased bond details
    function storeBond( bytes32 _operation,
                        address _payer,
                        address _party,
                        bytes16 _parValue,
                        bytes16 _bondPrice,
                        bytes16 _purchasedIssueAmount,
                        bytes16 _paidInAmount,
                        bytes32 _paidInCashToken,
                        uint256 _timeIssued,
                        address _issuedBond) private {
        if(_operation=="issue"){
            issues[_payer][_issuedBond].counterParties[0] = _party;
            issues[_payer][_issuedBond].parValue = _parValue;
            issues[_payer][_issuedBond].price = _bondPrice;
            issues[_payer][_issuedBond].purchasedIssueAmount = _purchasedIssueAmount;
            issues[_payer][_issuedBond].paidInAmount = _paidInAmount;
            issues[_payer][_issuedBond].paidInCurrency = _paidInCashToken;
            issues[_payer][_issuedBond].timeIssuedOrSubscribed = _timeIssued;
        }
        else if(_operation=="purchase"){
            purchases[_payer][_issuedBond].counterParties[0] = _party;
            purchases[_payer][_issuedBond].parValue = _parValue;
            purchases[_payer][_issuedBond].price = _bondPrice;
            purchases[_payer][_issuedBond].purchasedIssueAmount = _purchasedIssueAmount;
            purchases[_payer][_issuedBond].paidInAmount = _paidInAmount;
            purchases[_payer][_issuedBond].paidInCurrency = _paidInCashToken;
            purchases[_payer][_issuedBond].timeIssuedOrSubscribed = _timeIssued;
        }
    }

}
