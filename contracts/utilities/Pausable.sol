pragma solidity >=0.5.0 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

contract Pausable is Ownable {
    bool paused;
    function pause() public {
        require(msg.sender == owner());
        paused = true;
    }
    function unpause() public {
        require(msg.sender == owner());
        paused = false;
    }
}