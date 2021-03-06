# Verified Issuer for cash and zero coupon bond tokens
The objective of this project is to create a reference implementation for issue of Verified digital cash tokens on ethereum, so that developers can create similar implementations on other blockchain platforms. 

This implementation follows the ERC20 standard because we want digital currencies to be usable across currently used wallets and on crypto exchanges. 


## How does the Verified digital currency system work ?
1. The Verified digital cash token is NOT one cash token but multiple tokens for different fiat currencies (eg, VX-USD for US dollar, VX-EUR for the Euro, etc)

2. Users can purchase the Verified cash tokens using ether and also fiat currencies. 

3. Users can also redeem (return) Verified cash tokens and they can choose to take ether in return or some other Verified cash token in return. Eg, a user can choose to redeem VX-USD and take VX-EUR. 

4. The price of the Verified cash tokens are stabilized (so it is designed to be stable) by using a set of interest rates on the Verified cash tokens. Interest rates regulate demand and supply and thus price of Verified cash tokens. The current implementation supports buying of Verified digital bonds denominated in multiple currencies with cash tokens denominated in corresponding currencies. Bonds are simply loans. However, unlike regular loans that require the borrower to pay an interest at a periodic interval, the Verified bonds for different fiat currencies are zero coupon bonds - these are bonds that are issued in such a way that the interest is paid upfront. So, if a user buys (borrows) a zero coupon bond whose face value is USD 100, the user may get a bond (loan) of only USD 80. Like cash tokens, bonds can be redeemed back into cash tokens. 

5. Interest rates on Verified bond tokens are calculated externally to this system (the Verified oracle). The Verified oracle captures events emitted by the issuer (eg, sold, lent, redeemed) and uses them in combination with prevailing interest and exchange rates between fiat currency pairs to price Verified cash and bond tokens. This pricing is available to the issuer in turn using an Oracle contract.

# Cloning This Repository

```shell
$> git clone https://github.com/verified-network/verified-issuer.git
$> cd verified-issuer
$> git submodule update --init
```

## Steps

### To build and deploy locally:
1.  To compile the project, change to the root of the directory where the project is located:\
    ``` cd <the root of the directory where the project is located> ```

2.  Install Oraclize's ethereum-bridge 

    ``` npm install -g ethereum-bridge ```

3.  ``` truffle compile ```

4.  For local testing make sure to have a test blockchain such as Ganache or [Ganache Cli] installed and running before executing migrate:

    If you use Ganache, please directly open the Ganache and create *NEW WORKSPACE*, and then add the truffle-config.js or truffle.js file to this workspace, note to     set the *PORT NUMBER*.

    If you use the [Ganache Cli] for the test. please open the new terminal window and run the ganache-cli first:\
    ``` ganache-cli ```

5.  Start ethereum-bridge for Oraclize by opening a new terminal

    ``` ethereum-bridge -H localhost:8545 -a 9 ```

    And copy ``` OAR = OracleAddrResolverI(0x..............);``` to the constructor in Oracle.sol in \contracts\oraclize folder

6.  ``` truffle migrate ```

### To compile and deploy to the Ropsten testnet:

*Note: We have provided an account for test. The account and the mnemonic just for test, please don’t use on mainnet.*

1.  Install HDWalletProvider
Truffle's HDWalletProvider is a separate npm package. Please install it first:\
``` npm install @truffle/hdwallet-provider ```

2.  To compile the project, change to the root of the directory where the project is located:\
``` cd <the root of the directory where the project is located> ```

3.  ``` truffle compile ```

4.  Deploy to the Ropsten network:\
``` truffle migrate --network ropsten ```


[Ganache Cli]: https://github.com/trufflesuite/ganache-cli



*NOTE:* Currently this reference implementation is under development and NOT FOR PRODUCTION.

