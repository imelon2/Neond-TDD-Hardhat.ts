import { ethers } from "hardhat";
import { BigNumber} from 'ethers';

const House_Address = "0x6B0f498a77c05dC5ba0a2d073498b8fB80951ce7";
const tNEON_Address = "0xD56707ae95dfa75fD9ebEAd130d795eC9fe0A2ab";
const tUSDT_Address = "0x6c95299DB09cc80cdd6Eef37D622ad52477aA128";

const MIN_tNEON = BigNumber.from(1).mul(BigNumber.from(10).pow(18)); // ex 1 NEON
const MIN_tUSDT = BigNumber.from(1).mul(BigNumber.from(10).pow(6)); // ex 1 NEON

const tNEON_Amount = BigNumber.from(20000).mul(BigNumber.from(10).pow(18));
const tUSDT_Amount = BigNumber.from(20000).mul(BigNumber.from(10).pow(6));

const game = {
    neonRoulette : "0x2C935aF4AFCE1c9433248B6efaB936Ab77EF6784"
}

async function main() {
    const House = await ethers.getContractAt("House",House_Address);

    await House.initToken(tNEON_Address,300,MIN_tNEON)
    await House.initToken(tUSDT_Address,300,MIN_tUSDT)
    await House.addGame(game["neonRoulette"])

    const tNEON = await ethers.getContractAt("tNEON",tNEON_Address)
    await tNEON.transfer(House_Address,tNEON_Amount)

    const tUSDT = await ethers.getContractAt("tUSDT",tUSDT_Address)
    const lastTx = await tUSDT.transfer(House_Address,tUSDT_Amount)
    await lastTx.wait();

    const tNEON_balance = await House.getBalance(tNEON_Address)
    const tUSDT_balance = await House.getBalance(tUSDT_Address)
    
    console.log(`House tNEON current Balance : ${tNEON_balance}`);
    console.log(`House tUSDT current Balance : ${tUSDT_balance}`);


}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });