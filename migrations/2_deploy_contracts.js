// (c) Kallol Borah, 2020
// deploying via tokens

const stringutils = artifacts.require('stringutils');
const paymentutils = artifacts.require('paymentutils');
const ABDKMathQuad = artifacts.require('ABDKMathQuad');
const Factory = artifacts.require('Factory');
const Bond = artifacts.require('Bond');
const Cash = artifacts.require('Cash');
const Oracle = artifacts.require('Oracle');
const Fees = artifacts.require('Fees');
const ERC20 = artifacts.require('ERC20');
const Token = artifacts.require('Token');

module.exports = function(deployer, network, accounts) {
    
    deployer.deploy(stringutils);
    deployer.link(stringutils, [Bond, Cash, Oracle]);

    deployer.deploy(paymentutils);
    deployer.link(paymentutils, [Bond, Cash]);

    deployer.deploy(ABDKMathQuad);
    deployer.link(ABDKMathQuad,[Factory, Cash, Bond, Oracle, ERC20, Token]);

    deployer.deploy(Oracle, {from: accounts[0], gas:6721975, value: 0.25e18});
    deployer.deploy(Cash);
    deployer.deploy(Bond);
    deployer.deploy(Token);
    deployer.deploy(Fees);

    deployer.deploy(Factory).then(async () => {
        const factory = await Factory.deployed();
        const cash = await Cash.deployed();
        const bond = await Bond.deployed();
        const oracle = await Oracle.deployed();
        const token = await Token.deployed();
        const fee = await Fees.deployed();

        await factory.initialize();
        await oracle.initialize(factory.address);
        await fee.initialize(factory.address);

        await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
        await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);
        await factory.createIssuer(cash.address, web3.utils.utf8ToHex("Via_INR"), web3.utils.utf8ToHex("Cash"), oracle.address, token.address, fee.address);

        await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_USD"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
        await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_EUR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);
        await factory.createIssuer(bond.address, web3.utils.utf8ToHex("Via_INR"), web3.utils.utf8ToHex("Bond"), oracle.address, token.address, fee.address);

        for (let i = 0; i < 6; i++) {
            var factoryTokenAddress = await factory.tokens(i);
            console.log("Token address:", factoryTokenAddress);
            console.log("Token name:", web3.utils.hexToUtf8(await factory.getName(factoryTokenAddress)));
            console.log("Token type:", web3.utils.hexToUtf8(await factory.getType(factoryTokenAddress)));
            console.log();
        }       

        await factory.setViaOracleUrl("https://via-oracle.azurewebsites.net");
    });
    
}




