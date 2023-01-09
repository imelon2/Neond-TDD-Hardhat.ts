----------------------------------------------------------------------------------------
(1) Deploy Proxy and Contract
env $(cat .env) npx hardhat run --network mumbai scripts/deploy_MyERC721.js
env $(cat .env) npx hardhat verify --network mumbai "MyERC721 Contract Address"
go to polygonscan verify Proxy Contract
----------------------------------------------------------------------------------------
(2) Upgrade Proxy
env $(cat .env) npx hardhat run --network mumbai scripts/upgrade_MyERC721.js
env $(cat .env) npx hardhat verify --network mumbai "MyERC721V2 Contract Address"
go to polygonscan verify Proxy Contract


(3) Clean hardhat
npx hardhat clean