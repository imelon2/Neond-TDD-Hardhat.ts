import { ethers } from "hardhat";

async function main() {
    const _tUSDT = await ethers.getContractFactory("tUSDT");
    const tUSDT = await _tUSDT.deploy();
    console.log("Deploying tUSDT ERC20...");
    await tUSDT.deployed();
    console.log("tUSDT ERC20 deployed to:", tUSDT.address); // 0x6c95299DB09cc80cdd6Eef37D622ad52477aA128
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });