/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, ContractFactory, Signer } from "ethers";
import { Provider } from "ethers/providers";
import { UnsignedTransaction } from "ethers/utils/transaction";

import { TransactionOverrides } from "..";
import { ERC20 } from "../ERC20";

export class ERC20__factory extends ContractFactory {
  constructor(signer?: Signer) {
    super(_abi, _bytecode, signer);
  }

  deploy(overrides?: TransactionOverrides): Promise<ERC20> {
    return super.deploy(overrides) as Promise<ERC20>;
  }
  getDeployTransaction(overrides?: TransactionOverrides): UnsignedTransaction {
    return super.getDeployTransaction(overrides);
  }
  attach(address: string): ERC20 {
    return super.attach(address) as ERC20;
  }
  connect(signer: Signer): ERC20__factory {
    return super.connect(signer) as ERC20__factory;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): ERC20 {
    return new Contract(address, _abi, signerOrProvider) as ERC20;
  }
}

const _abi = [
  {
    constant: true,
    inputs: [
      {
        name: "",
        type: "address",
      },
    ],
    name: "balances",
    outputs: [
      {
        name: "",
        type: "bytes16",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: true,
    inputs: [],
    name: "decimals",
    outputs: [
      {
        name: "",
        type: "uint8",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        name: "tokenOwner",
        type: "address",
      },
      {
        indexed: true,
        name: "spender",
        type: "address",
      },
      {
        indexed: false,
        name: "tokens",
        type: "uint256",
      },
    ],
    name: "Approval",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        name: "tokens",
        type: "uint256",
      },
    ],
    name: "Transfer",
    type: "event",
  },
  {
    constant: true,
    inputs: [],
    name: "totalSupply",
    outputs: [
      {
        name: "",
        type: "uint256",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: true,
    inputs: [
      {
        name: "tokenOwner",
        type: "address",
      },
    ],
    name: "balanceOf",
    outputs: [
      {
        name: "",
        type: "uint256",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      {
        name: "receiver",
        type: "address",
      },
      {
        name: "tokens",
        type: "uint256",
      },
    ],
    name: "transfer",
    outputs: [
      {
        name: "",
        type: "bool",
      },
    ],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      {
        name: "spender",
        type: "address",
      },
      {
        name: "tokens",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        name: "",
        type: "bool",
      },
    ],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: true,
    inputs: [
      {
        name: "tokenOwner",
        type: "address",
      },
      {
        name: "spender",
        type: "address",
      },
    ],
    name: "allowance",
    outputs: [
      {
        name: "",
        type: "uint256",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      {
        name: "owner",
        type: "address",
      },
      {
        name: "buyer",
        type: "address",
      },
      {
        name: "tokens",
        type: "uint256",
      },
    ],
    name: "transferFrom",
    outputs: [
      {
        name: "",
        type: "bool",
      },
    ],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x608060405234801561001057600080fd5b50610d6e806100206000396000f3fe608060405234801561001057600080fd5b50600436106100885760003560e01c8063313ce5671161005b578063313ce5671461016057806370a082311461017e578063a9059cbb146101a4578063dd62ed3e146101d057610088565b8063095ea7b31461008d57806318160ddd146100cd57806323b872dd146100e757806327e235e31461011d575b600080fd5b6100b9600480360360408110156100a357600080fd5b506001600160a01b0381351690602001356101fe565b604080519115158252519081900360200190f35b6100d5610286565b60408051918252519081900360200190f35b6100b9600480360360608110156100fd57600080fd5b506001600160a01b0381358116916020810135909116906040013561029d565b6101436004803603602081101561013357600080fd5b50356001600160a01b0316610499565b604080516001600160801b03199092168252519081900360200190f35b6101686104ae565b6040805160ff9092168252519081900360200190f35b6100d56004803603602081101561019457600080fd5b50356001600160a01b03166104be565b6100b9600480360360408110156101ba57600080fd5b506001600160a01b0381351690602001356104eb565b6100d5600480360360408110156101e657600080fd5b506001600160a01b038135811691602001351661060c565b600061020982610647565b3360008181526003602090815260408083206001600160a01b0389168085529083529281902080546001600160801b03191660809690961c959095179094558351868152935191937f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925929081900390910190a35060015b92915050565b6001546000906102989060801b6106ac565b905090565b60006102cc6102ab83610647565b6001600160a01b03861660009081526002602052604090205460801b610744565b60000b60001914806102ea57506102e56102ab83610647565b60000b155b6102f357600080fd5b61032b6102ff83610647565b6001600160a01b038616600090815260036020908152604080832033845290915290205460801b610744565b60000b600019148061034957506103446102ff83610647565b60000b155b61035257600080fd5b6001600160a01b0384166000908152600260205260409020546103809060801b61037b84610647565b61088d565b6001600160a01b038516600090815260026020908152604080832080546001600160801b031916608095861c179055600382528083203384529091529020546103cd911b61037b84610647565b6001600160a01b038581166000908152600360209081526040808320338452825280832080546001600160801b031916608096871c1790559287168252600290522054610423911b61041e84610647565b61089b565b6001600160a01b0384811660008181526002602090815260409182902080546001600160801b03191660809690961c95909517909455805186815290519193928816927fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef92918290030190a35060019392505050565b60026020526000908152604090205460801b81565b600054600160a01b900460ff1681565b6001600160a01b0381166000908152600260205260408120546104e39060801b6106ac565b90505b919050565b60006105116104f983610647565b3060009081526002602052604090205460801b610744565b60000b600019148061052f575061052a6104f983610647565b60000b155b61053857600080fd5b306000908152600260205260409020546105589060801b61037b84610647565b3060009081526002602052604080822080546001600160801b031916608094851c1790556001600160a01b0386168252902054610599911b61041e84610647565b6001600160a01b03841660008181526002602090815260409182902080546001600160801b03191660809590951c9490941790935580518581529051919230927fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef9281900390910190a350600192915050565b6001600160a01b0380831660009081526003602090815260408083209385168352929052908120546106409060801b6106ac565b9392505050565b600081610656575060006104e6565b81600061066282610c9f565b9050607081101561067b578060700382901b915061068e565b607081111561068e576070810382901c91505b613fff0160701b6001600160701b03919091161760801b90506104e6565b6000617fff6001600160801b03608084901c1660701c16613fff8110156106d75760009150506104e6565b6001607f1b8360801c6001600160801b0316106106f357600080fd5b6140fe81111561070257600080fd5b600160701b6001600160701b03608085901c161761406f82101561072c5761406f8290031c610640565b61406f8211156106405761406e1982011b9392505050565b600060016001607f1b03608084901c16600160701b617fff0281111561076957600080fd5b60016001607f1b03608084901c16600160701b617fff0281111561078c57600080fd5b6001600160801b03198581169085161415806107b85750600160701b617fff02826001600160801b0316105b6107c157600080fd5b6001600160801b031985811690851614156107e157600092505050610280565b60006001607f1b8660801c6001600160801b03161015905060006001607f1b8660801c6001600160801b031610159050811561084c57801561083d57826001600160801b0316846001600160801b03161161083d576001610841565b6000195b945050505050610280565b801561085f576001945050505050610280565b826001600160801b0316846001600160801b03161161088057600019610841565b6001945050505050610280565b600061064083600160ff1b84185b6000617fff6001600160801b03608085811c8216607090811c8416939186901c90921690911c8116908214156109115780617fff1415610907576001600160801b031985811690851614156108f4578492505050610280565b50600160ef1b61ffff0291506102809050565b8492505050610280565b80617fff1415610925578392505050610280565b6001607f1b608086901c6001600160801b0381169190911015906001600160701b031683610956576001935061095d565b600160701b175b6001607f1b608087901c6001600160801b0381169190911015906001600160701b03168461098e5760019450610995565b600160701b175b826109c5576001600160801b03198816600160ff1b146109b557876109b8565b60005b9650505050505050610280565b806109e5576001600160801b03198916600160ff1b146109b557886109b8565b8486038415158315151415610af3576070811315610a0c5789975050505050505050610280565b6000811315610a1e5790811c90610a4d565b606f19811215610a375788975050505050505050610280565b6000811215610a4d578060000384901c93508596505b92810192600160711b8410610a68576001968701969390931c925b86617fff1415610a9d5784610a8557600160f01b617fff02610a8f565b6001600160f01b03195b975050505050505050610280565b600160701b841015610ab25760009650610abf565b6001600160701b03841693505b83607088901b86610ad1576000610ad7565b6001607f1b5b6001600160801b0316171760801b975050505050505050610280565b6000811315610b0e57600184901b9350600187039650610b25565b6000811215610b2557600182901b91506001860396505b6070811315610b375760019150610b84565b6001811315610b54576001810360018303901c6001019150610b84565b606f19811215610b675760019350610b84565b600019811215610b84576001816000030360018503901c60010193505b818410610b95578184039350610b9e565b83820393508294505b83610bb457506000965061028095505050505050565b6000610bbf85610c9f565b90508060711415610be557600185901c6001600160701b03169450600188019750610c34565b6070811015610c2757607081900380891115610c14578086901b6001600160701b031695508089039850610c21565b600098600019019590951b945b50610c34565b6001600160701b03851694505b87617fff1415610c6a5785610c5157600160f01b617fff02610c5b565b6001600160f01b03195b98505050505050505050610280565b84607089901b87610c7c576000610c82565b6001607f1b5b6001600160801b0316171760801b98505050505050505050610280565b6000808211610cad57600080fd5b6000600160801b8310610cc257608092831c92015b680100000000000000008310610cda57604092831c92015b6401000000008310610cee57602092831c92015b620100008310610d0057601092831c92015b6101008310610d1157600892831c92015b60108310610d2157600492831c92015b60048310610d3157600292831c92015b600283106104e3576001019291505056fea165627a7a7230582013e7ffc9634286fad8d4206999d0d456ccb1e273aa02c343c1dcf927550c7d4d0029";
