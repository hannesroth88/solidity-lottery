import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";
import * as dotenv from "dotenv";
dotenv.config();

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL as string;
const PRIVATE_KEY = process.env.PRIVATE_KEY as string;
const COINMARKETCAP_APIKEY = process.env.COINMARKETCAP_APIKEY as string;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY as string;

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
    },
  },
  gasReporter: {
    currency: "EUR",
    gasPrice: 21,
    enabled: process.env.REPORT_GAS ? true : false,
    coinmarketcap: COINMARKETCAP_APIKEY
  },
  etherscan: {
      // yarn hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
      apiKey: {
          goerli: ETHERSCAN_API_KEY,
      },
  },
};

export default config;
