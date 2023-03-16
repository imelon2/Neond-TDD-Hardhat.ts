import { ethers } from "hardhat";

async function main() {
    const _House = await ethers.getContractFactory("House");
    const House = await _House.deploy();
    console.log("Deploying House...");
    await House.deployed();
    console.log("House deployed to:", House.address); // 0x9F1c3F43AD2c1363Dc6af4E17419CE5deEf2491f
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });