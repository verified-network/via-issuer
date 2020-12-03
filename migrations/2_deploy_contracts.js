// (c) Kallol Borah, 2020
// deploying via tokens

const stringutils = artifacts.require('stringutils');
const ABDKMathQuad = artifacts.require('ABDKMathQuad');
const Factory = artifacts.require('Factory');
const Bond = artifacts.require('Bond');
const Cash = artifacts.require('Cash');
const CashV2Test = artifacts.require('CashV2Test');
const ViaOracle = artifacts.require('ViaOracle');
const usingProvable = artifacts.require('usingProvable');
const ERC20 = artifacts.require('ERC20');
const Token = artifacts.require('Token');

const TokenFactory = artifacts.require('TokenFactory');
const BondFactory = artifacts.require('BondFactory');
const CashFactory = artifacts.require('CashFactory');

module.exports = function(deployer, network, accounts) {
    deployer.deploy(stringutils);
    deployer.link(stringutils, [Bond, Cash, ViaOracle, CashFactory, BondFactory, TokenFactory, CashV2Test]);

    deployer.deploy(ABDKMathQuad);
    deployer.link(ABDKMathQuad,[Cash, Bond, ViaOracle, ERC20, Token, CashFactory, BondFactory, TokenFactory, CashV2Test]);

    deployer.deploy(usingProvable);
    deployer.deploy(ViaOracle, {from: accounts[0], gas:6721975, value: 0.25e18});
    deployer.deploy(ERC20);

    // factory contracts (we use different account to prevent admin falllback errors)
    deployer.deploy(CashFactory, {from: accounts[2], gas:6721975});
    deployer.deploy(BondFactory, {from: accounts[2], gas:6721975});
    deployer.deploy(TokenFactory, {from: accounts[2], gas:6721975});

    deployer.deploy(Factory).then(async () => {
        const factory = await Factory.deployed();
        const cash = await CashFactory.deployed();
        const bond = await BondFactory.deployed();
        const oracle = await ViaOracle.deployed();
        const token = await TokenFactory.deployed();

        await oracle.initialize(factory.address);

        await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, {from: accounts[2]});
        await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, {from: accounts[2]});
        await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_INR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, {from: accounts[2]});

        await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, {from: accounts[2]});
        await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, {from: accounts[2]});
        await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_INR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, {from: accounts[2]});

        for (let i = 0; i < 6; i++) {
            var factoryTokenAddress = await factory.tokens(i);
            console.log("Token address:", factoryTokenAddress);
            console.log("Token name:", web3.utils.hexToUtf8(await factory.getName(factoryTokenAddress)));
            console.log("Token type:", web3.utils.hexToUtf8(await factory.getType(factoryTokenAddress)));
            console.log();
        }       
    });
    
}




