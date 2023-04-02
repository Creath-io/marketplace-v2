const {ethers, upgrades} = require("hardhat");

async function main() {
  const [admin, test] = await ethers.getSigners();
  //const Creath = await ethers.getContractFactory("Creath");
  //const Factory = await ethers.getContractFactory("CreathArtFactory");
  //const Marketplace = await ethers.getContractFactory("CreathMarketplace");
  const Treasury = await ethers.getContractFactory("CreathTreasury");
  //const Mock = await ethers.getContractFactory("USDT");
  //const creath = await Creath.deploy();
  const treasury = await Treasury.deploy(admin.getAddress(), "0x2C7500456BE0C057138F17CFF6Afa8195fE414bA");
  //const mock = await Mock.deploy();
  /*const marketplace = await upgrades.deployProxy(Marketplace,[
    treasury.address,
    mock.address,
    ethers.BigNumber.from("20")
  ],{kind:"uups"});
  const factory = await Factory.deploy(marketplace.address);
 
  console.log("Creath", creath.address);0x9bBD6C78a59db71f5a6Bf883f9d108474e980794
  console.log("Art Factory", factory.address);
  console.log("Marketplace", marketplace.address);*/
  console.log("Treasury", treasury.address);
  //console.log("Mock", mock.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
