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

interface OwnableInterface extends Interface {
  functions: {
    initialize: TypedFunctionDescription<{
      encode([sender]: [string]): string;
    }>;

    owner: TypedFunctionDescription<{ encode([]: []): string }>;

    isOwner: TypedFunctionDescription<{ encode([]: []): string }>;

    renounceOwnership: TypedFunctionDescription<{ encode([]: []): string }>;

    transferOwnership: TypedFunctionDescription<{
      encode([newOwner]: [string]): string;
    }>;
  };

  events: {
    OwnershipTransferred: TypedEventDescription<{
      encodeTopics([previousOwner, newOwner]: [
        string | null,
        string | null
      ]): string[];
    }>;
  };
}

export class Ownable extends Contract {
  connect(signerOrProvider: Signer | Provider | string): Ownable;
  attach(addressOrName: string): Ownable;
  deployed(): Promise<Ownable>;

  on(event: EventFilter | string, listener: Listener): Ownable;
  once(event: EventFilter | string, listener: Listener): Ownable;
  addListener(eventName: EventFilter | string, listener: Listener): Ownable;
  removeAllListeners(eventName: EventFilter | string): Ownable;
  removeListener(eventName: any, listener: Listener): Ownable;

  interface: OwnableInterface;

  functions: {
    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    initialize(
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    "initialize(address)"(
      sender: string,
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
  };

  /**
   * Initializes the contract setting the deployer as the initial owner.
   */
  initialize(
    sender: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  /**
   * Initializes the contract setting the deployer as the initial owner.
   */
  "initialize(address)"(
    sender: string,
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

  filters: {
    OwnershipTransferred(
      previousOwner: string | null,
      newOwner: string | null
    ): EventFilter;
  };

  estimate: {
    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    initialize(
      sender: string,
      overrides?: TransactionOverrides
    ): Promise<BigNumber>;

    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    "initialize(address)"(
      sender: string,
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
  };
}