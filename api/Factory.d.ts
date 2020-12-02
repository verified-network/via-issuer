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

interface FactoryInterface extends Interface {
  functions: {
    getSigner: TypedFunctionDescription<{
      encode([_salt, _logic, _admin, _data, _signature]: [
        BigNumberish,
        string,
        string,
        Arrayish,
        Arrayish
      ]): string;
    }>;

    deploySigned: TypedFunctionDescription<{
      encode([_salt, _logic, _admin, _data, _signature]: [
        BigNumberish,
        string,
        string,
        Arrayish,
        Arrayish
      ]): string;
    }>;

    tokens: TypedFunctionDescription<{ encode([]: [BigNumberish]): string }>;

    deploy: TypedFunctionDescription<{
      encode([_salt, _logic, _admin, _data]: [
        BigNumberish,
        string,
        string,
        Arrayish
      ]): string;
    }>;

    token: TypedFunctionDescription<{ encode([]: [string]): string }>;

    renounceOwnership: TypedFunctionDescription<{ encode([]: []): string }>;

    getDeploymentAddress: TypedFunctionDescription<{
      encode([_salt, _sender]: [BigNumberish, string]): string;
    }>;

    owner: TypedFunctionDescription<{ encode([]: []): string }>;

    isOwner: TypedFunctionDescription<{ encode([]: []): string }>;

    deployMinimal: TypedFunctionDescription<{
      encode([_logic, _data]: [string, Arrayish]): string;
    }>;

    transferOwnership: TypedFunctionDescription<{
      encode([newOwner]: [string]): string;
    }>;

    initialize: TypedFunctionDescription<{ encode([]: []): string }>;

    getTokenCount: TypedFunctionDescription<{ encode([]: []): string }>;

    getToken: TypedFunctionDescription<{ encode([n]: [BigNumberish]): string }>;

    getName: TypedFunctionDescription<{
      encode([viaAddress]: [string]): string;
    }>;

    getType: TypedFunctionDescription<{
      encode([viaAddress]: [string]): string;
    }>;

    getNameAndType: TypedFunctionDescription<{
      encode([viaAddress]: [string]): string;
    }>;

    getProduct: TypedFunctionDescription<{
      encode([symbol]: [Arrayish]): string;
    }>;

    getIssuer: TypedFunctionDescription<{
      encode([tokenType, tokenName]: [Arrayish, Arrayish]): string;
    }>;

    createIssuer: TypedFunctionDescription<{
      encode([salt, _target, tokenName, tokenType, _oracle, _token]: [
        BigNumberish,
        string,
        Arrayish,
        Arrayish,
        string,
        string
      ]): string;
    }>;

    createToken: TypedFunctionDescription<{
      encode([_target, tokenName, tokenProduct, tokenSymbol]: [
        string,
        Arrayish,
        Arrayish,
        Arrayish
      ]): string;
    }>;
  };

