pragma solidity >=0.5.0 <0.7.0;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

contract Pausable is Ownable {
    bool internal paused;

    event Paused();
    event Unpaused();

    function _pause() internal {
        paused = true;
        emit Paused();
    }

    function _unpause() internal {
        paused = false;
        emit Unpaused();
    }

    function isPaused() public view returns (bool) {
        return paused;
    }
}