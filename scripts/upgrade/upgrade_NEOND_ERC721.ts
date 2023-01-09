import { ethers, upgrades } from "hardhat";

const PROXY = "0xdE4BAa65C4f52BDEC2802759f9aD25dC825FD21a"

// async function main() {
//     const _NEONDERC721 = await ethers.getContractFactory("NEOND_V2");
//     console.log("Upgrading Box...");
//     await upgrades.upgradeProxy(PROXY, _NEONDERC721);
//     console.log("_MyERC721V2 upgraded");
// }

// main().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
//   });