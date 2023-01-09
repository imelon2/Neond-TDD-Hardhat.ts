// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./VRF.sol";
import "../interface/IHouse.sol";

contract NeonRoulette is VRF {
    using SafeERC20 for IERC20;

    struct Bet {
        address player;
        address token;
        uint256 outcome;
        uint256 bonusOutcome;
        bool isSettled;
        bool isRefunded;
        uint256 winAmount;
        uint256 placeBlockNumber;
        uint256[] betAmount;
        uint256 totalBetAmount;
    }

    struct Token {
        uint64 pendingCount;
        uint16 houseEdge;
        bool isPuased;
    }

    mapping(uint => Bet) public bets;
    mapping(address => Token) public tokens;

    IHouse private House;

    bool public gameIsLive;
    uint16 public refundDelay;

    uint constant MULTIPLIER = 27;

    constructor(
        address _vrfCoordinator,
        address _House
        ) VRF(_vrfCoordinator, 8 /* number of RandomWords request vrf */){
        House = IHouse(_House);
        refundDelay = 10800; // 1 Block = 2 sec | 10800 BLocks = 21600 sec = 6 hours (Based by Polygon)
    }

    // Error
    error GameIsNotLive();
    error InvalidAddress();
    error BetIsPending();
    error TokenIsPaused();
    error BetLengthNotInRange();
    error HouseUnapprovedToken();
    error ZeroBet();
    error SettledBet();
    error NotPassedRefundPeriod();


    // Events
    event BetPlaced(uint indexed betId, address indexed player,address token, uint256[] betAmount);
    event BetSettled(uint indexed betId, address indexed player, address token, uint256[] betAmount, uint outcome,uint bounsOutcome, uint winAmount);
    event BetRefunded(uint indexed betId, address indexed player,address token, uint amount);
    event SetHouseEdge(address indexed token, uint16 houseEdge);
    event SetRefundPeriod(uint16 refundDelay);

    // Modifier
    modifier IsGameLive() {
        if(!gameIsLive) {
            revert GameIsNotLive();
        }
        _;
    }

    // Management
    function toggleGameLive() external onlyOwner {
        gameIsLive = !gameIsLive;
    }

    function toggleTokenPuase(address token) external onlyOwner {
        tokens[token].isPuased = !tokens[token].isPuased;
    }

    // Setter(init) 
    function initHouse(IHouse _House) external onlyOwner {
        if (address(_House) == address(0)) {
            revert InvalidAddress();
        }
        House = _House;
    }

    function initRefundDelay(uint16 _refundDelay) external onlyOwner {
        refundDelay = _refundDelay;
        emit SetRefundPeriod(_refundDelay);
    }

    function initToken(address token,uint16 houseEdge) external onlyOwner {
        if(tokens[token].pendingCount != 0) {
            revert BetIsPending();
        }
        tokens[token].houseEdge = houseEdge;
        if(!tokens[token].isPuased) {
            tokens[token].isPuased = true;    
        }
        emit SetHouseEdge(token,houseEdge);
    }

    // Getter
    function getMinBetAmount(address token) public view returns(uint) {
        return House.getMinBetAmount(token);
    }

    function getMaxBetAmount(address token) public view returns(uint) {
        return House.getMaxBetAmount(token,MULTIPLIER);
    }

    function _getWinAmount(address _token, uint256 _amount) private view returns(uint256) {
            return _amount * (10000 - tokens[_token].houseEdge) / 10000;
    }

    function placeBet(address token, uint256[] calldata betAmount) external IsGameLive {
        if(tokens[token].isPuased) {
            revert TokenIsPaused();
        }
        uint8 betLength = uint8(betAmount.length);
        if(betLength != 37) {
            revert BetLengthNotInRange();
        }

        // House Status
        if(!House.isAllowedToken(token)) {
            revert HouseUnapprovedToken();
        }
        uint256 totalBetAmount;
        uint256 minBetAmount = getMinBetAmount(token);
        uint256 maxBetAmount = getMaxBetAmount(token);
        for(uint i = 0; i < betLength;i++) {
            uint _betAmount = betAmount[i];
            if(_betAmount <= maxBetAmount && _betAmount >= minBetAmount) {
                totalBetAmount += betAmount[i];
            }
        }
        if(totalBetAmount == 0) {
            revert ZeroBet();
        }

        address player = msg.sender;

        // Transfer player's bet amount and Pending amount in a House
        House.palceBet(token,player,totalBetAmount);

        uint256 betId = sendRequestRandomness(); // request randomness to Chainlink VRF

        bets[betId] = Bet({
            player : player,
            token : token,
            betAmount : betAmount, // uint256[]
            totalBetAmount : totalBetAmount,
            winAmount : 0,
            outcome : 0,
            bonusOutcome: 0,
            placeBlockNumber : block.number,
            isSettled : false,
            isRefunded : false
        });

        tokens[token].pendingCount ++;

        emit BetPlaced(betId, player, token, betAmount);
    }

    /*
    * @dev : Chain Link VRF call this with result
    * randomWords[0] = game result
    * randomWords[1] = number of bonus games (0~5)
    * randomWords[2] = Bonus Game Win Multiplier (x1 ~ x10000)
    * randomWords[3 ~ 7] = Draw a bonus number, number of randomWords[1] (0~37)
    * L if randomWords[1] = 3, bonus number = randomWords[3],randomWords[4],randomWords[5]
    */
    function fulfillRandomWords(uint256 id, uint256[] memory randomWords)
        internal
        override {
            Bet storage bet = bets[id];
            uint256 totalBetAmount = bet.totalBetAmount;


            // Check that bet exists
            // Check that bet is not settled yet
            if (totalBetAmount == 0 || bet.isSettled == true) {
                return;
            }

            uint256 amount;
            address token = bet.token;
            address player = bet.player;

            uint256 outcome = randomWords[0] % 37;
            uint256[] memory _betAmount = bet.betAmount;
            uint256 betAmount = _betAmount[outcome];

            uint8 bounsIndex;
            uint256 bonusOutcome;

            // Win Game
            if(betAmount != 0) {
                bounsIndex = uint8(randomWords[1] % 6);// 0~5 EA
                uint bounsMultipler = 30; // test value
                if(bounsIndex != 0) {
                    uint bonusNum;
                    for(uint i = 0; i < bounsIndex; i++) {
                        bonusNum = 2 ** (randomWords[i+2] % 37);
                        bonusOutcome & bonusNum == 0 ? bonusOutcome += bonusNum : 0 ;
                    }
                    // check bonus result
                    2 ** outcome & bonusOutcome != 0 ? 
                    // Win Bonus Game
                    amount = betAmount * bounsMultipler :
                    // Lose Bonus Game
                    amount = betAmount * MULTIPLIER; // x27

                // if Bonus number is 0
                } else {
                    amount = betAmount * MULTIPLIER; // x27
                }


            // Lose Game
            } else {
                amount = 0;
            }

            // uint256 winAmount = settleBet(token,player,amount);
            uint256 winAmount = _getWinAmount(token,amount);
            House.settleBet(token, player, totalBetAmount,winAmount, amount != 0);

            bet.winAmount = winAmount;
            bet.outcome = outcome;
            bet.bonusOutcome = bonusOutcome;
            bet.isSettled = true;

            tokens[token].pendingCount --;

            emit BetSettled(id,player,token,_betAmount,outcome,bonusOutcome,winAmount);
    }

    function refundBet(uint betId) external {
        Bet storage bet = bets[betId];

        uint256 totalBetAmount = bet.totalBetAmount;
        address token = bet.token;

        if(totalBetAmount <= 0) {
            revert ZeroBet();
        }
        if(bet.isSettled) {
            revert SettledBet();
        }
        if(!isPassedRefundPeriod(betId)) {
            revert NotPassedRefundPeriod();
        }

        address player = bet.player;

        House.refundBet(token, player, totalBetAmount);

        // Update bet records
        bet.isSettled = true;
        bet.isRefunded = true;


        tokens[token].pendingCount --;

        emit BetRefunded(betId,player,token,totalBetAmount);
    }

    // Checked
    function isPassedRefundPeriod(uint betId) public view returns(bool) {
        return block.number > bets[betId].placeBlockNumber + refundDelay;
    }
}
