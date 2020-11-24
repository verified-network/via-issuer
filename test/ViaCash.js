const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

const Factory = artifacts.require('Factory');
const Cash = artifacts.require('Cash');
const stringutils = artifacts.require('stringutils');
const ABDKMathQuad = artifacts.require('ABDKMathQuad');
const ViaOracle = artifacts.require('ViaOracle');
const Token = artifacts.require('Token');

web3.setProvider("http://localhost:8545");

contract("CashContractSize", function(accounts) {
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
  });

contract("IssuingViaUSD", async (accounts) => {
    it("should send ether to Via-USD cash contract and then get some Via-USD cash tokens", async () => {
        var abdkMathQuad = await ABDKMathQuad.deployed();
        await Cash.link(abdkMathQuad);

        var factory = await Factory.deployed();
        var cash = await Cash.deployed();
        var oracle = await ViaOracle.deployed(); 
        var token = await Token.deployed();   
        
        await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
        
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
        
        let callbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
        await truffleAssert.createTransactionResult(oracle, callbackToViaOracle.transactionHash);
          
        console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));
        console.log("Account Via-USD cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
                
    });

    const getFirstEvent = (_event) => {
      return new Promise((resolve, reject) => {
        _event.once('data', resolve).once('error', reject)
      });
    }
});

contract("IssuingViaEUR", async (accounts) => {
  it("should send ether to Via-EUR cash contract and then get some Via-EUR cash tokens", async () => {
      var abdkMathQuad = await ABDKMathQuad.deployed();
      await Cash.link(abdkMathQuad);

      var factory = await Factory.deployed();
      var cash = await Cash.deployed();
      var oracle = await ViaOracle.deployed();  
      var token = await Token.deployed();  
      
      await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
      
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
      
      let firstCallbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      await truffleAssert.createTransactionResult(oracle, firstCallbackToViaOracle.transactionHash);
      let secondCallbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      await truffleAssert.createTransactionResult(oracle, secondCallbackToViaOracle.transactionHash);
      
      console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));
      console.log("Account Via-EUR cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));

  });

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }

});

contract("ViaUSDExchange", async (accounts) => {
  it("should send Via-USD to Via-EUR cash contract and then get some Via-EUR cash tokens", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await ViaOracle.deployed(); 
    var token = await Token.deployed();  
    
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);

    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    var viaeurCashAddress = await factory.tokens(1);
    var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
    var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
    var viaeurCash = await Cash.at(viaeurCashAddress);

    console.log(viausdCashName, viausdCashType, "token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log(viaeurCashName, viaeurCashType, "token address:", viaeurCashAddress);
    console.log(viaeurCashName, viaeurCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Account Via-EUR cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    console.log();
    
    console.log("Via oracle ether balance before query:", await web3.eth.getBalance(oracle.address));
    await viausdCash.sendTransaction({from:accounts[0], to:viausdCashAddress, value:1e18});

    let callbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackToViaOracle.transactionHash);
    console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));
    
    console.log("Via-USD cash token contract ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Via-EUR cash token contract ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance after sending ether and before sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Account Via-EUR cash token balance after sending ether and before sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    console.log();
    
    console.log("Via oracle ether balance before query:", await web3.eth.getBalance(oracle.address));
    await viausdCash.transferFrom(accounts[0], viaeurCashAddress, 10);

    let callbackWithExchangeRates = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackWithExchangeRates.transactionHash);
    console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));

    console.log("Via-USD cash token contract ether balance after sending Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Via-EUR cash token contract ether balance after sending Via-USD:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance after sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Account Via-EUR cash token balance after sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
  });

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }

});

contract("ViaUSDRedemption", async (accounts) => {
  it("should send Via-USD to Via-USD cash contract and then get ether sent during issuing process", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await ViaOracle.deployed();  
    var token = await Token.deployed(); 
    
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
    
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
    
    await viausdCash.sendTransaction({from:accounts[0], to:viausdCashAddress, value:1e18});
    let callbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackToViaOracle.transactionHash);
    
    console.log("Via-USD cash token contract ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance after sending ether and before sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log();
    
    await viausdCash.transferFrom(accounts[0], viausdCashAddress, 10);
    let callbackForRedemption = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackForRedemption.transactionHash);

    console.log("Via-USD cash token contract ether balance after sending Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance after sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
  });

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }

});

