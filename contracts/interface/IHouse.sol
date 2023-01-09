// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IHouse {
    function getMinBetAmount(address token) external view returns(uint256);
    function getMaxBetAmount(address token,uint256 multiplier) external view returns(uint256);
    function isAllowedToken(address token) external view returns(bool);
    function palceBet(address token,address player,uint betAmount) external;
    function settleBet(address token,address player, uint totalAmount,uint amount, bool win) external;
    function refundBet(address token,address player, uint amount) external;
}