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