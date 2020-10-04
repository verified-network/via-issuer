// (c) Kallol Borah, 2020
// Using Openzeppelin upgrades and contract loader to upgrade cash and bond contracts

const Web3 = require("web3");
const {
  ZWeb3,
  Contracts,
  ProxyAdminProject
} = require("@openzeppelin/upgrades");

async function main() {
    // Set up web3 object, connected to the network, initialize the Upgrades library
    const web3 = new Web3("http://localhost:7545"); //change as required
    ZWeb3.initialize(web3.currentProvider);
    const loader = setupLoader({ provider: web3 }).web3;

    //Fetch the default account
    const from = await ZWeb3.defaultAccount();
    
    //below are addresses of cash and bond proxy addresses from deployment script 
    const via_usd_cash = "";
    const via_eur_cash = "";
    const via_inr_cash = "";
    const via_usd_bond = "";
    const via_eur_bond = "";
    const via_inr_bond = "";
  
    //creating a new project, to manage our upgradeable contracts.
    const project = new ProxyAdminProject("via-issuer", null, null, {
      from,
      gas: 1e6,
      gasPrice: 1e9
    });

    //upgrade cash and bond implementation contracts
    const cash = Contracts.getFromLocal("Cash");
    const via_usd_cash_proxy = await project.upgradeProxy(via_usd_cash, cash);
    console.log("via_usd_cash_proxy : ", via_usd_cash_proxy.options.address);
    const via_eur_cash_proxy = await project.upgradeProxy(via_eur_cash, cash);
    console.log("via_eur_cash_proxy : ", via_eur_cash_proxy.options.address);
    const via_inr_cash_proxy = await project.upgradeProxy(via_inr_cash, cash);
    console.log("via_inr_cash_proxy : ", via_inr_cash_proxy.options.address);

    const bond = Contracts.getFromLocal("Bond");
    const via_usd_bond_proxy = await project.upgradeProxy(via_usd_bond, bond);
    console.log("via_usd_bond_proxy : ", via_usd_bond_proxy.options.address);
    const via_eur_bond_proxy = await project.upgradeProxy(via_eur_bond, bond);
    console.log("via_eur_bond_proxy : ", via_eur_bond_proxy.options.address);
    const via_inr_bond_proxy = await project.upgradeProxy(via_inr_bond, bond);
    console.log("via_inr_bond_proxy : ", via_inr_bond_proxy.options.address);

  }

  main();