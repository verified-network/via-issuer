// (c) Kallol Borah, 2020
// Implements token issued by Bond issuer. Can be reused by any financial product issuer

pragma solidity >=0.5.0 <0.7.0;

import "./erc/ERC20.sol";
import "./Bond.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "abdk-libraries-solidity/ABDKMathQuad.sol";

contract Token is ERC20, Initializable, Ownable {

    //Via token attributes (eg, name : Via-USD, product : ViaBond, symbol : bond identifier)
    bytes32 public name;
    bytes32 public product;
    bytes32 public symbol;
    address payable issuer;

    //initiliaze proxies
    function initialize(bytes32 _name, address payable _owner, bytes32 _product, bytes32 _symbol) public {
        Ownable.initialize(_owner);
        issuer = _owner;
        name = _name;
        symbol = _symbol;
        product = _product;
    }

    function addTotalSupply(bytes16 amount) external{
        //adjust total supply
        totalSupply_ = ABDKMathQuad.add(totalSupply_, amount);
    }

    function reduceSupply(bytes16 amount) external{        
        totalSupply_ = ABDKMathQuad.sub(totalSupply_, amount);
    }

    function addBalance(address party, bytes16 amount) external{
        //add via to this contract's balance first (ie issue them first)
        balances[party] = ABDKMathQuad.add(balances[party], amount);
    }

    function reduceBalance(address party, bytes16 amount) external{
        balances[party] = ABDKMathQuad.sub(balances[party], amount);
    }

    function transferFrom(address sender, address receiver, uint256 tokens) public returns (bool){
        //ensure sender has enough tokens in balance before transferring or redeeming them
        require(ABDKMathQuad.cmp(balances[sender],ABDKMathQuad.fromUInt(tokens))==1 ||
                ABDKMathQuad.cmp(balances[sender],ABDKMathQuad.fromUInt(tokens))==0);
        if(Bond(issuer).transferFoward(symbol, address(this), sender, receiver, tokens))
            return true;
        else
            return false;
    }

    function transferToken(address sender, address receiver, uint256 tokens) public returns (bool){
        //owner should have more tokens than being transferred
        if(ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), balances[sender])==-1 || ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), balances[sender])==0){
            //sending contract should be allowed by token owner to make this transfer
            //require(ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), allowed[sender][msg.sender])==-1 || ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), allowed[sender][msg.sender])==0);
            balances[sender] = ABDKMathQuad.sub(balances[sender], ABDKMathQuad.fromUInt(tokens));
            //allowed[sender][msg.sender] = ABDKMathQuad.sub(allowed[sender][msg.sender], ABDKMathQuad.fromUInt(tokens));
            balances[receiver] = ABDKMathQuad.add(balances[receiver], ABDKMathQuad.fromUInt(tokens));
            return true;
        }
        return false;
    }    

}