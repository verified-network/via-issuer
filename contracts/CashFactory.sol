pragma solidity >=0.6.0 <0.8.0;

import "./utilities/ProxiesFactory.sol";
import "./Cash.sol";

contract CashFactory is ProxiesFactory {
    constructor() public ProxiesFactory(type(Cash).creationCode) {}
} 