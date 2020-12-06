// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../utilities/ProxiesFactory.sol";
import "../Token.sol";

contract TokenFactory is ProxiesFactory {
    constructor() public ProxiesFactory(type(Token).creationCode) {}
} 