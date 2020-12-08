"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.wrapProvider = void 0;
const util_1 = require("util");
const crypto_1 = __importDefault(require("crypto"));
function wrapProvider(provider) {
    const web3Send = util_1.promisify(provider.send.bind(provider));
    return {
        async send(method, params) {
            const id = crypto_1.default.randomBytes(4).toString('hex');
            const { result, error } = await web3Send({ jsonrpc: '2.0', method, params, id });
            if (error) {
                throw new Error(error.message);
            }
            else {
                return result;
            }
        },
    };
}
exports.wrapProvider = wrapProvider;
//# sourceMappingURL=wrap-provider.js.map