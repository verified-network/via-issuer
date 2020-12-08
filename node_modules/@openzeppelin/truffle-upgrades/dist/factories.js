"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProxyAdminFactory = exports.getProxyFactory = void 0;
const AdminUpgradeabilityProxy_json_1 = __importDefault(require("@openzeppelin/upgrades-core/artifacts/contracts/proxy/AdminUpgradeabilityProxy.sol/AdminUpgradeabilityProxy.json"));
const ProxyAdmin_json_1 = __importDefault(require("@openzeppelin/upgrades-core/artifacts/contracts/proxy/ProxyAdmin.sol/ProxyAdmin.json"));
const truffle_1 = require("./truffle");
function getProxyFactory(template) {
    const AdminUpgradeabilityProxy = truffle_1.TruffleContract(AdminUpgradeabilityProxy_json_1.default);
    AdminUpgradeabilityProxy.setProvider(template.currentProvider);
    AdminUpgradeabilityProxy.defaults(template.class_defaults);
    return AdminUpgradeabilityProxy;
}
exports.getProxyFactory = getProxyFactory;
function getProxyAdminFactory(template) {
    var _a, _b;
    const ProxyAdmin = truffle_1.TruffleContract(ProxyAdmin_json_1.default);
    const defaults = (_a = template === null || template === void 0 ? void 0 : template.class_defaults) !== null && _a !== void 0 ? _a : truffle_1.getTruffleDefaults();
    const provider = (_b = template === null || template === void 0 ? void 0 : template.currentProvider) !== null && _b !== void 0 ? _b : truffle_1.getTruffleProvider();
    ProxyAdmin.setProvider(provider);
    ProxyAdmin.defaults(defaults);
    return ProxyAdmin;
}
exports.getProxyAdminFactory = getProxyAdminFactory;
//# sourceMappingURL=factories.js.map