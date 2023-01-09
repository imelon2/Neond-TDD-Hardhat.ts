import { ethers, upgrades } from "hardhat";

const PROXY = ""

// async function main() {
//     const _NEON = await ethers.getContractFactory("NEON_V2");
//     console.log("Upgrading NEON ERC20 ...");
//     await upgrades.upgradeProxy(PROXY, _NEON);
//     console.log("NEON ERC20 upgraded");
// }

// main().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
//   });