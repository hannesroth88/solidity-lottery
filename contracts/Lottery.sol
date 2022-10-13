// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Lottery {
    /* State variables */
    address payable[] private s_raffleAddressArray;
    address public immutable owner;
    uint256 public i_payableAmount = 1e15;

    /* Exceptions */
    error ExceptionNotEnoughEth();

    /* Events */
    event RaffleEntered(address indexed player);

    constructor() {
        owner = msg.sender;
    }

    // user can enter Raffle
    function enterRaffle() public payable {
        // check if payabl e amount > 0.001
        if (msg.value < i_payableAmount) {
            revert ExceptionNotEnoughEth();
        }
        // add to the array
        s_raffleAddressArray.push(payable(msg.sender));
        // emit an event when we update a dynamic array
        emit RaffleEntered(msg.sender);
    }

    /*  removed because, public keyword is more gasefficient
    function getPayableAmount() public view returns(uint256) {
        return i_payableAmount;
    } */

    // function drawRaffle(){}
}
