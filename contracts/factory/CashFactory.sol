// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../utilities/ProxiesFactory.sol";
import "../Cash.sol";

contract CashFactory is ProxiesFactory {
    constructor() public ProxiesFactory(type(Cash).creationCode) {}
} 