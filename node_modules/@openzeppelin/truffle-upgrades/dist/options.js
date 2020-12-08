"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.withDeployDefaults = exports.withDefaults = void 0;
const truffle_1 = require("./truffle");
const upgrades_core_1 = require("@openzeppelin/upgrades-core");
function withDefaults(opts) {
    const { deployer } = withDeployDefaults(opts);
    const { unsafeAllowCustomTypes, unsafeAllowLinkedLibraries } = upgrades_core_1.withValidationDefaults(opts);
    return {
        deployer,
        unsafeAllowCustomTypes,
        unsafeAllowLinkedLibraries,
    };
}
exports.withDefaults = withDefaults;
function withDeployDefaults(opts) {
    var _a;
    return {
        deployer: (_a = opts.deployer) !== null && _a !== void 0 ? _a : defaultDeployer,
    };
}
exports.withDeployDefaults = withDeployDefaults;
const defaultDeployer = {
    get provider() {
        return truffle_1.getTruffleConfig().provider;
    },
    async deploy(Contract, ...args) {
        return Contract.new(...args);
    },
};
//# sourceMappingURL=options.js.map