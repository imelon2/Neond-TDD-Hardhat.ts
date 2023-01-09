// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

abstract contract VRF is Ownable,VRFConsumerBaseV2 {

    struct ChainlinkConfig {
        uint64 subId;
        uint32 callbackGasLimit;
        uint16 requestConfirmations;
        bytes32 keyHash;
    }

    VRFCoordinatorV2Interface COORDINATOR;
    ChainlinkConfig public chainlinkConfig;

    uint32 internal immutable numRandomWords;

    // address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed; // Mumbai
    constructor(address vrfCoordinator,uint32 _numRandomWords) VRFConsumerBaseV2(vrfCoordinator) {
        numRandomWords = _numRandomWords;
    }


    /*
    * @param subId : ChainLink VRF subscription Id
    * @param callbackGasLimit : 300000
    * @param requestConfirmations : 3 (min val)
    * @param keyHash : 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f(MUMBAI , 500 gwei Key Hash)
    */
    function setChainlinkConfig(
        uint64 subId,
        uint32 callbackGasLimit,
        uint16 requestConfirmations,
        bytes32 keyHash
    ) external onlyOwner {
        chainlinkConfig.subId = subId;
        chainlinkConfig.callbackGasLimit = callbackGasLimit;
        chainlinkConfig.requestConfirmations = requestConfirmations;
        chainlinkConfig.keyHash = keyHash;
    }
    
    function sendRequestRandomness() internal returns(uint256){
        uint256 betId = COORDINATOR.requestRandomWords(
            chainlinkConfig.keyHash,
            chainlinkConfig.subId,
            chainlinkConfig.requestConfirmations,
            chainlinkConfig.callbackGasLimit,
            numRandomWords
        );

        return betId;
    }
}