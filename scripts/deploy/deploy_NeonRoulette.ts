import { ethers } from "hardhat";

const vrfCoordinator = "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed"; // Mumbai
const House = "0x9F1c3F43AD2c1363Dc6af4E17419CE5deEf2491f"

async function main() {
    const _NeonRoulette = await ethers.getContractFactory("NeonRoulette");
    const NeonRoulette = await _NeonRoulette.deploy(vrfCoordinator,House);
    console.log("Deploying NeonRoulette...");
    await NeonRoulette.deployed();
    console.log("NeonRoulette deployed to:", NeonRoulette.address); // 0x2C935aF4AFCE1c9433248B6efaB936Ab77EF6784
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });