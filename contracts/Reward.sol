// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Reward is Ownable {
    IERC20 public immutable neon;

    constructor(IERC20 _neon) {
        neon = _neon;
    }

    event UpdateMerkleRoot(uint256 blockNumber,bytes32 merkleRoot);
    event Claim(uint256 blockNumber,address claimer,uint256 amount,bytes32 merkleRoot);


    // 보상 받는 플레이어 리스트의 머클루트
    bytes32 public _merkleRoot;
    mapping(bytes32 => mapping(address => bool)) public isClaimed;

    function updateMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
        _merkleRoot = _newMerkleRoot;

        emit UpdateMerkleRoot(block.number,_newMerkleRoot);
    }

    function canClaim(address claimer,uint256 amount,bytes32[] calldata merkleProof) public view returns(bool) {
        bytes32 node = keccak256(abi.encodePacked(claimer, amount));
        return MerkleProof.verifyCalldata(
            merkleProof,
            _merkleRoot,
            node
        );
    }

    function claim(
        uint256 amount,
        bytes32[] calldata merkleProof) public {
            // 이미 보상을 클레임 했는지 확인
            require(!isClaimed[_merkleRoot][msg.sender], "Already claimed.");

            // MerkleRoot에 msg.sender와 클레임 금액이 포함되었는지 확인
            require(canClaim(msg.sender,amount,merkleProof),"No rewards to claim.");

            // Contract에 충분한 보상이 있는지 확인
            require(getBalance() >= amount,"Not Enough Rewards");
            
            neon.transfer(msg.sender, amount);
            isClaimed[_merkleRoot][msg.sender] = true;

            emit Claim(block.number,msg.sender,amount,_merkleRoot);
        }
    
    function getBalance() public view returns(uint) {
        return neon.balanceOf(address(this));
    }
}