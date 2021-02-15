// (c) Kallol Borah, 2020
// Client interface
// SPDX-License-Identifier: MIT

pragma solidity 0.5.7;

interface VerifiedClient{

    function setCustody(address _client, address _account) external;

    function getCustody(address _client) external view returns(address);

    function setAccess(bool login) external;

    function getAccess(address _client) external view returns(uint256, uint256);

    function setManager(address _client, address _manager) external;

    function getManager(address _client) external view returns(address);

    function isRegistered(address _client) external view returns(bool);

    function setAMLStatus(address _client, bool status) external;

    function getAMLStatus(address _client) external view returns(bool);

}