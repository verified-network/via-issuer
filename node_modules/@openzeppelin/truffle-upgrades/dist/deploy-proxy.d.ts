import { ContractClass, ContractInstance } from './truffle';
import { Options } from './options';
interface InitializerOptions {
    initializer?: string | false;
}
export declare function deployProxy(Contract: ContractClass, opts?: Options & InitializerOptions): Promise<ContractInstance>;
export declare function deployProxy(Contract: ContractClass, args?: unknown[], opts?: Options & InitializerOptions): Promise<ContractInstance>;
export {};
//# sourceMappingURL=deploy-proxy.d.ts.map