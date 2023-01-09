import { ethers } from "hardhat";

async function main() {
    const _House = await ethers.getContractFactory("House");
    const House = await _House.deploy();
    console.log("Deploying House...");
    await House.deployed();
    console.log("House deployed to:", House.address); // 0x6B0f498a77c05dC5ba0a2d073498b8fB80951ce7
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });