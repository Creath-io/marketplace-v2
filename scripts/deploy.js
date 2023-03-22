const {ethers, upgrades} = require("hardhat");

async function main() {
  const [admin, test] = await ethers.getSigners();
  /*const Bot = await ethers.getContractFactory("mySwapContract");
  const bot = await Bot.deploy(
    "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
    "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
  );*/

  //console.log(bot.address);
  const Creath = await ethers.getContractFactory("Creath");
  const AddressRegistry = await ethers.getContractFactory("CreathAddressRegistry");
  const Factory = await ethers.getContractFactory("CreathArtFactory");
  const Marketplace = await ethers.getContractFactory("CreathMarketplace");
  const TokenRegistry = await ethers.getContractFactory("CreathTokenRegistry");
  const Treasury = await ethers.getContractFactory("CreathTreasury");
  //const creath = await Creath.deploy();
  //const tokenRegistry = await TokenRegistry.deploy();
  //const treasury = await Treasury.deploy(test.getAddress());
  /*const marketplace = await upgrades.deployProxy(Marketplace,[
    treasury.address,
    ethers.BigNumber.from("20")
  ],{kind:"uups"});*/
  const factory = await Factory.deploy("0xe2f965D2D4F89Bcaa2F8Edf9f4Eaf2Ce0A0AF328");
  /*const addressRegistry = await AddressRegistry.deploy(
    creath.address,
    marketplace.address,
    factory.address,
    tokenRegistry.address
  );*/

  //console.log("Creath", creath.address);
  console.log("Art Factory", factory.address);
  //console.log("Marketplace", marketplace.address);*/
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
