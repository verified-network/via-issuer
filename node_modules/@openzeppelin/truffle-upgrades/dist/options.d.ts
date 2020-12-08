import { Deployer } from './truffle';
import { ValidationOptions } from '@openzeppelin/upgrades-core';
export declare type Options = DeployOptions & ValidationOptions;
export declare function withDefaults(opts: Options): Required<Options>;
export interface DeployOptions {
    deployer?: Deployer;
}
export declare function withDeployDefaults(opts: DeployOptions): Required<DeployOptions>;
//# sourceMappingURL=options.d.ts.map