contract("ViaEURRedemption", async (accounts) => {
  it("should send Via-EUR tokens to Via-EUR contract and get back ether paid in earlier", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
      await Cash.link(abdkMathQuad);

      var factory = await Factory.deployed();
      var cash = await Cash.deployed();
      var oracle = await ViaOracle.deployed();  
      var token = await Token.deployed();  
      
      await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
      
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

      await viaeurCash.sendTransaction({from:accounts[0], to:viaeurCashAddress, value:1e18});
      let callbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      await truffleAssert.createTransactionResult(oracle, callbackToViaOracle.transactionHash);

      console.log("Via-EUR cash token contract ether balance after sending ether:", await web3.eth.getBalance(viaeurCashAddress));
      console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  
      console.log("Account Via-EUR cash token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
      console.log();
      
      await viaeurCash.transferFrom(accounts[0], viaeurCashAddress, 10);
      let callbackForRedemption = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
      await truffleAssert.createTransactionResult(oracle, callbackForRedemption.transactionHash);

      console.log("Via-EUR cash token contract ether balance after sending Via-EUR:", await web3.eth.getBalance(viaeurCashAddress));
      console.log("Account ether balance after sending Via-EUR:", await web3.eth.getBalance(accounts[0]));
      console.log("Account Via-EUR cash token balance after sending Via-EUR:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
  });

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }
  
});

