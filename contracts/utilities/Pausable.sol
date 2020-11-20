pragma solidity >=0.5.0 <0.7.0;


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
        * @return True: contract is paused
        * @return False: contract is not paused
    */
    function isPaused() public view returns (bool) {
        return paused;
    }
}