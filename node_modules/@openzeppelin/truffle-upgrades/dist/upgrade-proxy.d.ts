import { ContractClass, ContractInstance } from './truffle';
import { Options } from './options';
export declare function prepareUpgrade(proxyAddress: string, Contract: ContractClass, opts?: Options): Promise<string>;
export declare function upgradeProxy(proxyAddress: string, Contract: ContractClass, opts?: Options): Promise<ContractInstance>;
//# sourceMappingURL=upgrade-proxy.d.ts.map