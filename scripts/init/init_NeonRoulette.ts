import { ethers } from "hardhat";

const House_Address = process.env.HOUSE_ADDRESS
const NeonRoulette_Address = process.env.NEON_ROULETTE_ADDRESS!
const tNEON_Address = process.env.TNEON_ADDRESS!;
const tUSDT_Address = process.env.TUSET_ADDRESS!;

const ChainLink_SubId = process.env.SUB_ID!;

async function main() {
    const NeonRoulette = await ethers.getContractAt("NeonRoulette",NeonRoulette_Address);
    await NeonRoulette.initToken(tNEON_Address,300)
    await NeonRoulette.initToken(tUSDT_Address,300)
    const lastTx =await NeonRoulette.setChainlinkConfig(ChainLink_SubId,300000,3,"0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f");

    await lastTx.wait();

    console.log("Finish Init NeonRoulette Contract");
    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });