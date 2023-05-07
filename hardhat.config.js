require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
      blockConfirmations: 1,
    },
    mumbai: {
      url: process.env.POLYGON_MUMBAI_RPC_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      saveDeployments: true,
      chainId: 80001,
    },
  },
};
