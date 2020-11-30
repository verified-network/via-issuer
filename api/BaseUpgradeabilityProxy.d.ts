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

interface BaseUpgradeabilityProxyInterface extends Interface {
  functions: {};

  events: {
    Upgraded: TypedEventDescription<{
      encodeTopics([implementation]: [string | null]): string[];
    }>;
  };
}

export class BaseUpgradeabilityProxy extends Contract {
  connect(
    signerOrProvider: Signer | Provider | string
  ): BaseUpgradeabilityProxy;
  attach(addressOrName: string): BaseUpgradeabilityProxy;
  deployed(): Promise<BaseUpgradeabilityProxy>;

  on(event: EventFilter | string, listener: Listener): BaseUpgradeabilityProxy;
  once(
    event: EventFilter | string,
    listener: Listener
  ): BaseUpgradeabilityProxy;
  addListener(
    eventName: EventFilter | string,
    listener: Listener
  ): BaseUpgradeabilityProxy;
  removeAllListeners(eventName: EventFilter | string): BaseUpgradeabilityProxy;
  removeListener(eventName: any, listener: Listener): BaseUpgradeabilityProxy;

  interface: BaseUpgradeabilityProxyInterface;

  functions: {};

  filters: {
    Upgraded(implementation: string | null): EventFilter;
  };

  estimate: {};
}
