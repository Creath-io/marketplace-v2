require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-gas-reporter");
require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const mnemonic = process.env.MNEMONIC;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
  networks: {
    goerli: {
      url: "https://rpc.sepolia.org",
      chainId: 11155111,
      accounts: {
        mnemonic,
        path: "m/44'/60'/0'/0",
        inittialIndex: 0,
        count: 10,
      },
    },
    polygon: {
      url: "https://polygon-rpc.com",
      chainId: 137,
      accounts: {
        mnemonic,
        path: "m/44'/60'/0'/0",
        inittialIndex: 0,
        count: 10,
      },
    },
    localhost: {
      url: `http://localhost:8545`,
      accounts: {
        mnemonic,
        path: "m/44'/60'/0'/0",
        inittialIndex: 0,
        count: 10,
      },
      timeout: 150000,
    },
    mainnet: {
      url: "https://eth.llamarpc.com",
      chainId: 1,
      accounts: {
        mnemonic,
        path: "m/44'/60'/0'/0",
        inittialIndex: 1,
        count: 10,
      },
    },
    hardhat: {
      accounts: {
        mnemonic,
        path: "m/44'/60'/0'/0",
        inittialIndex: 0,
        count: 10,
      },
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
