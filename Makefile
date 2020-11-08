.PHONY: flatten
flatten:
	# core contracts
	truffle-flattener contracts/Bond.sol > flattened/Bond_Flattened.sol
	truffle-flattener contracts/Cash.sol > flattened/Cash_Flattened.sol
	truffle-flattener contracts/Factory.sol > flattened/Factory_Flattened.sol
	truffle-flattener contracts/Migrations.sol > flattened/Migrations_Flattened.sol
	truffle-flattener contracts/Token.sol > flattened/Token_Flattened.sol
	# utilities contracts
	truffle-flattener contracts/utilities/StringUtils.sol > flattened/StringUtils_Flattened.sol
	# oraclize contracts
	truffle-flattener contracts/oraclize/Oracle.sol > flattened/Oracle_Flattened.sol
	truffle-flattener contracts/oraclize/provableAPI.sol > flattened/ProvableAPI_Flattened.sol
	truffle-flattener contracts/oraclize/ViaOracle.sol > flattened/ViaOracle_Flattened.sol
	# erc contracts
	truffle-flattener contracts/erc/ERC20.sol > flattened/ERC20_Flattened.sol

.PHONY: myhtril
mythril:
	myth -v 1 analyze --max-depth 1024 --solv 0.5.7 --phrack --enable-physics --parallel-solving --solver-timeout 2000000 --execution-timeout 200 ./flattened/Bond_Flattened.sol 2>&1 | tee mythril_bond_analysis.txt
	myth -v 1 analyze --max-depth 1024 --solv 0.5.7 --phrack --enable-physics --parallel-solving --solver-timeout 2000000 --execution-timeout 200 ./flattened/Cash_Flattened.sol 2>&1 | tee mythril_cash_analysis.txt
	myth -v 1 analyze --max-depth 1024 --solv 0.5.7 --phrack --enable-physics --parallel-solving --solver-timeout 2000000 --execution-timeout 200 ./flattened/Factory_Flattened.sol 2>&1 | tee mythril_factory_analysis.txt
	myth -v 1 analyze --max-depth 1024 --solv 0.5.7 --phrack --enable-physics --parallel-solving --solver-timeout 2000000 --execution-timeout 200 ./flattened/ViaOracle_Flattened.sol 2>&1 | tee mythril_viaoracle_analysis.txt

.PHONY: slither
slither:
	slither --solc ~/.solc-select/usr/bin/solc-v0.5.7 ./flattened/Factory_Flattened.sol 2>&1 | tee slither_factory_analysis.txt
	slither --solc ~/.solc-select/usr/bin/solc-v0.5.7 ./flattened/Bond_Flattened.sol 2>&1 | tee slither_bond_analysis.txt
	slither --solc ~/.solc-select/usr/bin/solc-v0.5.7 ./flattened/Cash_Flattened.sol 2>&1 | tee slither_cash_analysis.txt
	slither --solc ~/.solc-select/usr/bin/solc-v0.5.7 ./flattened/ViaOracle_Flattened.sol 2>&1 | tee slither_viaoracle_analysis.txt