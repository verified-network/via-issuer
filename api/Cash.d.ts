/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, ContractTransaction, EventFilter, Signer } from "ethers";
import { Listener, Provider } from "ethers/providers";
import { Arrayish, BigNumber, BigNumberish, Interface } from "ethers/utils";
import {
  TransactionOverrides,
  TypedEventDescription,
  TypedFunctionDescription,
} from ".";

interface CashInterface extends Interface {
  functions: {
    name: TypedFunctionDescription<{ encode([]: []): string }>;

    approve: TypedFunctionDescription<{
      encode([spender, tokens]: [string, BigNumberish]): string;
    }>;

    cashtokenName: TypedFunctionDescription<{ encode([]: []): string }>;

    totalSupply: TypedFunctionDescription<{ encode([]: []): string }>;

    deposits: TypedFunctionDescription<{
      encode([,]: [string, Arrayish]): string;
    }>;

    balances: TypedFunctionDescription<{ encode([]: [string]): string }>;

    decimals: TypedFunctionDescription<{ encode([]: []): string }>;

    balanceOf: TypedFunctionDescription<{
      encode([tokenOwner]: [string]): string;
    }>;

    renounceOwnership: TypedFunctionDescription<{ encode([]: []): string }>;

    owner: TypedFunctionDescription<{ encode([]: []): string }>;

    isOwner: TypedFunctionDescription<{ encode([]: []): string }>;

    symbol: TypedFunctionDescription<{ encode([]: []): string }>;

    transfer: TypedFunctionDescription<{
      encode([receiver, tokens]: [string, BigNumberish]): string;
    }>;

    allowance: TypedFunctionDescription<{
      encode([tokenOwner, spender]: [string, string]): string;
    }>;

    transferOwnership: TypedFunctionDescription<{
      encode([newOwner]: [string]): string;
    }>;

    initialize: TypedFunctionDescription<{
      encode([_name, _type, _owner, _oracle, _token]: [
        Arrayish,
        Arrayish,
        string,
        string,
        string
      ]): string;
    }>;

    transferFrom: TypedFunctionDescription<{
      encode([sender, receiver, tokens]: [
        string,
        string,
        BigNumberish
      ]): string;
    }>;

    requestAddToBalance: TypedFunctionDescription<{
      encode([tokens, sender]: [Arrayish, string]): string;
    }>;

    requestDeductFromBalance: TypedFunctionDescription<{
      encode([tokens, receiver]: [Arrayish, string]): string;
    }>;

    requestIssue: TypedFunctionDescription<{
      encode([amount, buyer, currency]: [Arrayish, string, Arrayish]): string;
    }>;

    convert: TypedFunctionDescription<{
      encode([txId, result, rtype]: [Arrayish, Arrayish, Arrayish]): string;
    }>;
  };

  events: {
    ViaCashIssued: TypedEventDescription<{
      encodeTopics([currency, value]: [null, null]): string[];
    }>;

    ViaCashRedeemed: TypedEventDescription<{
      encodeTopics([currency, value]: [null, null]): string[];
    }>;

    LogCallback: TypedEventDescription<{
      encodeTopics([EthXid, EthXvalue, txId, ViaXvalue]: [
        null,
        null,
        null,
        null
      ]): string[];
    }>;

    OwnershipTransferred: TypedEventDescription<{
      encodeTopics([previousOwner, newOwner]: [
        string | null,
        string | null
      ]): string[];
    }>;

    Approval: TypedEventDescription<{
      encodeTopics([tokenOwner, spender, tokens]: [
        string | null,
        string | null,
        null
      ]): string[];
    }>;

    Transfer: TypedEventDescription<{
      encodeTopics([from, to, tokens]: [
        string | null,
        string | null,
        null
      ]): string[];
    }>;
  };
}

export class Cash extends Contract {
  connect(signerOrProvider: Signer | Provider | string): Cash;
  attach(addressOrName: string): Cash;
  deployed(): Promise<Cash>;

  on(event: EventFilter | string, listener: Listener): Cash;
  once(event: EventFilter | string, listener: Listener): Cash;
  addListener(eventName: EventFilter | string, listener: Listener): Cash;
  removeAllListeners(eventName: EventFilter | string): Cash;
  removeListener(eventName: any, listener: Listener): Cash;

  interface: CashInterface;

  functions: {
    name(overrides?: TransactionOverrides): Promise<string>;

    "name()"(overrides?: TransactionOverrides): Promise<string>;

    approve(
      spender: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "approve(address,uint256)"(
      spender: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    cashtokenName(overrides?: TransactionOverrides): Promise<string>;

    "cashtokenName()"(overrides?: TransactionOverrides): Promise<string>;

    totalSupply(overrides?: TransactionOverrides): Promise<BigNumber>;

    "totalSupply()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    deposits(
      arg0: string,
      arg1: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "deposits(address,bytes32)"(
      arg0: string,
      arg1: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    balances(arg0: string, overrides?: TransactionOverrides): Promise<string>;

    "balances(address)"(
      arg0: string,
      overrides?: TransactionOverrides
    ): Promise<string>;

    decimals(overrides?: TransactionOverrides): Promise<number>;

    "decimals()"(overrides?: TransactionOverrides): Promise<number>;

    balanceOf(
      tokenOwner: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "balanceOf(address)"(
      tokenOwner: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    /**
 * Leaves the contract without owner. It will not be possible to call
 `onlyOwner` functions anymore. Can only be called by the current owner.
      * > Note: Renouncing ownership will leave the contract without an owner,
 thereby removing any functionality that is only available to the owner.
 */
    renounceOwnership(
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    /**
 * Leaves the contract without owner. It will not be possible to call
 `onlyOwner` functions anymore. Can only be called by the current owner.
      * > Note: Renouncing ownership will leave the contract without an owner,
 thereby removing any functionality that is only available to the owner.
 */
    "renounceOwnership()"(
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    /**
     * Returns the address of the current owner.
     */
    owner(overrides?: TransactionOverrides): Promise<string>;

    /**
     * Returns the address of the current owner.
     */
    "owner()"(overrides?: TransactionOverrides): Promise<string>;

    /**
     * Returns true if the caller is the current owner.
     */
    isOwner(overrides?: TransactionOverrides): Promise<boolean>;

    /**
     * Returns true if the caller is the current owner.
     */
    "isOwner()"(overrides?: TransactionOverrides): Promise<boolean>;

    symbol(overrides?: TransactionOverrides): Promise<string>;

    "symbol()"(overrides?: TransactionOverrides): Promise<string>;

    transfer(
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "transfer(address,uint256)"(
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    allowance(
      tokenOwner: string,
      spender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "allowance(address,address)"(
      tokenOwner: string,
      spender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    /**
 * Transfers ownership of the contract to a new account (`newOwner`).
 Can only be called by the current owner.
 */
    transferOwnership(
      newOwner: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    /**
 * Transfers ownership of the contract to a new account (`newOwner`).
 Can only be called by the current owner.
 */
    "transferOwnership(address)"(
      newOwner: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    initialize(
      _name: Arrayish,
      _type: Arrayish,
      _owner: string,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "initialize(bytes32,bytes32,address,address,address)"(
      _name: Arrayish,
      _type: Arrayish,
      _owner: string,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    "initialize(address)"(
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    transferFrom(
      sender: string,
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "transferFrom(address,address,uint256)"(
      sender: string,
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    requestAddToBalance(
      tokens: Arrayish,
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "requestAddToBalance(bytes16,address)"(
      tokens: Arrayish,
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    requestDeductFromBalance(
      tokens: Arrayish,
      receiver: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "requestDeductFromBalance(bytes16,address)"(
      tokens: Arrayish,
      receiver: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    requestIssue(
      amount: Arrayish,
      buyer: string,
      currency: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "requestIssue(bytes16,address,bytes32)"(
      amount: Arrayish,
      buyer: string,
      currency: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    convert(
      txId: Arrayish,
      result: Arrayish,
      rtype: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "convert(bytes32,bytes16,bytes32)"(
      txId: Arrayish,
      result: Arrayish,
      rtype: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;
  };

  name(overrides?: TransactionOverrides): Promise<string>;

  "name()"(overrides?: TransactionOverrides): Promise<string>;

  approve(
    spender: string,
    tokens: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "approve(address,uint256)"(
    spender: string,
    tokens: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  cashtokenName(overrides?: TransactionOverrides): Promise<string>;

  "cashtokenName()"(overrides?: TransactionOverrides): Promise<string>;

  totalSupply(overrides?: TransactionOverrides): Promise<BigNumber>;

  "totalSupply()"(overrides?: TransactionOverrides): Promise<BigNumber>;

  deposits(
    arg0: string,
    arg1: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  "deposits(address,bytes32)"(
    arg0: string,
    arg1: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  balances(arg0: string, overrides?: TransactionOverrides): Promise<string>;

  "balances(address)"(
    arg0: string,
    overrides?: TransactionOverrides
  ): Promise<string>;

  decimals(overrides?: TransactionOverrides): Promise<number>;

  "decimals()"(overrides?: TransactionOverrides): Promise<number>;

  balanceOf(
    tokenOwner: string,
    overrides?: TransactionOverrides
  ): Promise<BigNumber>;

  "balanceOf(address)"(
    tokenOwner: string,
    overrides?: TransactionOverrides
  ): Promise<BigNumber>;

  /**
 * Leaves the contract without owner. It will not be possible to call
 `onlyOwner` functions anymore. Can only be called by the current owner.
      * > Note: Renouncing ownership will leave the contract without an owner,
 thereby removing any functionality that is only available to the owner.
 */
  renounceOwnership(
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  /**
 * Leaves the contract without owner. It will not be possible to call
 `onlyOwner` functions anymore. Can only be called by the current owner.
      * > Note: Renouncing ownership will leave the contract without an owner,
 thereby removing any functionality that is only available to the owner.
 */
  "renounceOwnership()"(
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  /**
   * Returns the address of the current owner.
   */
  owner(overrides?: TransactionOverrides): Promise<string>;

  /**
   * Returns the address of the current owner.
   */
  "owner()"(overrides?: TransactionOverrides): Promise<string>;

  /**
   * Returns true if the caller is the current owner.
   */
  isOwner(overrides?: TransactionOverrides): Promise<boolean>;

  /**
   * Returns true if the caller is the current owner.
   */
  "isOwner()"(overrides?: TransactionOverrides): Promise<boolean>;

  symbol(overrides?: TransactionOverrides): Promise<string>;

  "symbol()"(overrides?: TransactionOverrides): Promise<string>;

  transfer(
    receiver: string,
    tokens: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "transfer(address,uint256)"(
    receiver: string,
    tokens: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  allowance(
    tokenOwner: string,
    spender: string,
    overrides?: TransactionOverrides
  ): Promise<BigNumber>;

  "allowance(address,address)"(
    tokenOwner: string,
    spender: string,
    overrides?: TransactionOverrides
  ): Promise<BigNumber>;

  /**
 * Transfers ownership of the contract to a new account (`newOwner`).
 Can only be called by the current owner.
 */
  transferOwnership(
    newOwner: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  /**
 * Transfers ownership of the contract to a new account (`newOwner`).
 Can only be called by the current owner.
 */
  "transferOwnership(address)"(
    newOwner: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  initialize(
    _name: Arrayish,
    _type: Arrayish,
    _owner: string,
    _oracle: string,
    _token: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "initialize(bytes32,bytes32,address,address,address)"(
    _name: Arrayish,
    _type: Arrayish,
    _owner: string,
    _oracle: string,
    _token: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  /**
   * Initializes the contract setting the deployer as the initial owner.
   */
  "initialize(address)"(
    sender: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  transferFrom(
    sender: string,
    receiver: string,
    tokens: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "transferFrom(address,address,uint256)"(
    sender: string,
    receiver: string,
    tokens: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  requestAddToBalance(
    tokens: Arrayish,
    sender: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "requestAddToBalance(bytes16,address)"(
    tokens: Arrayish,
    sender: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  requestDeductFromBalance(
    tokens: Arrayish,
    receiver: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "requestDeductFromBalance(bytes16,address)"(
    tokens: Arrayish,
    receiver: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  requestIssue(
    amount: Arrayish,
    buyer: string,
    currency: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "requestIssue(bytes16,address,bytes32)"(
    amount: Arrayish,
    buyer: string,
    currency: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  convert(
    txId: Arrayish,
    result: Arrayish,
    rtype: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "convert(bytes32,bytes16,bytes32)"(
    txId: Arrayish,
    result: Arrayish,
    rtype: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  filters: {
    ViaCashIssued(currency: null, value: null): EventFilter;

    ViaCashRedeemed(currency: null, value: null): EventFilter;

    LogCallback(
      EthXid: null,
      EthXvalue: null,
      txId: null,
      ViaXvalue: null
    ): EventFilter;

    OwnershipTransferred(
      previousOwner: string | null,
      newOwner: string | null
    ): EventFilter;

    Approval(
      tokenOwner: string | null,
      spender: string | null,
      tokens: null
    ): EventFilter;

    Transfer(from: string | null, to: string | null, tokens: null): EventFilter;
  };

  estimate: {
    name(overrides?: TransactionOverrides): Promise<BigNumber>;

    "name()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    approve(
      spender: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "approve(address,uint256)"(
      spender: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    cashtokenName(overrides?: TransactionOverrides): Promise<BigNumber>;

    "cashtokenName()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    totalSupply(overrides?: TransactionOverrides): Promise<BigNumber>;

    "totalSupply()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    deposits(
      arg0: string,
      arg1: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "deposits(address,bytes32)"(
      arg0: string,
      arg1: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    balances(
      arg0: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "balances(address)"(
      arg0: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    decimals(overrides?: TransactionOverrides): Promise<BigNumber>;

    "decimals()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    balanceOf(
      tokenOwner: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "balanceOf(address)"(
      tokenOwner: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    /**
 * Leaves the contract without owner. It will not be possible to call
 `onlyOwner` functions anymore. Can only be called by the current owner.
      * > Note: Renouncing ownership will leave the contract without an owner,
 thereby removing any functionality that is only available to the owner.
 */
    renounceOwnership(overrides?: TransactionOverrides): Promise<BigNumber>;

    /**
 * Leaves the contract without owner. It will not be possible to call
 `onlyOwner` functions anymore. Can only be called by the current owner.
      * > Note: Renouncing ownership will leave the contract without an owner,
 thereby removing any functionality that is only available to the owner.
 */
    "renounceOwnership()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    /**
     * Returns the address of the current owner.
     */
    owner(overrides?: TransactionOverrides): Promise<BigNumber>;

    /**
     * Returns the address of the current owner.
     */
    "owner()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    /**
     * Returns true if the caller is the current owner.
     */
    isOwner(overrides?: TransactionOverrides): Promise<BigNumber>;

    /**
     * Returns true if the caller is the current owner.
     */
    "isOwner()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    symbol(overrides?: TransactionOverrides): Promise<BigNumber>;

    "symbol()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    transfer(
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "transfer(address,uint256)"(
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    allowance(
      tokenOwner: string,
      spender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "allowance(address,address)"(
      tokenOwner: string,
      spender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    /**
 * Transfers ownership of the contract to a new account (`newOwner`).
 Can only be called by the current owner.
 */
    transferOwnership(
      newOwner: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    /**
 * Transfers ownership of the contract to a new account (`newOwner`).
 Can only be called by the current owner.
 */
    "transferOwnership(address)"(
      newOwner: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    initialize(
      _name: Arrayish,
      _type: Arrayish,
      _owner: string,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "initialize(bytes32,bytes32,address,address,address)"(
      _name: Arrayish,
      _type: Arrayish,
      _owner: string,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    "initialize(address)"(
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    transferFrom(
      sender: string,
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "transferFrom(address,address,uint256)"(
      sender: string,
      receiver: string,
      tokens: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    requestAddToBalance(
      tokens: Arrayish,
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "requestAddToBalance(bytes16,address)"(
      tokens: Arrayish,
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    requestDeductFromBalance(
      tokens: Arrayish,
      receiver: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "requestDeductFromBalance(bytes16,address)"(
      tokens: Arrayish,
      receiver: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    requestIssue(
      amount: Arrayish,
      buyer: string,
      currency: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "requestIssue(bytes16,address,bytes32)"(
      amount: Arrayish,
      buyer: string,
      currency: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    convert(
      txId: Arrayish,
      result: Arrayish,
      rtype: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "convert(bytes32,bytes16,bytes32)"(
      txId: Arrayish,
      result: Arrayish,
      rtype: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;
  };
}