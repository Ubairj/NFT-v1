require('dotenv/config');

const { task } = require('hardhat/config');
const { node_url, accounts } = require('./src/lib/hardhat');

require('dotenv/config');

require('hardhat-deploy');
require('hardhat-deploy-ethers');
require('hardhat-spdx-license-identifier');
require('hardhat-contract-sizer');
require('hardhat-abi-exporter');
require('hardhat-gas-reporter');
require('hardhat-watcher');

require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-solhint');
require('@nomiclabs/hardhat-ganache');
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-etherscan');


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config = {
  solidity: {
    compilers: [
      {
        version: '0.8.6',
        settings: {
          optimizer: {
            enabled: true,
            runs: 9999,
          },
        },
      },
    ],
  },
  namedAccounts: {
    deployer: {
      default: 0,
      kovan: 0,
    },
  },
  networks: {
    hardhat: {
      chainId: 1337,
      accounts: accounts(),
    },
    localhost: {
      url: 'http://localhost:8545',
      accounts: accounts(),
      gasPrice: 'auto',
      gas: 'auto',
    },
    mainnet: {
      url: node_url('mainnet'),
      accounts: accounts('mainnet'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    rinkeby: {
      url: node_url('rinkeby'),
      accounts: accounts('rinkeby'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    ropsten: {
      url: node_url('ropsten'),
      accounts: accounts('ropsten'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    kovan: {
      url: node_url('kovan'),
      accounts: accounts('kovan'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    staging: {
      url: node_url('kovan'),
      accounts: accounts('kovan'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    ftmtest: {
      url: node_url('ftmtest'),
      accounts: accounts('ftmtest'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    opera: {
      url: node_url('opera'),
      accounts: accounts('opera'),
    },
    sokol: {
      url: node_url('sokol'),
      accounts: accounts('sokol'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    fuji: {
      url: node_url('fuji'),
      accounts: accounts('fuji'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    avax: {
      url: node_url('avax'),
      accounts: accounts('avax'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    binance: {
      url: node_url('binance'),
      accounts: accounts('binance'),
      gasPrice: 'auto',
      gas: 'auto',
    },
    bsctest: {
      url: node_url('bsctest'),
      accounts: accounts('bsctest'),
      gasPrice: 'auto',
      gas: 'auto',
    },
  },
  etherscan: {
    apiKey: '4QX1GGDD4FPPHK4DNTR3US6XJDFBUXG7WQ',
  },
  paths: {
    sources: 'contracts',
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 150,
    enabled: true,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    maxMethodDiff: 10,
  },
  mocha: {
    timeout: 0,
  },
  abiExporter: {
    path: './abis',
    clear: false,
    flat: false,
    pretty: true,
    runOnCompile: true
  }
};

module.exports = config;
