require('dotenv').config();
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require('hardhat-abi-exporter');
require("@nomiclabs/hardhat-web3");
require("hardhat-gas-reporter");
require('solidity-coverage');

const {
    // cannot be shared
    PRIVATE_KEY, // mainnet/testnet deployer keykey
    // ---
    // gas report
    // REPORT_GAS = true,
    REPORT_CURRENCY,
    REPORT_GAS_FILE_OUTPUT,
    // coinmarketcap.com api key
    COINMARKETCAP_API_KEY,
    // block explorers
    ETHERSCAN_API_KEY,
    OPTIMISMSCAN_API_KEY,
    POLYGONSCAN_API_KEY,
    BSCSCAN_API_KEY,
    // providers urls
    MAINNET_API_URL,
    SEPOLIA_API_URL,
    OPTIMISM_API_URL,
    GOERLI_API_URL,
    POLYGON_API_URL,
    MUMBAI_API_URL,
    BSC_API_URL,
    BSCTEST_API_URL,
} = process.env;

const mainnetConfig = {};
const sepoliaConfig = {};
const optimismConfig = {};
const polygonConfig = {};

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address, await account.getBalance());
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

function buildConfig() {
    const networks = {};

    // ethereum
    if (MAINNET_API_URL.length) {
        networks.mainnet = {
            url: MAINNET_API_URL,
            accounts: [PRIVATE_KEY]
        };
    }
    if (SEPOLIA_API_URL.length) {
        networks.sepolia = {
            url: SEPOLIA_API_URL,
            accounts: [PRIVATE_KEY]
        };
    }
    if (GOERLI_API_URL.length) {
        networks.goerli = {
            url: GOERLI_API_URL,
            accounts: [PRIVATE_KEY]
        };
    }

    // optimism
    if (OPTIMISM_API_URL.length) {
        networks.optimism = {
            url: OPTIMISM_API_URL,
            accounts: [PRIVATE_KEY]
        }
    }

    // binance smart chain
    if (BSC_API_URL.length) {
        networks.bsc = {
            url: BSC_API_URL,
            accounts: [PRIVATE_KEY]
        };
    }
    if (BSCTEST_API_URL.length) {
        networks.bscTestnet = {
            url: BSCTEST_API_URL,
            accounts: [PRIVATE_KEY]
        };
    }

    // polygon
    if (POLYGON_API_URL.length) {
        networks.polygon = {
            url: POLYGON_API_URL,
            accounts: [PRIVATE_KEY]
        };
    }
    if (MUMBAI_API_URL.length) {
        networks.polygonMumbai = {
            url: MUMBAI_API_URL,
            accounts: [PRIVATE_KEY]
        };
    }

    /*
     * END OF NETWORKS
     */

    const etherscan = {
        apiKey: {}
    };
    if (ETHERSCAN_API_KEY.length) {
        etherscan.apiKey.mainnet = ETHERSCAN_API_KEY;
        // etherscan.apiKey.sepolia = ETHERSCAN_API_KEY; // unsupported somehow
        etherscan.apiKey.goerli = ETHERSCAN_API_KEY;
    }
    if (BSCSCAN_API_KEY.length) {
        etherscan.apiKey.bsc = BSCSCAN_API_KEY;
        etherscan.apiKey.bscTestnet = BSCSCAN_API_KEY;
    }
    if (POLYGONSCAN_API_KEY.length) {
        etherscan.apiKey.polygon = POLYGONSCAN_API_KEY;
        etherscan.apiKey.polygonMumbai = POLYGONSCAN_API_KEY;
    }

    return {
        solidity: {
            version: "0.8.9",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        },
        defaultNetwork: 'hardhat',
        optimizer: true,
        networks,
        etherscan,
        paths: {
            sources: "./contracts",
            tests: "./test",
            cache: "./cache",
            artifacts: "./artifacts"
        },
        gasReporter: {
            enabled: true,
            // lets inspect how much will it cost in the currency below the key
            coinmarketcap: REPORT_CURRENCY ? COINMARKETCAP_API_KEY : '',
            currency: 'USD'

        },
        abiExporter: {
            path: './abi',
            runOnCompile: true,
            clear: true,
            flat: true,
            spacing: 2,
            pretty: true
        }
    }
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = buildConfig();
