"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.migrateManifest = exports.Manifest = void 0;
const path_1 = __importDefault(require("path"));
const fs_1 = require("fs");
const provider_1 = require("./provider");
const t = __importStar(require("io-ts"));
const proper_lockfile_1 = __importDefault(require("proper-lockfile"));
const compare_versions_1 = require("compare-versions");
const currentManifestVersion = '3.1';
function defaultManifest() {
    return {
        manifestVersion: currentManifestVersion,
        impls: {},
    };
}
const manifestDir = '.openzeppelin';
class Manifest {
    constructor(chainId) {
        var _a;
        this.locked = false;
        const name = (_a = provider_1.networkNames[chainId]) !== null && _a !== void 0 ? _a : `unknown-${chainId}`;
        this.file = path_1.default.join(manifestDir, `${name}.json`);
    }
    static async forNetwork(provider) {
        return new Manifest(await provider_1.getChainId(provider));
    }
    async getAdmin() {
        return (await this.read()).admin;
    }
    async getDeploymentFromAddress(address) {
        const data = await this.read();
        const deployment = Object.values(data.impls).find(d => (d === null || d === void 0 ? void 0 : d.address) === address);
        if (deployment === undefined) {
            throw new Error(`Deployment at address ${address} is not registered`);
        }
        return deployment;
    }
    async read() {
        const release = this.locked ? undefined : await this.lock();
        try {
            const data = JSON.parse(await fs_1.promises.readFile(this.file, 'utf8'));
            return validateOrUpdateManifestVersion(data);
        }
        catch (e) {
            if (e.code === 'ENOENT') {
                return defaultManifest();
            }
            else {
                throw e;
            }
        }
        finally {
            await (release === null || release === void 0 ? void 0 : release());
        }
    }
    async write(data) {
        if (!this.locked) {
            throw new Error('Manifest must be locked');
        }
        const normalized = normalizeManifestData(data);
        await fs_1.promises.writeFile(this.file, JSON.stringify(normalized, null, 2) + '\n');
    }
    async lockedRun(cb) {
        if (this.locked) {
            throw new Error('Manifest is already locked');
        }
        const release = await this.lock();
        try {
            return await cb();
        }
        finally {
            await release();
        }
    }
    async lock() {
        await fs_1.promises.mkdir(path_1.default.dirname(this.file), { recursive: true });
        const release = await proper_lockfile_1.default.lock(this.file, { retries: 3, realpath: false });
        this.locked = true;
        return async () => {
            await release();
            this.locked = false;
        };
    }
}
exports.Manifest = Manifest;
function validateOrUpdateManifestVersion(data) {
    if (typeof data.manifestVersion !== 'string') {
        throw new Error('Manifest version is missing');
    }
    else if (compare_versions_1.compare(data.manifestVersion, '3.0', '<')) {
        throw new Error('Found a manifest file for OpenZeppelin CLI. An automated migration is not yet available.');
    }
    else if (compare_versions_1.compare(data.manifestVersion, currentManifestVersion, '<')) {
        return migrateManifest(data);
    }
    else if (data.manifestVersion === currentManifestVersion) {
        return data;
    }
    else {
        throw new Error(`Unknown value for manifest version (${data.manifestVersion})`);
    }
}
function migrateManifest(data) {
    if (data.manifestVersion === '3.0') {
        data.manifestVersion = currentManifestVersion;
        return data;
    }
    else {
        throw new Error('Manifest migration not available');
    }
}
exports.migrateManifest = migrateManifest;
const tNullable = (codec) => t.union([codec, t.undefined]);
const DeploymentCodec = t.intersection([
    t.strict({
        address: t.string,
    }),
    t.partial({
        txHash: t.string,
    }),
]);
const ManifestDataCodec = t.intersection([
    t.strict({
        manifestVersion: t.string,
        impls: t.record(t.string, tNullable(t.intersection([DeploymentCodec, t.strict({ layout: t.any })]))),
    }),
    t.partial({
        admin: tNullable(DeploymentCodec),
    }),
]);
function normalizeManifestData(data) {
    return ManifestDataCodec.encode(data);
}
//# sourceMappingURL=manifest.js.map