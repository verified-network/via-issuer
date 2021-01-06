const assert = require("chai").assert;
var truffleAssert = require('truffle-assertions');
var truffleEvent  = require('truffle-events');

const Factory = artifacts.require('Factory');
const Cash = artifacts.require('Cash');
const Bond = artifacts.require('Bond');
const stringutils = artifacts.require('stringutils');
const ABDKMathQuad = artifacts.require('ABDKMathQuad');
const ViaOracle = artifacts.require('ViaOracle');
const Token = artifacts.require('Token');

web3.setProvider("http://127.0.0.1:8545");

contract("Bond contract testing", async (accounts) => {

  const getFirstEvent = (_event) => {
    return new Promise((resolve, reject) => {
      _event.once('data', resolve).once('error', reject)
    });
  }
  
  const timeoutPromise = new Promise((_, reject) => {
    setTimeout(() => {
      reject(new Error('Request timed out'));
    }, 200000);
  })

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
      var oracle = await ViaOracle.deployed();  
      var token = await Token.deployed();  
      
      await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address);
      
      var viausdBondAddress = await factory.tokens(3);
      var viausdBondName = await web3.utils.hexToUtf8(await factory.getName(viausdBondAddress));
      var viausdBondType = await web3.utils.hexToUtf8(await factory.getType(viausdBondAddress));
      var viausdBond = await Bond.at(viausdBondAddress);

      console.log(viausdBondName, viausdBondType, " contract address:", viausdBondAddress);
      console.log(viausdBondName, viausdBondType, " contract ether balance before sending ether:", await web3.eth.getBalance(viausdBondAddress));
      console.log("Account address:", accounts[0]);
      console.log("Account ether balance before sending ether:", await web3.eth.getBalance(accounts[0]));
      //console.log("Account Via-USD bond token balance before sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBond.balanceOf(accounts[0]))));
      console.log();

      console.log("Via oracle ether balance before query:", await web3.eth.getBalance(oracle.address));
      await viausdBond.sendTransaction({from:accounts[0], to:viausdBondAddress, value:1e18});
      console.log("Via-USD bond contract ether balance after sending ether:", await web3.eth.getBalance(viausdBondAddress));
      console.log("Account ether balance after sending ether:", await web3.eth.getBalance(accounts[0]));  
      
      /*let ivub = Promise.race([getFirstEvent(oracle.LogResult({fromBlock:'latest'})), timeoutPromise]);
      try{
          await ivub;
      } catch (error) { 
        console.log(error);
      } finally {
        clearTimeout(ivub);
      }*/
      /*
      var viausdBondToken = await getFirstEvent(factory.TokenCreated({fromBlock:'latest'}), (ev) => {
        console.log("Token created !");
        return Token.at(ev._address);
      });
      */
      
      var viausdBondToken = truffleAssert.eventEmitted(factory, 'TokenCreated', (ev) => {
        console.log("Token created !");
        return Token.at(ev._address);
      });
      
      console.log("Via oracle ether balance after query:", await web3.eth.getBalance(oracle.address));
      console.log("Account Via-USD bond token balance after sending ether:", await web3.utils.hexToNumberString(await web3.utils.toHex(await viausdBondToken.balanceOf(accounts[0]))));
      
  });    
   

});









