import { ethers } from "ethers"
import GAME_ABI from "./abi/NeonRoulette.json"

const CONTRACT_ADDRESS = 'GAME CONTRACT ADDRESS'
const WEBSOCKET_MUMBAI_RPC_URL = "MUMBAI_RPC_URL" // wss://ws-mumbai.matic.today/

module.exports = async () => {


        const httpProvider = new ethers.WebSocketProvider(WEBSOCKET_MUMBAI_RPC_URL)

        // BroadCasting on Game Contract 
        const contract = new ethers.Contract(CONTRACT_ADDRESS, GAME_ABI, httpProvider)
        contract.on('BetSettled', (betId, player, betAmount, betChoice, outcome, winAmount, event) => {
            // DB에 저장되는 로직 ...
        })


        
}

