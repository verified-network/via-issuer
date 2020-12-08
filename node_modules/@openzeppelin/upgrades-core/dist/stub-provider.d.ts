import { ImplDeployment } from './manifest';
export declare function stubProvider(chainId?: number): {
    mine: () => void;
    deploy: (immediate?: boolean) => Promise<ImplDeployment>;
    deployPending: () => Promise<ImplDeployment>;
    readonly deployCount: number;
    isContract(address: string): boolean;
    getMethodCount(method: string): number;
    send(method: string, params?: unknown[] | undefined): Promise<any>;
};
//# sourceMappingURL=stub-provider.d.ts.map