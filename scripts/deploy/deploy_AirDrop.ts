import { ethers } from "hardhat";
import { BigNumber} from 'ethers';

const neon = "0xa08F997a1D3bbe10d05b50b7006A6525cBB57fFa"
const neond = "0x276f396df47C4eAD51BE77f8933442f35744a25f"

const decimals = 18;
const _REWARD_TOTAL_AMOUNT = "";
const _REWARD_AMOUNT = "";

const REWARD_AMOUNT = BigNumber.from(_REWARD_AMOUNT).mul(BigNumber.from(10).pow(decimals)); // ex 100 NEON
const REWARD_TOTAL_AMOUNT = BigNumber.from(_REWARD_TOTAL_AMOUNT).mul(BigNumber.from(10).pow(decimals)); // ex 10000 NEON

async function main() {
    const _Airdrop = await ethers.getContractFactory("Airdrop");

    // (1) Deploy Airdrop Contract
    const Airdrop = await _Airdrop.deploy(neon,neond,REWARD_AMOUNT);
    console.log("Deploying NEOND Airdrop...");
    await Airdrop.deployed();
    console.log("NEOND Airdrop deployed to:", Airdrop.address); 

    // (2) transfer NEON for Reward
    const NEON = await ethers.getContractAt("NEON",neon)
    const _transfer = await NEON.transfer(Airdrop.address,REWARD_TOTAL_AMOUNT)
    const transfer_result = await _transfer.wait();
    console.log(`transfer transection result : ${transfer_result}`);
    
    // (3) check Airdrop Contract balance(= total reward amount)
    const Airdrop_balance = await NEON.balanceOf(Airdrop.address)
    console.log(`Current Airdrip Reward Total Banalce : ${Airdrop_balance} NEON` );

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });