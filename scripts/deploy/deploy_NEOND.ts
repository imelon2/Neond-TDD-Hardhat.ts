import { ethers, upgrades } from "hardhat";

async function main() {
    const _NEONDERC721 = await ethers.getContractFactory("NEOND");
    console.log("Deploying NEOND ERC721...");
    const NEONDERC721 = await upgrades.deployProxy(_NEONDERC721,{kind:'uups'})
    await NEONDERC721.deployed();
    console.log("NEOND ERC721 deployed to:", NEONDERC721.address); // 0x276f396df47C4eAD51BE77f8933442f35744a25f
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });