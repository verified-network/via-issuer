// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../utilities/ProxiesFactory.sol";
import "../Bond.sol";

contract BondFactory is ProxiesFactory {
    constructor() public ProxiesFactory(type(Bond).creationCode) {}
} 