contract("ViaUSDRedemptionAfterTransfer", async (accounts) => {
  it("should send Via-USD tokens to Via-USD contract after transfer of Via-USD tokens from one user account to another", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await ViaOracle.deployed(); 
    var token = await Token.deployed();  
    
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
    
    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    console.log(viausdCashName, viausdCashType, "token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Sender address:", accounts[0]);
    console.log("Sender ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log();
    
    await viausdCash.sendTransaction({from:accounts[0], to:viausdCashAddress, value:1e18});
    console.log("Via-USD cash token contract ether balance after sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));

    let callbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackToViaOracle.transactionHash);
    
    console.log("Sender Via-USD cash token balance after sending ether and before sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Receiver address:", accounts[1]);
    console.log("Receiver ether balance before Via-USD is sent by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-USD cash token balance before receiving Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    console.log();
    
    await viausdCash.transferFrom(accounts[0], accounts[1], 100);

    console.log("Sender ether balance after sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-USD cash token balance after sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Receiver ether balance after Via-USD is sent by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-USD cash token balance after receiving Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
  
    await viausdCash.transferFrom(accounts[1], viausdCashAddress, 50);
    let callbackForRedemption = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackForRedemption.transactionHash);

    console.log("Via-USD cash token contract ether balance after redeeming Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after redeeming Via-USD:", await web3.eth.getBalance(accounts[1]));
    console.log("Account Via-USD cash token balance after redeeming Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
  });

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }

});

contract("TransferViaUSD", async (accounts) => {
  it("should transfer Via-USD to another account", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await ViaOracle.deployed(); 
    var token = await Token.deployed();  
    
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
    
    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    console.log(viausdCashName, viausdCashType, "token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Sender address:", accounts[0]);
    console.log("Sender ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log();
    
    await viausdCash.sendTransaction({from:accounts[0], to:viausdCashAddress, value:1e18});
    console.log("Via-USD cash token contract ether balance after sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));

    let callbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackToViaOracle.transactionHash);
    
    console.log("Sender Via-USD cash token balance after sending ether and before sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Receiver address:", accounts[1]);
    console.log("Receiver ether balance before Via-USD is sent by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-USD cash token balance before receiving Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
    console.log();
    
    await viausdCash.transferFrom(accounts[0], accounts[1], 100);

    console.log("Sender ether balance after sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-USD cash token balance after sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Receiver ether balance after Via-USD is sent by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-USD cash token balance after receiving Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
  });

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }

});

contract("ViaUSDRedemptionAfterEURExchangeTransferAndRedemption", async (accounts) => {
  it("should send Via-USD to Via-EUR cash contract, get some Via-EUR cash tokens which it should transfer to another account which will redeem Via-EUR to get Via-USD which it will again redeem to get ether", async () => {
    var abdkMathQuad = await ABDKMathQuad.deployed();
    await Cash.link(abdkMathQuad);

    var factory = await Factory.deployed();
    var cash = await Cash.deployed();
    var oracle = await ViaOracle.deployed(); 
    var token = await Token.deployed();  
    
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
    await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address);
    
    var viausdCashAddress = await factory.tokens(0);
    var viausdCashName = await web3.utils.hexToUtf8(await factory.getName(viausdCashAddress));
    var viausdCashType = await web3.utils.hexToUtf8(await factory.getType(viausdCashAddress));
    var viausdCash = await Cash.at(viausdCashAddress);

    var viaeurCashAddress = await factory.tokens(1);
    var viaeurCashName = await web3.utils.hexToUtf8(await factory.getName(viaeurCashAddress));
    var viaeurCashType = await web3.utils.hexToUtf8(await factory.getType(viaeurCashAddress));
    var viaeurCash = await Cash.at(viaeurCashAddress);

    console.log(viausdCashName, viausdCashType, "token address:", viausdCashAddress);
    console.log(viausdCashName, viausdCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viausdCashAddress));
    console.log(viaeurCashName, viaeurCashType, "token address:", viaeurCashAddress);
    console.log(viaeurCashName, viaeurCashType, "token contract ether balance before sending ether:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account address:", accounts[0]);
    console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Account Via-EUR cash token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    console.log();
    
    await viausdCash.sendTransaction({from:accounts[0], to:viausdCashAddress, value:1e18});

    let callbackToViaOracle = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackToViaOracle.transactionHash);
    
    console.log("Via-USD cash token contract ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Via-EUR cash token contract ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending ether and before sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance after sending ether and before sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Account Via-EUR cash token balance after sending ether and before sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    console.log();
    
    await viausdCash.transferFrom(accounts[0], viaeurCashAddress, 100);
    let callbackWithExchangeRates = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackWithExchangeRates.transactionHash);

    console.log("Via-USD cash token contract ether balance after sending Via-USD:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Via-EUR cash token contract ether balance after sending Via-USD:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending Via-USD:", await web3.eth.getBalance(accounts[0]));
    console.log("Account Via-USD cash token balance after sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[0]))));
    console.log("Account Via-EUR cash token balance after sending Via-USD:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
  
    await viaeurCash.transferFrom(accounts[0], accounts[1], 50);

    console.log("Sender ether balance after transferring Via-EUR:", await web3.eth.getBalance(accounts[0]));
    console.log("Sender Via-EUR cash token balance after transferring Via-EUR:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[0]))));
    console.log("Receiver ether balance after Via-EUR is transferred by sender:", await web3.eth.getBalance(accounts[1]));
    console.log("Receiver Via-EUR cash token balance after transfer of Via-EUR:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[1]))));

    await viaeurCash.transferFrom(accounts[1], viaeurCashAddress, 25);
    let callbackForEURRedemption = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackForEURRedemption.transactionHash);

    console.log("Via-EUR cash token contract ether balance after sending Via-EUR:", await web3.eth.getBalance(viaeurCashAddress));
    console.log("Account ether balance after sending Via-EUR:", await web3.eth.getBalance(accounts[1]));
    console.log("Account Via-EUR cash token balance after sending Via-EUR:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viaeurCash.balanceOf(accounts[1]))));

    await viausdCash.transferFrom(accounts[1], viausdCashAddress, 25);
    let callbackForUSDRedemption = await getFirstEvent(oracle.LogResult({fromBlock:'latest'}));
    await truffleAssert.createTransactionResult(oracle, callbackForUSDRedemption.transactionHash);

    console.log("Via-USD cash token contract ether balance after sending Via-USD obtained after redeeming Via-EUR:", await web3.eth.getBalance(viausdCashAddress));
    console.log("Account ether balance after sending Via-USD obtained after redeeming Via-EUR:", await web3.eth.getBalance(accounts[1]));
    console.log("Account Via-USD cash token balance after sending Via-USD obtained after redeeming Via-EUR:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdCash.balanceOf(accounts[1]))));
  });

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }

});