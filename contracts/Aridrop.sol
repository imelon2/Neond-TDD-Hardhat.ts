// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Airdrop is Ownable,Pausable,ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public rewardAmount;

    uint48 private A;
    uint48 private Z;

    IERC20 NEON;
    IERC721 NEOND_NFT;

    mapping (uint256 => bool) public isNftReceivedReward;

    error Rewarded();
    error NotNftHolder();
    error NotEnoughReward();
    error NotAirDropNft();

    event Claim(address indexed holder,uint256 tokenId);

    constructor(address _NEON,address _NEOND_NFT,uint256 _rewardAmount) {
        NEON = IERC20(_NEON);
        NEOND_NFT = IERC721(_NEOND_NFT);
        rewardAmount = _rewardAmount;
    }

    function setRewardAmount(uint256 _amount) external onlyOwner {
        rewardAmount = _amount;
    }

    function setIdOffset(uint48 _A,uint48 _Z) external onlyOwner {
        A = _A; 
        Z = _Z;
    }

    function totalRewardAmount() public view returns(uint256) {
        return NEON.balanceOf(address(this));
    }

    function claim(uint256 tokenId) external whenNotPaused nonReentrant {
        if(totalRewardAmount() < rewardAmount) {
            revert NotEnoughReward();
        }
        if(isNftReceivedReward[tokenId] == true) {
            revert Rewarded();
        }

        if(idOffset(tokenId)) {
            revert NotAirDropNft();
        }

        address holder = msg.sender;
        if(holder != nftBalanceOf(tokenId)) {
            revert NotNftHolder();
        }


        isNftReceivedReward[tokenId] = true;
        NEON.safeTransfer(holder,rewardAmount);

        emit Claim(holder, tokenId);
    }

    function nftBalanceOf(uint256 tokenId) private view returns(address) {
        return NEOND_NFT.ownerOf(tokenId);
    }

    // id A ~ Z is Airdrop NFT
    function idOffset(uint256 tokenId) private view returns(bool) {
        return A >= tokenId  || tokenId > Z;
    }

    function emergencyClaim() external onlyOwner {
        NEON.safeTransfer(msg.sender,totalRewardAmount());
    }

    function emergencyTransfer(address to,uint256 amount) external onlyOwner {
        NEON.safeTransfer(to,amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

}