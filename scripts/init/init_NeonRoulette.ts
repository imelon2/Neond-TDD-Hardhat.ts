import { ethers } from "hardhat";

const House_Address = process.env.HOUSE_ADDRESS
const NeonRoulette_Address = process.env.NEON_ROULETTE_ADDRESS
const tNEON_Address = process.env.TNEON_ADDRESS;
const tUSDT_Address = process.env.TUSET_ADDRESS;


async function main() {
    // const NeonRoulette = await ethers.getContractAt("NeonRoulette",NeonRoulette_Address);

    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });