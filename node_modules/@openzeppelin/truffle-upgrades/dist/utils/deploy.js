"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deploy = void 0;
async function deploy(contract, deployer) {
    const { address, transactionHash: txHash } = await deployer.deploy(contract);
    if (txHash === undefined) {
        throw new Error('Transaction hash is undefined');
    }
    return { address, txHash };
}
exports.deploy = deploy;
//# sourceMappingURL=deploy.js.map