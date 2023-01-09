import { ethers, upgrades } from "hardhat";

async function main() {
    const _NEON = await ethers.getContractFactory("tNEON");
    console.log("Deploying tNEON ERC20...");
    const NEON = await upgrades.deployProxy(_NEON,{kind:'uups'})
    await NEON.deployed();
    console.log("tNEON ERC20 deployed to:", NEON.address); // 0xD56707ae95dfa75fD9ebEAd130d795eC9fe0A2ab
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });