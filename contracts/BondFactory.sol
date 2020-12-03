pragma solidity >=0.6.0 <0.8.0;

import "./utilities/ProxiesFactory.sol";
import "./Bond.sol";

contract BondFactory is ProxiesFactory {
    constructor() public ProxiesFactory(type(Bond).creationCode) {}
} 