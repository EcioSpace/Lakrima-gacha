const { mnemonic, etherscanApiKey, bscscanApiKey } = require('./secrets.json');

require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");

// // This is a sample Hardhat task. To learn how to create your own go to
// // Ethereum development environment for professionals
// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
// const accounts = await hre.ethers.getSigners();
//
// for (const account of accounts) {
// console.log(account.address);
// }
// });

// You need to export an object to set up your config
// Go to Ethereum development environment for professionals to learn more

/* @type import('hardhat/config').HardhatUserConfig
*/
module.exports = {
  defaultNetwork: "testnet",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    hardhat: {
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: { mnemonic: mnemonic }
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts: { mnemonic: mnemonic }
    },
    hardhat: {
      chainId: 1337
    }
  },
  etherscan: {
    apiKey: bscscanApiKey
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  }
};