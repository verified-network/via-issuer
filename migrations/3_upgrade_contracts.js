const UpgradeableProxy = artifacts.require('TransparentUpgradeableProxy');

module.exports = function(deployer, network, accounts) {
    // change idx to the account index that points to the mangement account
    // we default to 2
    var idx = "2";
    var managementAcct = accounts[idx];

    // addresses for the various factory proxy contracts
    var bond_factory_proxy_addr = "";
    var cash_factory_proxy_addr = "";
    var token_factory_proxy_addr = "";
    // instances of the upgradeable proxy contracts
    var bondInstance;
    var cashInstance;
    var tokenInstance;
    async () => {
        bondInstance = await UpgradeableProxy.at(bond_factory_proxy_addr);
        cashInstance = await UpgradeableProxy.at(cash_factory_proxy_addr);
        tokenInstance = await UpgradeableProxy.at(token_factory_proxy_addr);    
    };
     // addresses of new implementation contracts for Cash.sol, Bond.sol, Token.sol
    var new_bond_implementation = "";
    var new_cash_implementation = "";
    var new_token_implementation = "";

    /*
        uncomment these to trigger upgrading the implementation contracts

        await bondInstance.upgradeTo(new_bond_implementation, {from: managementAcct});
        await cashInstance.upgradeTo(new_cash_implementation, {from: managementAcct});
        await tokenInstance.upgradeTo(new_token_implementation, {from: managementAcct});
    */
}