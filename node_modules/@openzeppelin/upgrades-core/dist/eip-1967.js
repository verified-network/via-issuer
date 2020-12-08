"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.toEip1967Hash = exports.toFallbackEip1967Hash = exports.getImplementationAddress = exports.getAdminAddress = void 0;
const ethereumjs_util_1 = require("ethereumjs-util");
const bn_js_1 = __importDefault(require("bn.js"));
const provider_1 = require("./provider");
async function getAdminAddress(provider, address) {
    const ADMIN_LABEL = 'eip1967.proxy.admin';
    const FALLBACK_ADMIN_LABEL = 'org.zeppelinos.proxy.admin';
    const storage = await getEip1967Storage(provider, address, ADMIN_LABEL, FALLBACK_ADMIN_LABEL);
    return parseAddress(storage);
}
exports.getAdminAddress = getAdminAddress;
async function getImplementationAddress(provider, address) {
    const IMPLEMENTATION_LABEL = 'eip1967.proxy.implementation';
    const FALLBACK_IMPLEMENTATION_LABEL = 'org.zeppelinos.proxy.implementation';
    const storage = await getEip1967Storage(provider, address, IMPLEMENTATION_LABEL, FALLBACK_IMPLEMENTATION_LABEL);
    if (isEmptySlot(storage)) {
        throw new Error(`Contract at ${address} doesn't look like an EIP 1967 proxy`);
    }
    return parseAddress(storage);
}
exports.getImplementationAddress = getImplementationAddress;
async function getEip1967Storage(provider, address, slot, fallbackSlot) {
    let storage = await provider_1.getStorageAt(provider, address, toEip1967Hash(slot));
    if (isEmptySlot(storage)) {
        storage = await provider_1.getStorageAt(provider, address, toFallbackEip1967Hash(fallbackSlot));
    }
    return storage;
}
function toFallbackEip1967Hash(label) {
    return '0x' + ethereumjs_util_1.keccak256(Buffer.from(label)).toString('hex');
}
exports.toFallbackEip1967Hash = toFallbackEip1967Hash;
function toEip1967Hash(label) {
    const hash = ethereumjs_util_1.keccak256(Buffer.from(label));
    const bigNumber = new bn_js_1.default(hash).sub(new bn_js_1.default(1));
    return '0x' + bigNumber.toString(16);
}
exports.toEip1967Hash = toEip1967Hash;
function isEmptySlot(storage) {
    storage = storage.replace(/^0x/, '');
    return new bn_js_1.default(storage, 'hex').isZero();
}
function parseAddress(storage) {
    const buf = Buffer.from(storage.replace(/^0x/, ''), 'hex');
    if (!buf.slice(0, 12).equals(Buffer.alloc(12, 0))) {
        throw new Error(`Value in storage is not an address (${storage})`);
    }
    const address = '0x' + buf.toString('hex', 12, 32); // grab the last 20 bytes
    return ethereumjs_util_1.toChecksumAddress(address);
}
//# sourceMappingURL=eip-1967.js.map