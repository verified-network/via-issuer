// (c) Kallol Borah, 2020
// Test cases for cash tokens

const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

const Factory = artifacts.require('Factory');
const Cash = artifacts.require('Cash');
const Fees = artifacts.require('Fees');
const ABDKMathQuad = artifacts.require('ABDKMathQuad');
const Oracle = artifacts.require('Oracle');
const Token = artifacts.require('Token');

web3.setProvider("http://localhost:8545");

contract("Cash contract testing", async (accounts) => {
  
  var getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }
  
  //test 1
  it("get the size of the Cash contract", function() {
    return Cash.deployed().then(function(instance) {
      var bytecode = instance.constructor._json.bytecode;
      var deployed = instance.constructor._json.deployedBytecode;
      var sizeOfB  = bytecode.length / 2;
      var sizeOfD  = deployed.length / 2;
      console.log("size of bytecode in bytes = ", sizeOfB);
      console.log("size of deployed in bytes = ", sizeOfD);
      console.log("initialisation and constructor code in bytes = ", sizeOfB - sizeOfD);
    });  
  });
  
  //test 2
  it("should send ether to Via-USD cash contract and then get some Via-USD cash tokens", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed(); 
    var token = await Token.deployed();   
    var fee = await Fees.deployed();
    
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
    
    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    console.log(viausdCashName, viausdCashType, "token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log();

    console.log("Via oracle ether balance before query:", await web3.eth.getBalance(oracle.address));
    await viausdCash.sendTransaction({from:accounts[0], to:viausdCashAddress, value:1e18});
    console.log("Via-USD cash token contract ether balance after sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  
       
    try{
      await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    }catch(error){
      console.log(error);
    }
    
    console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));
    console.log("Account Via-USD cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
  });
  
  //test 3
  it("should send ether to Via-EUR cash contract and then get some Via-EUR cash tokens", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed();  
    var fee = await Fees.deployed();
    
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
    
    var viaeurCashAddress = await factory.tokens(1);
    var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
    var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
    var viaeurCash = await Cash.at(viaeurCashAddress);

    console.log(viaeurCashName, viaeurCashType, "token address:", viaeurCashAddress);
    console.log(viaeurCashName, viaeurCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-EUR cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    console.log();

    console.log("Via oracle ether balance before query:", await web3.eth.getBalance(oracle.address));
    await viaeurCash.sendTransaction({from:accounts[0], to:viaeurCashAddress, value:1e18});
    console.log("Via-EUR cash token contract ether balance after sending ether:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  
    
    try{
      await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    }catch(error){
      console.log(error);
    }
    
    console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));
    console.log("Account Via-EUR cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));

  });

  //test 4
  it("should send Via-EUR tokens to Via-INR contract and get Via-INR equivalent to paid in Via-EUR", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
      await Cash.link(abdkMathQuad);

      var factory = await Factory.deployed();
      var cash = await Cash.deployed();
      var oracle = await Oracle.deployed();  
      var token = await Token.deployed();  
      var fee = await Fees.deployed();
      
      await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_INR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
      
      var viainrCashAddress = await factory.tokens(2);
      var viainrCashName = await web3.utils.hexToUtf8(await factory.getName(viainrCashAddress));
      var viainrCashType = await web3.utils.hexToUtf8(await factory.getType(viainrCashAddress));
      var viainrCash = await Cash.at(viainrCashAddress);

      var viaeurCashAddress = await factory.tokens(1);
      var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
      var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
      var viaeurCash = await Cash.at(viaeurCashAddress);

      console.log(viainrCashName, viainrCashType, "token address:", viainrCashAddress);
      console.log("Account address:", accounts[0]);
      console.log("Account Via-EUR cash token balance before sending Via-EUR to Via-INR contract : ", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
      console.log("Account Via-INR cash token balance before sending Via-EUR to Via-INR contract : ", await web3.utils.hexToNumberString(await web3.utils.toHex(await viainrCash.balanceOf(accounts[0]))));
      console.log();
      
      await viaeurCash.transferFrom(accounts[0], viainrCashAddress, 10);
      
      try{
        await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      }catch(error){
        console.log(error);
      }
      
      console.log("Account Via-EUR cash token balance after sending Via-EUR to Via-INR contract :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
      console.log("Account Via-INR cash token balance after sending Via-EUR to Via-INR contract :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viainrCash.balanceOf(accounts[0]))));
  });
  
  //test 5
  it("should send Via-USD to Via-USD cash contract and then get ether sent during issuing process", async () => {

    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed(); 
    var fee = await Fees.deployed();
    
    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);
    
    console.log(viausdCashName, viausdCashType, "token address:", viausdCashAddress);
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before redeeming Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance before redeeming Via-USD :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Via-USD cash token contract ether balance before redeeming Via-USD:", await web3.eth.getBalance(viausdCashAddress));

    await viausdCash.transferFrom(accounts[0], viausdCashAddress, 10);
    
    try{
      await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    }catch(error){
      console.log(error);
    }
    
    console.log("Account ether balance after redeeming Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance after redeeming Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Via-USD cash token contract ether balance after redeeming Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    
  });
  
  //test 6
  it("should send Via-EUR tokens to Via-EUR contract and get back ether paid in earlier", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
      await Cash.link(abdkMathQuad);

      var factory = await Factory.deployed();
      var cash = await Cash.deployed();
      var oracle = await Oracle.deployed();  
      var token = await Token.deployed();  
      var fee = await Fees.deployed();
      
      var viaeurCashAddress = await factory.tokens(1);
      var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
      var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
      var viaeurCash = await Cash.at(viaeurCashAddress);

      console.log(viaeurCashName, viaeurCashType, "token address:", viaeurCashAddress);
      console.log("Account ether balance before redeeming Via-EUR:", await web3.eth.getBalance(accounts[0]));
      console.log("Via-EUR cash token contract ether balance before redeeming Via-EUR:", await web3.eth.getBalance(viaeurCashAddress));
      console.log("Account Via-EUR cash token balance before sending Via-EUR:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
      console.log();
      
      await viaeurCash.transferFrom(accounts[0], viaeurCashAddress, 10);
      
      try{
        await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      }catch(error){
        console.log(error);
      }
      
      console.log("Account ether balance after redeeming Via-EUR:", await web3.eth.getBalance(accounts[0]));
      console.log("Via-EUR cash token contract ether balance after redeeming Via-EUR:", await web3.eth.getBalance(viaeurCashAddress));
      console.log("Account Via-EUR cash token balance after sending Via-EUR:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
  
  });

  //test 7
  it("should redeem Via-INR tokens by sending them to Via-EUR contract and get Via-EUR paid in earlier", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
      await Cash.link(abdkMathQuad);

      var factory = await Factory.deployed();
      var cash = await Cash.deployed();
      var oracle = await Oracle.deployed();  
      var token = await Token.deployed();  
      var fee = await Fees.deployed();
      
      var viainrCashAddress = await factory.tokens(2);
      var viainrCashName = await web3.utils.hexToUtf8(await factory.getName(viainrCashAddress));
      var viainrCashType = await web3.utils.hexToUtf8(await factory.getType(viainrCashAddress));
      var viainrCash = await Cash.at(viainrCashAddress);

      var viaeurCashAddress = await factory.tokens(1);
      var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
      var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
      var viaeurCash = await Cash.at(viaeurCashAddress);

      console.log("Account Via-EUR cash token balance before sending Via-INR to Via-EUR contract : ", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
      console.log("Account Via-INR cash token balance before sending Via-INR to Via-EUR contract : ", await web3.utils.hexToNumberString(await web3.utils.toHex(await viainrCash.balanceOf(accounts[0]))));
      console.log();
      
      await viainrCash.transferFrom(accounts[0], viaeurCashAddress, 100);
      
      try{
        await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      }catch(error){
        console.log(error);
      }
      
      console.log("Account Via-EUR cash token balance after redeeming Via-INR :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
      console.log("Account Via-INR cash token balance after redeeming Via-INR :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viainrCash.balanceOf(accounts[0]))));
  });
  
  //test 8
  it("should transfer Via-USD to another account", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed(); 
    var token = await Token.deployed();  
    var fee = await Fees.deployed();
    
    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    console.log("Sender address:", accounts[0]);
    console.log("Sender ether balance before sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-USD cash token balance before transferring Via-USD :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Receiver ether balance before Via-USD is sent by sender:", await web3.eth.getBalance(accounts[1]));
    console.log();
    
    await viausdCash.transferFrom(accounts[0], accounts[1], 100);
    
    try{
      await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    }catch(error){
      console.log(error);
    }
    
    console.log("Sender ether balance after sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-USD cash token balance after transferring Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Receiver ether balance after Via-USD is sent by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-USD cash token balance after receiving Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
  
  });

  //test 9
  it("should redeem transferred Via-USD tokens from one user account to get back ether paid in another account", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed(); 
    var token = await Token.deployed();  
    var fee = await Fees.deployed();
    
    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    console.log(viausdCashName, viausdCashType, "token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, "token contract ether balance before redeeming Via-USD :", await web3.eth.getBalance(viausdCashAddress));
    console.log("Redeemer Ether balance before redemption :", await web3.eth.getBalance(accounts[1]));
    console.log("Redeemer Via-USD cash token balance before redemption :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    console.log();
    
    await viausdCash.transferFrom(accounts[1], viausdCashAddress, 50);
    
    try{
      await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      //await getFirstEvent(cash.ViaCashRedeemed({fromBlock:'latest'}));
    }catch(error){
      console.log(error);
    }
    
    console.log("Via-USD cash token contract ether balance after redeeming Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Redeemer ether balance after redeeming Via-USD:", await web3.eth.getBalance(accounts[1]));
    console.log("Redeemer account Via-USD cash token balance after redeeming Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
  
  });

});



