import { ethers } from "hardhat";

const vrfCoordinator = "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed"; // Mumbai
const House_Address = process.env.HOUSE_ADDRESS!

async function main() {
    const _NeonRoulette = await ethers.getContractFactory("NeonRoulette");
    const NeonRoulette = await _NeonRoulette.deploy(vrfCoordinator,House_Address);
    console.log("Deploying NeonRoulette...");
    await NeonRoulette.deployed();
    console.log("NeonRoulette deployed to:", NeonRoulette.address); // 0x2772C85e36cD97276eD594Aa1484D5A86Cc7e9A4
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });