// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


/**
    * @notice a pausable contract implementation
*/
contract Pausable {
    bool internal paused;

    event Paused();
    event Unpaused();

    /**
        * @notice sould be called by a wrapper function implementing access control
    */
    function _pause() internal {
        paused = true;
        emit Paused();
    }

    /**
        * @notice sould be called by a wrapper function implementing access control
    */
    function _unpause() internal {
        paused = false;
        emit Unpaused();
    }

    /**
        * @notice returns whether or not the contract is paused
    */
    function isPaused() public view returns (bool) {
        return paused;
    }
}