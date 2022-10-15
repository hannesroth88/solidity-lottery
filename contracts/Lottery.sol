// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

contract Lottery is VRFConsumerBaseV2, AutomationCompatibleInterface {
    /* TYPES */
    enum RaffleState {
        OPEN,
        CALCULATING
    }
    /* STATE VARIABLES */
    // Lottery
    address payable[] private s_players;
    address private immutable owner;
    uint256 private immutable i_entranceFee;
    address private s_recentWinner;
    RaffleState private s_raffleState;
    uint256 private immutable i_interval;
    uint256 private s_timeStampLastRaffle;

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinatorInterface;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant NUMWORDS = 1;
    // Chainlink Automation Variables

    /* EXCEPTIONS */
    error ExceptionNotEnoughEth();
    error ExceptionTransferFailed();
    error ExceptionRaffleNotOpen();
    error ExceptionRaffleNotReady(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);

    /* EVENTS */
    event RaffleEntered(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(uint256 requestId, address indexed winner);

    constructor(
        uint256 entranceFee,
        address vRFCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vRFCoordinator) {
        owner = msg.sender;
        i_entranceFee = entranceFee;
        i_vrfCoordinatorInterface = VRFCoordinatorV2Interface(vRFCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        i_interval = interval;
        s_timeStampLastRaffle = block.timestamp;
    }

    // user can enter Raffle
    function enterRaffle() public payable {
        // check if payabl e amount > 0.001
        if (msg.value < i_entranceFee) {
            revert ExceptionNotEnoughEth();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert ExceptionRaffleNotOpen();
        }
        // add to the array
        s_players.push(payable(msg.sender));
        // emit an event when we update a dynamic array
        emit RaffleEntered(msg.sender);
    }

    function requestRandomWinner() internal {
        // Set State to CALCULATING so no new Players can enter
        s_raffleState = RaffleState.CALCULATING;
        // request random numbers
        uint256 requestId = i_vrfCoordinatorInterface.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUMWORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    // random word/number will be sent by Coordinators and call this function
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // modulo array length to get number between 0-9
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_timeStampLastRaffle = block.timestamp;
        // sent the whole balance to winner
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert ExceptionTransferFailed();
        }
        emit WinnerPicked(requestId, recentWinner);
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     */
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isOpen = (s_raffleState == RaffleState.OPEN);
        bool enoughTimePassed = ((block.timestamp - s_timeStampLastRaffle) > i_interval);
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = (address(this).balance > 0);
        upkeepNeeded = (isOpen && enoughTimePassed && hasPlayers && hasBalance);
    }

    /**
     * @dev Once `checkUpkeep` is returning `true`, this function is called
     * and it kicks off a Chainlink VRF call to get a random winner.
     * Note: external because own contract should not call this
     */
    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (upkeepNeeded) {
            revert ExceptionRaffleNotReady(address(this).balance, s_players.length, uint256(s_raffleState));
        }
        requestRandomWinner();
    }


    /** Getter Functions */

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getNumWords() public pure returns (uint256) {
        return NUMWORDS;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATION;
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getTimeStampLastRaffle( ) public view returns (uint256) {
        return s_timeStampLastRaffle;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }


    /*  removed because, public keyword is more gasefficient
    function getPayableAmount() public view returns(uint256) {
        return i_payableAmount;
    } */

    // function drawRaffle(){}

}