  events: {
    IssuerCreated: TypedEventDescription<{
      encodeTopics([_address, tokenName, tokenType]: [
        string | null,
        null,
        null
      ]): string[];
    }>;

    TokenCreated: TypedEventDescription<{
      encodeTopics([_address, tokenName, tokenType]: [
        string | null,
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

    ProxyCreated: TypedEventDescription<{
      encodeTopics([proxy]: [null]): string[];
    }>;
  };
}

export class Factory extends Contract {
  connect(signerOrProvider: Signer | Provider | string): Factory;
  attach(addressOrName: string): Factory;
  deployed(): Promise<Factory>;

  on(event: EventFilter | string, listener: Listener): Factory;
  once(event: EventFilter | string, listener: Listener): Factory;
  addListener(eventName: EventFilter | string, listener: Listener): Factory;
  removeAllListeners(eventName: EventFilter | string): Factory;
  removeListener(eventName: any, listener: Listener): Factory;

  interface: FactoryInterface;

  functions: {
    getSigner(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "getSigner(uint256,address,address,bytes,bytes)"(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    deploySigned(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "deploySigned(uint256,address,address,bytes,bytes)"(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    tokens(
      arg0: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "tokens(uint256)"(
      arg0: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    deploy(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "deploy(uint256,address,address,bytes)"(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    token(
      arg0: string,
      overrides?: TransactionOverrides
    ): Promise<{
      tokenType: string;
      name: string;
      0: string;
      1: string;
    }>;

    "token(address)"(
      arg0: string,
      overrides?: TransactionOverrides
    ): Promise<{
      tokenType: string;
      name: string;
      0: string;
      1: string;
    }>;

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

    getDeploymentAddress(
      _salt: BigNumberish,
      _sender: string,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "getDeploymentAddress(uint256,address)"(
      _salt: BigNumberish,
      _sender: string,
      overrides?: TransactionOverrides
    ): Promise<string>;

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

    deployMinimal(
      _logic: string,
      _data: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "deployMinimal(address,bytes)"(
      _logic: string,
      _data: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

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

    initialize(overrides?: TransactionOverrides): Promise<ContractTransaction>;

    "initialize()"(
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    "initialize(address)"(
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    getTokenCount(overrides?: TransactionOverrides): Promise<BigNumber>;

    "getTokenCount()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    getToken(
      n: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "getToken(uint256)"(
      n: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    getName(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "getName(address)"(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<string>;

    getType(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "getType(address)"(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<string>;

    getNameAndType(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<{
      0: string;
      1: string;
    }>;

    "getNameAndType(address)"(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<{
      0: string;
      1: string;
    }>;

    getProduct(
      symbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "getProduct(bytes32)"(
      symbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    getIssuer(
      tokenType: Arrayish,
      tokenName: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    "getIssuer(bytes32,bytes32)"(
      tokenType: Arrayish,
      tokenName: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<string>;

    createIssuer(
      salt: BigNumberish,
      _target: string,
      tokenName: Arrayish,
      tokenType: Arrayish,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "createIssuer(uint256,address,bytes32,bytes32,address,address)"(
      salt: BigNumberish,
      _target: string,
      tokenName: Arrayish,
      tokenType: Arrayish,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    createToken(
      _target: string,
      tokenName: Arrayish,
      tokenProduct: Arrayish,
      tokenSymbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    "createToken(address,bytes32,bytes32,bytes32)"(
      _target: string,
      tokenName: Arrayish,
      tokenProduct: Arrayish,
      tokenSymbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;
  };

  getSigner(
    _salt: BigNumberish,
    _logic: string,
    _admin: string,
    _data: Arrayish,
    _signature: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  "getSigner(uint256,address,address,bytes,bytes)"(
    _salt: BigNumberish,
    _logic: string,
    _admin: string,
    _data: Arrayish,
    _signature: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  deploySigned(
    _salt: BigNumberish,
    _logic: string,
    _admin: string,
    _data: Arrayish,
    _signature: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "deploySigned(uint256,address,address,bytes,bytes)"(
    _salt: BigNumberish,
    _logic: string,
    _admin: string,
    _data: Arrayish,
    _signature: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  tokens(arg0: BigNumberish, overrides?: TransactionOverrides): Promise<string>;

  "tokens(uint256)"(
    arg0: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  deploy(
    _salt: BigNumberish,
    _logic: string,
    _admin: string,
    _data: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "deploy(uint256,address,address,bytes)"(
    _salt: BigNumberish,
    _logic: string,
    _admin: string,
    _data: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  token(
    arg0: string,
    overrides?: TransactionOverrides
  ): Promise<{
    tokenType: string;
    name: string;
    0: string;
    1: string;
  }>;

  "token(address)"(
    arg0: string,
    overrides?: TransactionOverrides
  ): Promise<{
    tokenType: string;
    name: string;
    0: string;
    1: string;
  }>;

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

  getDeploymentAddress(
    _salt: BigNumberish,
    _sender: string,
    overrides?: TransactionOverrides
  ): Promise<string>;

  "getDeploymentAddress(uint256,address)"(
    _salt: BigNumberish,
    _sender: string,
    overrides?: TransactionOverrides
  ): Promise<string>;

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

  deployMinimal(
    _logic: string,
    _data: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "deployMinimal(address,bytes)"(
    _logic: string,
    _data: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

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

  initialize(overrides?: TransactionOverrides): Promise<ContractTransaction>;

  "initialize()"(
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  /**
   * Initializes the contract setting the deployer as the initial owner.
   */
  "initialize(address)"(
    sender: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  getTokenCount(overrides?: TransactionOverrides): Promise<BigNumber>;

  "getTokenCount()"(overrides?: TransactionOverrides): Promise<BigNumber>;

  getToken(n: BigNumberish, overrides?: TransactionOverrides): Promise<string>;

  "getToken(uint256)"(
    n: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  getName(
    viaAddress: string,
    overrides?: TransactionOverrides
  ): Promise<string>;

  "getName(address)"(
    viaAddress: string,
    overrides?: TransactionOverrides
  ): Promise<string>;

  getType(
    viaAddress: string,
    overrides?: TransactionOverrides
  ): Promise<string>;

  "getType(address)"(
    viaAddress: string,
    overrides?: TransactionOverrides
  ): Promise<string>;

  getNameAndType(
    viaAddress: string,
    overrides?: TransactionOverrides
  ): Promise<{
    0: string;
    1: string;
  }>;

  "getNameAndType(address)"(
    viaAddress: string,
    overrides?: TransactionOverrides
  ): Promise<{
    0: string;
    1: string;
  }>;

  getProduct(
    symbol: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  "getProduct(bytes32)"(
    symbol: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  getIssuer(
    tokenType: Arrayish,
    tokenName: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  "getIssuer(bytes32,bytes32)"(
    tokenType: Arrayish,
    tokenName: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<string>;

  createIssuer(
    salt: BigNumberish,
    _target: string,
    tokenName: Arrayish,
    tokenType: Arrayish,
    _oracle: string,
    _token: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "createIssuer(uint256,address,bytes32,bytes32,address,address)"(
    salt: BigNumberish,
    _target: string,
    tokenName: Arrayish,
    tokenType: Arrayish,
    _oracle: string,
    _token: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  createToken(
    _target: string,
    tokenName: Arrayish,
    tokenProduct: Arrayish,
    tokenSymbol: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  "createToken(address,bytes32,bytes32,bytes32)"(
    _target: string,
    tokenName: Arrayish,
    tokenProduct: Arrayish,
    tokenSymbol: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  filters: {
    IssuerCreated(
      _address: string | null,
      tokenName: null,
      tokenType: null
    ): EventFilter;

    TokenCreated(
      _address: string | null,
      tokenName: null,
      tokenType: null
    ): EventFilter;

    OwnershipTransferred(
      previousOwner: string | null,
      newOwner: string | null
    ): EventFilter;

    ProxyCreated(proxy: null): EventFilter;
  };

  estimate: {
    getSigner(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getSigner(uint256,address,address,bytes,bytes)"(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    deploySigned(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "deploySigned(uint256,address,address,bytes,bytes)"(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      _signature: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    tokens(
      arg0: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "tokens(uint256)"(
      arg0: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    deploy(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "deploy(uint256,address,address,bytes)"(
      _salt: BigNumberish,
      _logic: string,
      _admin: string,
      _data: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    token(arg0: string, overrides?: TransactionOverrides): Promise<BigNumber>;

    "token(address)"(
      arg0: string,
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

    getDeploymentAddress(
      _salt: BigNumberish,
      _sender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getDeploymentAddress(uint256,address)"(
      _salt: BigNumberish,
      _sender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

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

    deployMinimal(
      _logic: string,
      _data: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "deployMinimal(address,bytes)"(
      _logic: string,
      _data: Arrayish,
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

    initialize(overrides?: TransactionOverrides): Promise<BigNumber>;

    "initialize()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    "initialize(address)"(
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    getTokenCount(overrides?: TransactionOverrides): Promise<BigNumber>;

    "getTokenCount()"(overrides?: TransactionOverrides): Promise<BigNumber>;

    getToken(
      n: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getToken(uint256)"(
      n: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    getName(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getName(address)"(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    getType(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getType(address)"(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    getNameAndType(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getNameAndType(address)"(
      viaAddress: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    getProduct(
      symbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getProduct(bytes32)"(
      symbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    getIssuer(
      tokenType: Arrayish,
      tokenName: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "getIssuer(bytes32,bytes32)"(
      tokenType: Arrayish,
      tokenName: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    createIssuer(
      salt: BigNumberish,
      _target: string,
      tokenName: Arrayish,
      tokenType: Arrayish,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "createIssuer(uint256,address,bytes32,bytes32,address,address)"(
      salt: BigNumberish,
      _target: string,
      tokenName: Arrayish,
      tokenType: Arrayish,
      _oracle: string,
      _token: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    createToken(
      _target: string,
      tokenName: Arrayish,
      tokenProduct: Arrayish,
      tokenSymbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    "createToken(address,bytes32,bytes32,bytes32)"(
      _target: string,
      tokenName: Arrayish,
      tokenProduct: Arrayish,
      tokenSymbol: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;
  };
}