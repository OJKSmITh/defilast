import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      forking: {
        url: "https://klaytn.blockpi.network/v1/rpc/public",
      },
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        accountsBalance: "10000000000000000000000000", // 10,000,000 KLAY
      },
      blockGasLimit: 30000000,
    },
    baobab: {
      url:"https://api.baobab.klaytn.net:8651",
      chainId: 1001,
      accounts : require("./accounts.json").privateKey,
      gas: 20000000,
      gasPrice: 250000000000
    },
    arbitrum: {
      url:"https://arbitrum-goerli.publicnode.com",
      chainId:421613,
      accounts : require("./accounts.json").privateKey,
      gas:20000000,
      gasPrice: 25000000000
    },
    ganache: {
      url: "http://localhost:8545", // Ganache URL
      chainId: 1337, // Chain ID for Ganache
      gas: 8000000, // Gas limit for Ganache
      gasPrice: 20000000000 // Gas price for Ganache
    }
  }
};

export default config;
