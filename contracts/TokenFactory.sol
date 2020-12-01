pragma solidity >=0.6.0 <0.8.0;

import "./utilities/ProxiesFactory.sol";
import "./Token.sol";

contract TokenFactory is ProxiesFactory {
    constructor() public ProxiesFactory(type(Token).creationCode) {}
} 