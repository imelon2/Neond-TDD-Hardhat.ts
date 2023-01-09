import { ethers, upgrades } from "hardhat";
const address = "0xbc0cC420F9fD0E3B363bCc722e883aCae00723b1"
async function main() {

    const _Test = await ethers.getContractFactory("Test")
    const Test = await _Test.deploy();

    console.log(Test.address);
    
    // const TEST = await ethers.getContractAt("Test",address)

    // const tx = await TEST.testFunc(5);
    // const result_tx = await tx.wait()

    // console.log(tx);
    
    // console.log(result_tx);
    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });