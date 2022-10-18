/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/// Import this file to use console.log
import "hardhat/console.sol";


/**
@title A time lock Contract
@author Hafikraimy
*/
contract Lock {

    /**
    @dev create global variable which will be called by functions for different purposes
    */

    uint public unlockTime;
    address payable public owner;
    event Withdrawal(uint amount, uint when);

    /**
    @notice This function will run when this contract is deployed into the blockchain and will run only at that time
    @dev The current time must be less than the unlocking time 
    @param _unlockTime The time at which it will be unlocked
    */
    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    /**
    @dev emit the Withdrawal event after all the required statement have been satisfied
    */
    function withdraw() public {
        // Uncomment this line to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }
}
