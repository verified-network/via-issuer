// (c) Kallol Borah, 2020
// Test cases for bond tokens

const assert = require("chai").assert;
var truffleAssert = require('truffle-assertions');
var truffleEvent  = require('truffle-events');

const Factory = artifacts.require('Factory');
const Cash = artifacts.require('Cash');
const Bond = artifacts.require('Bond');
const Fees = artifacts.require('Fees');
const ABDKMathQuad = artifacts.require('ABDKMathQuad');
const Oracle = artifacts.require('Oracle');
const Token = artifacts.require('Token');

web3.setProvider("http://127.0.0.1:8545");

contract("Bond contract testing", async (accounts) => {

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }
  
  //test 1
  it("get the size of the Bond contract", function() {
    return Bond.deployed().then(function(instance) {
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
  it("should send ether to Via-USD bond contract and then get some Via-USD bond tokens to sender (issuer)", async () => {
      var abdkMathQuad = await ABDKMathQuad.deployed();
      await Bond.link(abdkMathQuad);

      var factory = await Factory.deployed();
      var bond = await Bond.deployed();
      var oracle = await Oracle.deployed();  
      var token = await Token.deployed();  
      var fee = await Fees.deployed();
      
      await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
      
      var viausdBondAddress = await factory.tokens(3);
      var viausdBondName = await web3.utils.hexToUtf8(await factory.getName(viausdBondAddress));
      var viausdBondType = await web3.utils.hexToUtf8(await factory.getType(viausdBondAddress));
      var viausdBond = await Bond.at(viausdBondAddress);

      console.log(viausdBondName, viausdBondType, " contract address:", viausdBondAddress);
      console.log(viausdBondName, viausdBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viausdBondAddress));
      console.log("Account address:", accounts[0]);
      console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
      console.log();

      console.log("Via oracle ether balance before query:", await web3.eth.getBalance(oracle.address));
      await viausdBond.sendTransaction({from:accounts[0], to:viausdBondAddress, value:1e18});
      console.log("Via-USD bond contract ether balance after sending ether:", await web3.eth.getBalance(viausdBondAddress));
      console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  
        
      var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
      let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
      truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
        emittedTokenAddress = ev._address;
        return ev._address;
      });
            
      viausdBondToken = await Token.at(emittedTokenAddress);
      console.log("Via USD bond token address :", emittedTokenAddress);
      console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));
      console.log("Account Via-USD bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBondToken.balanceOf(accounts[0]))));
      
  });
  /*  
  //test 3
  it("should transfer Via-USD bond to another account", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Bond.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var bond = await Bond.deployed();
    var oracle = await Oracle.deployed(); 
    var token = await Token.deployed();
    var fee = await Fees.deployed();   
    
    await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
    
    var viausdBondAddress = await factory.tokens(3);
    var viausdBondName = await web3.utils.hexToUtf8(await factory.getName(viausdBondAddress));
    var viausdBondType = await web3.utils.hexToUtf8(await factory.getType(viausdBondAddress));
    var viausdBond = await Bond.at(viausdBondAddress);

    console.log(viausdBondName, viausdBondType, " contract address:", viausdBondAddress);
    console.log(viausdBondName, viausdBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viausdBondAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log();

    await viausdBond.sendTransaction({from:accounts[0], to:viausdBondAddress, value:1e18});
    console.log("Via-USD bond contract ether balance after sending ether:", await web3.eth.getBalance(viausdBondAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  

    var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
    let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
    truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
      emittedTokenAddress = ev._address;
      return ev._address;
    });
          
    viausdBondToken = await Token.at(emittedTokenAddress);
    console.log("Receiver address:", accounts[1]);
    console.log("Receiver ether balance before Via-USD bond is transferred by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-USD bond token balance before receiving Via-USD bond:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBondToken.balanceOf(accounts[1]))));
    console.log();
    
    await viausdBondToken.transferFrom(accounts[0], accounts[1], 10);

    console.log("Sender ether balance after transferring Via-USD bond:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-USD bond token balance after transferring Via-USD bond:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBondToken.balanceOf(accounts[0]))));
    console.log("Receiver ether balance after Via-USD bond is transferred by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-USD bond token balance after receiving Via-USD bond:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBondToken.balanceOf(accounts[1]))));
  
  });
  
  //test 4
  it("should send ether to Via-EUR bond contract and issue Via-EUR bonds to sender (issuer)", async () => {
    //this case is similar to the Via-USD Bond issue above
    //only difference is that this test requires two calls to the oracle instead of one in the Via-USD case
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Bond.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var bond = await Bond.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed();
    var fee = await Fees.deployed();  
    
    await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
    
    var viaeurBondAddress = await factory.tokens(4);
    var viaeurBondName = await web3.utils.hexToUtf8(await factory.getName(viaeurBondAddress));
    var viaeurBondType = await web3.utils.hexToUtf8(await factory.getType(viaeurBondAddress));
    var viaeurBond = await Bond.at(viaeurBondAddress);

    console.log(viaeurBondName, viaeurBondType, " contract address:", viaeurBondAddress);
    console.log(viaeurBondName, viaeurBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log();

    await viaeurBond.sendTransaction({from:accounts[0], to:viaeurBondAddress, value:1e18});
    console.log("Via-EUR bond contract ether balance after sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  

    var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
    let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
    truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
      emittedTokenAddress = ev._address;
      return ev._address;
    });
          
    viaeurBondToken = await Token.at(emittedTokenAddress);

    console.log("Account Via-EUR bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[0]))));
        
  });
  
  // test 5
  it("should send Via-USD cash tokens to Via-EUR bond contract and issue Via-EUR bonds to sender (purchaser)", async () => {
    //in this test cases, first ether should be sent from account[0] to Via-EUR bond contract to issue Via-EUR bonds to issuer
    //then, Via-USD cash tokens should be sent from account[1] to the Via-EUR bond contract which will transfer the issued Via-EUR bonds to the sender of the Via-USD cash tokens(purchaser)
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Bond.link(abdkMathQuad);
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var bond = await Bond.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed();
    var fee = await Fees.deployed();  
    
    await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
    
    var viaeurBondAddress = await factory.tokens(4);
    var viaeurBondName = await web3.utils.hexToUtf8(await factory.getName(viaeurBondAddress));
    var viaeurBondType = await web3.utils.hexToUtf8(await factory.getType(viaeurBondAddress));
    var viaeurBond = await Bond.at(viaeurBondAddress);

    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    console.log(viaeurBondName, viaeurBondType, " contract address:", viaeurBondAddress);
    console.log(viaeurBondName, viaeurBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log();

    await viaeurBond.sendTransaction({from:accounts[0], to:viaeurBondAddress, value:1e18});
    console.log("Via-EUR bond contract ether balance after sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  

    var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
    let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
    truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
      emittedTokenAddress = ev._address;
      return ev._address;
    });
          
    viaeurBondToken = await Token.at(emittedTokenAddress);

    console.log("Account Via-EUR bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[0]))));

    console.log(viausdCashName, viausdCashType, " cash contract address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, " cash contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account address:", accounts[1]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[1]));
    console.log("Account Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    console.log();

    await viausdCash.sendTransaction({from:accounts[1], to:viausdCashAddress, value:1e18});
    console.log("Via-USD cash token contract ether balance after sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[1]));  
    
    await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    console.log("Account Via-USD cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    
    await viausdCash.transferFrom(accounts[1], viaeurBondToken, 100);
    console.log("Purchaser Account Via-USD cash token balance after sending Via-USD for Via-EUR bond purchase:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    
    await getFirstEvent(bond.ViaBondPurchased({fromBlock:'latest'}));
    console.log("Purchaser Account Via-EUR bond token balance after purchase with Via-USD cash :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[1]))));
        
  });

  // test 6
  it("should send Via-EUR cash tokens to Via-EUR bond contract and issue Via-EUR to sender (purchaser)", async () => {
    //in this test cases, first ether should be sent from account[0] to Via-EUR bond contract to issue Via-EUR bonds to issuer
    //then, Via-EUR cash tokens should be sent from account[1] to the Via-EUR bond contract which will transfer the issued Via-EUR bonds to the sender of the Via-EUR cash tokens(purchaser)
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Bond.link(abdkMathQuad);
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var bond = await Bond.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed();
    var fee = await Fees.deployed();  
    
    await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
    
    var viaeurBondAddress = await factory.tokens(4);
    var viaeurBondName = await web3.utils.hexToUtf8(await factory.getName(viaeurBondAddress));
    var viaeurBondType = await web3.utils.hexToUtf8(await factory.getType(viaeurBondAddress));
    var viaeurBond = await Bond.at(viaeurBondAddress);

    var viaeurCashAddress = await factory.tokens(0);
    var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
    var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
    var viaeurCash = await Cash.at(viaeurCashAddress);

    console.log(viaeurBondName, viaeurBondType, " contract address:", viaeurBondAddress);
    console.log(viaeurBondName, viaeurBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log();

    await viaeurBond.sendTransaction({from:accounts[0], to:viaeurBondAddress, value:1e18});
    console.log("Via-EUR bond token contract ether balance after sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  

    var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
    let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
    truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
      emittedTokenAddress = ev._address;
      return ev._address;
    });
          
    viaeurBondToken = await Token.at(emittedTokenAddress);

    console.log("Account Via-EUR bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[0]))));

    console.log(viaeurCashName, viaeurCashType, "cash contract address:", viaeurCashAddress);
    console.log(viaeurCashName, viaeurCashType, "cash contract ether balance before sending ether:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account address:", accounts[1]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[1]));
    console.log("Account Via-EUR cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[1]))));
    console.log();

    await viaeurCash.sendTransaction({from:accounts[1], to:viaeurCashAddress, value:1e18});
    console.log("Via-EUR cash token contract ether balance after sending ether:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[1]));  
    
    await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    console.log("Account Via-EUR cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[1]))));
    
    await viaeurCash.transferFrom(accounts[1], viaeurBondToken, 100);
    console.log("Purchaser Account Via-EUR cash token balance after sending Via-EUR for Via-EUR bond purchase:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[1]))));
    
    await getFirstEvent(bond.ViaBondPurchased({fromBlock:'latest'}));
    console.log("Purchaser Account Via-EUR bond token balance after purchase with Via-EUR cash :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[1]))));
        
  });

  // test 7
  it("should send Via-USD bond tokens to Via-USD bond contract and get back ether paid in earlier", async () => {
    //in this test cases, first ether should be sent from account[0] to Via-USD bond contract to issue Via-USD bonds to issuer
    //then, the same Via-USD bond tokens should be sent from account[0] to the Via-USD bond contract which will transfer the ether paid in earlier to the sender of Via-USD bond tokens (issuer)
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Bond.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var bond = await Bond.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed();
    var fee = await Fees.deployed();  
    
    await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
    
    var viausdBondAddress = await factory.tokens(3);
    var viausdBondName = await web3.utils.hexToUtf8(await factory.getName(viausdBondAddress));
    var viausdBondType = await web3.utils.hexToUtf8(await factory.getType(viausdBondAddress));
    var viausdBond = await Bond.at(viausdBondAddress);

    console.log(viausdBondName, viausdBondType, " contract address:", viausdBondAddress);
    console.log(viausdBondName, viausdBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viausdBondAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log();

    await viausdBond.sendTransaction({from:accounts[0], to:viausdBondAddress, value:1e18});
    console.log("Via-USD bond token contract ether balance after sending ether:", await web3.eth.getBalance(viausdBondAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  

    var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
    let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
    truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
      emittedTokenAddress = ev._address;
      return ev._address;
    });
          
    viausdBondToken = await Token.at(emittedTokenAddress);

    console.log("Account Via-USD bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBondToken.balanceOf(accounts[0]))));
    
    await viausdBond.transferFrom(accounts[0], viausdBondToken, 100);
    
    await getFirstEvent(bond.ViaBondRedeemed({fromBlock:'latest'}));

    console.log("Via-USD bond token contract ether balance after redeeming Via-USD bonds:", await web3.eth.getBalance(viausdBondToken));
    console.log("Account ether balance after redeeming Via-USD bonds:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD bond token balance after redeeming Via-USD bonds:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBondToken.balanceOf(accounts[0]))));

  });

  // test 8
  it("should send Via-EUR cash tokens to Via-EUR bond contract and pay out paid in ether and cash tokens by bond purchasers", async () => {
    //in this test cases, first ether should be sent from account[0] to Via-EUR bond contract to issue Via-EUR bonds to issuer
    //then, Via-USD cash tokens should be sent from account[1] to the Via-EUR bond contract to purchase Via-EUR bond tokens issued
    //then, issuer of Via-EUR bonds (account[0]) should send Via-EUR cash tokens to the Via-EUR bond contract which will return Via-USD cash to account[1] paid in earlier
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Bond.link(abdkMathQuad);
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var bond = await Bond.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed();
    var fee = await Fees.deployed();  
    
    await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
    
    var viaeurBondAddress = await factory.tokens(4);
    var viaeurBondName = await web3.utils.hexToUtf8(await factory.getName(viaeurBondAddress));
    var viaeurBondType = await web3.utils.hexToUtf8(await factory.getType(viaeurBondAddress));
    var viaeurBond = await Bond.at(viaeurBondAddress);

    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    var viaeurCashAddress = await factory.tokens(1);
    var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
    var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
    var viaeurCash = await Cash.at(viaeurCashAddress);

    console.log(viaeurBondName, viaeurBondType, " contract address:", viaeurBondAddress);
    console.log(viaeurBondName, viaeurBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log();

    await viaeurBond.sendTransaction({from:accounts[0], to:viaeurBondAddress, value:1e18});
    console.log("Via-EUR bond token contract ether balance after sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  

    var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
    let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
    truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
      emittedTokenAddress = ev._address;
      return ev._address;
    });
          
    viaeurBondToken = await Token.at(emittedTokenAddress);

    console.log("Account Via-EUR bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[0]))));

    console.log(viausdCashName, viausdCashType, " cash token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, " cash token contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account address:", accounts[1]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[1]));
    console.log("Account Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    console.log();

    await viausdCash.sendTransaction({from:accounts[1], to:viausdCashAddress, value:1e18});
    console.log("Via-USD cash token contract ether balance after sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[1]));  
    
    await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    console.log("Account Via-USD cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    
    await viausdCash.transferFrom(accounts[1], viaeurBondToken, 100);
    console.log("Account Via-USD cash token balance after sending Via-USD for Via-EUR bond purchase:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    
    await getFirstEvent(bond.ViaBondPurchased({fromBlock:'latest'}));
    console.log("Account Via-EUR bond token balance after purchase with Via-USD cash :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[1]))));
    
    await viaeurCash.sendTransaction({from:accounts[0], to:viaeurCashAddress, value:1e18});
    console.log("Via-EUR cash token contract ether balance after sending ether:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  
    
    await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    console.log("Issuer Account Via-EUR cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    
    await viaeurCash.transferFrom(accounts[0], viaeurBondToken, 1);
    console.log("Issuer Account Via-EUR cash token balance after sending Via-EUR for Via-EUR bond redemption:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    
    await getFirstEvent(bond.ViaBondRedeemed({fromBlock:'latest'}));
    console.log("Purchaser Account Via-USD cash token balance after redemption with Via-EUR cash :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[1]))));
    console.log("Issuer Account ether balance after redeeming Via-EUR bonds with Via-EUR cash:", await web3.eth.getBalance(accounts[0]));
  
  });

  // test 9
  it("should send collateral for issuing bonds to purchasers if bond redemption is not done by issuer", async () => {
    //in this test case, first ether should be sent from account[0] to Via-EUR bond contract to issue Via-EUR bonds to issuer
    //then, account[1] should send Via-USD cash tokens to the Via-EUR bond contract to purchase the issued Via-EUR bonds
    //then, account[1] should send the Via-EUR bond tokens back to the Via-EUR bond contract which should pay out the ether paid in for issue of the Via-EUR bonds to account[1] (the purchaser)
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Bond.link(abdkMathQuad);
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var bond = await Bond.deployed();
    var cash = await Cash.deployed();
    var oracle = await Oracle.deployed();  
    var token = await Token.deployed();
    var fee = await Fees.deployed();  
    
    await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
    
    var viaeurBondAddress = await factory.tokens(4);
    var viaeurBondName = await web3.utils.hexToUtf8(await factory.getName(viaeurBondAddress));
    var viaeurBondType = await web3.utils.hexToUtf8(await factory.getType(viaeurBondAddress));
    var viaeurBond = await Bond.at(viaeurBondAddress);

    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    console.log(viaeurBondName, viaeurBondType, " contract address:", viaeurBondAddress);
    console.log(viaeurBondName, viaeurBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log();

    await viaeurBond.sendTransaction({from:accounts[0], to:viaeurBondAddress, value:1e18});
    console.log("Via-EUR bond token contract ether balance after sending ether:", await web3.eth.getBalance(viaeurBondAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  

    var rcpt = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}));
    let tx = await truffleAssert.createTransactionResult(factory,rcpt.transactionHash);
    truffleAssert.eventEmitted(tx, 'TokenCreated', (ev) => {
      emittedTokenAddress = ev._address;
      return ev._address;
    });
          
    viaeurBondToken = await Token.at(emittedTokenAddress);

    console.log("Account Via-EUR bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBondToken.balanceOf(accounts[0]))));

    console.log(viausdCashName, viausdCashType, "Cash token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, "Cash token contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account address:", accounts[1]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[1]));
    console.log("Account Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    console.log();

    await viausdCash.sendTransaction({from:accounts[1], to:viausdCashAddress, value:1e18});
    console.log("Via-USD cash token contract ether balance after sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[1]));  
    
    await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    console.log("Account Via-USD cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    
    await viausdCash.transferFrom(accounts[1], viaeurBondAddress, 100);
    console.log("Account Via-USD cash token balance after sending Via-USD for Via-EUR bond purchase:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    
    await getFirstEvent(bond.ViaBondPurchased({fromBlock:'latest'}));
    console.log("Account Via-EUR bond token balance after purchase with Via-USD cash :", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurBond.balanceOf(accounts[1]))));
  
    await viaeurBond.transferFrom(accounts[1], viaeurBondToken, 100);
    
    await getFirstEvent(bond.ViaBondRedeemed({fromBlock:'latest'}));
    console.log("Account Via-USD cash token balance after redeeming Via-EUR bonds:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
  
  });*/

});









