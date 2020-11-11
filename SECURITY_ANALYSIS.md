# Mythril

Requires having installed `truffle-flattener` and flattening contracts. See Flattening for more information.

* Install mythril with `pip3 install mythril`
* Run mythril against flattened contracts with `make mythril` (this will take awhile, possibly around 1hr or more).
* Analysis results will be stored in `mythril_*_analysis.txt` and displayed on stdout
 
# Slither

Requires having installed `truffle-flattener` and flattening contracts. See Flattening for more information. In addition you must have [`solc-select`](https://github.com/crytic/solc-select) installed

* Install slither with `pip3 install slither-analyzer`
* Run slither against flattened contracts with `make slither` (this will take sometime, possibly around 2 minutes)
* Analysis results will be stored in `slither_*_analysis.txt` and displayed on stdout


# Flattening

* Install `truffler-flattener` with `npm install -g truffle-flattener`
* Flatten contracts with `make flatten`