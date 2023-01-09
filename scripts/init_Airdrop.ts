import { ethers } from "hardhat";
import { BigNumber} from 'ethers';

const airdrop = "0x8E891A959701Aef5E2Ae5CCe15c057F177CB408d"
const neon = "0xa08F997a1D3bbe10d05b50b7006A6525cBB57fFa"

const A = ""
const Z = ""
async function main() {
    const Airdrop = await ethers.getContractAt("Airdrop",airdrop)
    const _setIdOffset = await Airdrop.setIdOffset(A,Z);
    const setIdOffset_result = await _setIdOffset.wait();

    console.log(`Set Id Offset Result : ${setIdOffset_result.status}`);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });