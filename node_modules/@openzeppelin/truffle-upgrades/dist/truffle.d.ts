import { SourceUnit } from 'solidity-ast';
export interface Deployer {
    provider: TruffleProvider;
    deploy(contract: ContractClass, ...args: unknown[]): Promise<ContractInstance>;
}
export interface ContractClass {
    new (address: string): ContractInstance;
    'new'(...args: unknown[]): ContractInstance;
    deployed(): Promise<ContractInstance>;
    setProvider(provider: TruffleProvider): void;
    defaults(defaults: ContractClassDefaults): void;
    bytecode: string;
    currentProvider: TruffleProvider;
    class_defaults: ContractClassDefaults;
    contractName: string;
    address?: string;
    networks?: {
        [id: string]: NetworkObject;
    };
}
export interface NetworkObject {
    address?: string;
    transactionHash?: string;
    links: {
        [libName: string]: string;
    };
}
export interface ContractClassDefaults {
    from: string;
    gas: number;
    gasPrice: number;
}
export interface ContractInstance {
    address: string;
    transactionHash?: string;
    contract: {
        methods: {
            [name: string]: (...args: unknown[]) => {
                encodeABI(): string;
            };
        };
    };
    [other: string]: any;
}
export interface TruffleArtifact {
    contractName: string;
    sourcePath: string;
    source: string;
    bytecode: string;
    ast?: SourceUnit;
}
declare type TruffleProviderResult = {
    result: any;
    error: {
        message: string;
    };
};
export interface TruffleProvider {
    send(args: {
        method: string;
        params: unknown[];
        id: string;
        jsonrpc: '2.0';
    }, callback: (err: Error | null, value: TruffleProviderResult) => void): void;
}
export interface TruffleConfig {
    provider: TruffleProvider;
    contracts_build_directory: string;
    contracts_directory: string;
    from: string;
    gas: number;
    gasPrice: number;
}
export declare function getTruffleConfig(): TruffleConfig;
export declare function getTruffleDefaults(): ContractClassDefaults;
export declare function getTruffleProvider(): TruffleProvider;
export declare const TruffleContract: (artifact: unknown) => ContractClass;
export {};
//# sourceMappingURL=truffle.d.ts.map