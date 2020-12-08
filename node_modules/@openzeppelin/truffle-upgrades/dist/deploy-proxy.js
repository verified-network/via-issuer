"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deployProxy = void 0;
const upgrades_core_1 = require("@openzeppelin/upgrades-core");
const truffle_1 = require("./truffle");
const validate_1 = require("./validate");
const deploy_1 = require("./utils/deploy");
const factories_1 = require("./factories");
const wrap_provider_1 = require("./wrap-provider");
const options_1 = require("./options");
async function deployProxy(Contract, args = [], opts = {}) {
    if (!Array.isArray(args)) {
        opts = args;
        args = [];
    }
    const { deployer } = options_1.withDeployDefaults(opts);
    const provider = wrap_provider_1.wrapProvider(deployer.provider);
    const { contracts_build_directory, contracts_directory } = truffle_1.getTruffleConfig();
    const validations = await validate_1.validateArtifacts(contracts_build_directory, contracts_directory);
    const linkedBytecode = await validate_1.getLinkedBytecode(Contract, provider);
    const version = upgrades_core_1.getVersion(Contract.bytecode, linkedBytecode);
    upgrades_core_1.assertUpgradeSafe([validations], version, opts);
    const impl = await upgrades_core_1.fetchOrDeploy(version, provider, async () => {
        const deployment = await deploy_1.deploy(Contract, deployer);
        const layout = upgrades_core_1.getStorageLayout([validations], version);
        return { ...deployment, layout };
    });
    const AdminFactory = factories_1.getProxyAdminFactory(Contract);
    const adminAddress = await upgrades_core_1.fetchOrDeployAdmin(provider, () => deploy_1.deploy(AdminFactory, deployer));
    const data = getInitializerData(Contract, args, opts.initializer);
    const AdminUpgradeabilityProxy = factories_1.getProxyFactory(Contract);
    const proxy = await deployer.deploy(AdminUpgradeabilityProxy, impl, adminAddress, data);
    Contract.address = proxy.address;
    const contract = new Contract(proxy.address);
    contract.transactionHash = proxy.transactionHash;
    return contract;
}
exports.deployProxy = deployProxy;
function getInitializerData(Contract, args, initializer) {
    if (initializer === false) {
        return '0x';
    }
    const allowNoInitialization = initializer === undefined && args.length === 0;
    initializer = initializer !== null && initializer !== void 0 ? initializer : 'initialize';
    const stub = new Contract('');
    if (initializer in stub.contract.methods) {
        return stub.contract.methods[initializer](...args).encodeABI();
    }
    else if (allowNoInitialization) {
        return '0x';
    }
    else {
        throw new Error(`Contract ${Contract.name} does not have a function \`${initializer}\``);
    }
}
//# sourceMappingURL=deploy-proxy.js.map