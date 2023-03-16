const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");
const {ethers,Contract} = require("ethers");
const { db } = require("../models");
const REWARD_ABI =require("./abi/Reward.json");
const REWARD_CONTRACT_ADDRESS = "CONTRACT_ADDRESS"
const privateKey = "privateKey"


const provider = new ethers.providers.JsonRpcProvider("POLYGON_RPC_URL");
const walletWithProvider = new ethers.Wallet(privateKey, provider);
const reward_contract = new ethers.Contract(REWARD_CONTRACT_ADDRESS, GAME_ABI, walletWithProvider)


module.exports = {
  reward: async (req, res) => {
    const { from, to } = req.body;

    // 블록넘버 from 부터 to(default:43200) 까지의 게임 기록 조회
    const gameHistorys = await db["game_history"].find({
      where: {
        blockNum: {
          [Op.between]: [from, to],
        },
      },
    });
    
    let playersRewardAmount = new Object();
    for( let i = 0; i < gameHistorys.length; i++) {
        /**
         * winAmount == 0 : 게임에서 진 경우
         * winAmount != 0 : 게임에서 이긴 경우
         * 
         * 게임에서 진 경우, 베팅 금액을 Reward에서 더합니다.
         * 게임에서 이긴 경우, 승리 보상 금액을 Reward에서 뺌니다.
         */

        // 진 경우
        if(gameHistorys[i].winAmount === 0) {
            playersRewardAmount[gameHistorys[i].player].amount += betAmount;
        }
        // 이긴 경우
        else if (gameHistorys[i].winAmount !== 0) {
            playersRewardAmount[gameHistorys[i].player].amount -= winAmount;
        }
    }

    // 집계된 보상을 받을 플레이어와 보상 금액
    let merkleTreeData;
    Object.keys(playersRewardAmount).map(key => {
        if(playersRewardAmount[key].amount > 0) {
            merkleTreeData.push({
                palyer:key,
                amount:playersRewardAmount[key].amount * 1/4 // Cash Back 25%
            })
        }
    })

    await db['reward_data'].insertMany(merkleTreeData);



    const merkleTree = new MerkleTree(
        merkleTreeData,
        keccak256,
        { hashLeaves: true, sortPairs: true }
      );

    const root = merkleTree.getHexRoot()

    await reward_contract.updateMerkleRoot(root)


  },
  
  clain:async(req,res) => {
    // 보상을 청구하는 유저의 지갑주소
    const {claimer} = req.body; 

    // 집계된 보상을 받을 플레이어와 보상 금액 명단
    const rewardData = await db["reward_data"].find(); 

    // 명단에서 보상을 청구하는 유저의 데이터 추출
    const claimerData = rewardData.find(item => item.palyer === claimer)

    const merkleTree = new MerkleTree(
        rewardData,
        keccak256,
        { hashLeaves: true, sortPairs: true }
      );

    // Reward Contract에서 자격 검증시 필요한 Merkle Proof
    const proof = merkleTree.getHexProof(keccak256({palyer:claimer,amount:claimerData.amount}))

    return res.status(200).send({"proof":proof,"amount":claimerData.amount});
  }


};

