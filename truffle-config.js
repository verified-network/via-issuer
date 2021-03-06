const HDWalletProvider = require("@truffle/hdwallet-provider");

require('dotenv').config();

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        development: {
            host: "127.0.0.1", // Localhost (default: none)
            port: 8545, // Standard Ethereum port (default: none)
            network_id: "*", // Any network (default: none)
            websockets: true,
            gas:6721975
        },
        ropsten: {
            provider: () => new HDWalletProvider(mnemonic, "wss://ropsten.infura.io/ws/v3/" + process.env.INFURA_API_KEY),
            network_id: 3,
            gas: 5500000,
            gasPrice: 10000000000,
            networkCheckTimeout: 10000000,
            confirmations: 2,    
            timeoutBlocks: 200,  
            skipDryRun: true      
          },
        kovan: {
            provider: () => new HDWalletProvider(mnemonic, "https://kovan.infura.io/v3/" + process.env.INFURA_API_KEY),
            network_id: 42,
            gas: 6721975,
            gasPrice: 10000000000,
            confirmations: 2,    
            timeoutBlocks: 200,  
            skipDryRun: true  
        },
        rinkeby: {
            provider: () => new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/" + process.env.INFURA_API_KEY),
            network_id: 4,
            gas: 6721975,
            gasPrice: 10000000000,
            networkCheckTimeout: 10000000,
            confirmations: 2,    
            timeoutBlocks: 200,  
            skipDryRun: true  
        },
        // main ethereum network(mainnet)
        main: {
            provider: () => new HDWalletProvider(mnemonic, "https://mainnet.infura.io/v3/" + process.env.INFURA_API_KEY),
            network_id: 1,
            gas: 6721975,
            gasPrice: 10000000000
        }
    },
    compilers: {
        solc: {
           version: "0.5.7", 
           settings: {
               optimizer: {
                   enabled: true,
                   runs: 200
               }
           }
        }
    }/*,
    mocha: {
        reporter: 'eth-gas-reporter',
        reporterOptions : { 
            currency : 'USD',
            coinmarketcap : 'ffcb2325-818c-4d4d-9f38-ca5973a5f5ad',
            //gasPrice : 5,
            showTimeSpent : true,
            excludeContracts : ['Migrations'],
            src : 'contracts',
            url : 'http://localhost:8545',
            //outputFile : 'gas-report.txt'
            showMethodSig : false,
            onlyCalledMethods : true 
        } 
    }*/
};