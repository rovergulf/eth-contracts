require('dotenv').config();
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require('solidity-coverage');

const {
    // cannot be shared
    PRIVATE_KEY, // mainnet/testnet deployer key
    TEST_PK1, // additional test wallet key
    TEST_PK2, // additional test wallet key
    TEST_PK3, // additional test wallet key
    // ---
    // gas report
    REPORT_CURRENCY = false,
    REPORT_GAS = false, // include gas reports into tests
    // coinmarketcap.com api key
    COINMARKETCAP_API_KEY,
    // block explorers
    ETHERSCAN_API_KEY,
    OPTIMISMSCAN_API_KEY,
    POLYGONSCAN_API_KEY,
    BSCSCAN_API_KEY,
    // providers urls
    MAINNET_API_URL,
    RINKEBY_API_URL,
    OPTIMISM_API_URL,
    KOVAN_API_URL = 'https://kovan.infura.io/v3/',
    POLYGON_API_URL,
    MUMBAI_API_URL,
    BSC_API_URL,
    BSCTEST_API_URL,
} = process.env;

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

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
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
    networks: {
        hardhat: {
            // mining: {
            //     auto: false,
            //     interval: 500
            // }
        },
        // ethereum
        mainnet: {
            url: MAINNET_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
        rinkeby: {
            url: RINKEBY_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
        // optimism
        optimistic: {
            url: OPTIMISM_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
        kovan: {
            url: KOVAN_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
        // polygon
        polygon: {
            url: POLYGON_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
        mumbai: {
            url: MUMBAI_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
        // binance smart chain
        bsc: {
            url: BSC_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
        bscTest: {
            url: BSCTEST_API_URL,
            accounts: [`0x${PRIVATE_KEY}`],
        },
    },
    etherscan: {
        apiKey: {
            mainnet: ETHERSCAN_API_KEY,
            rinkeby: ETHERSCAN_API_KEY,
            // optimism
            // optimistic: OPTIMISMSCAN_API_KEY,
            kovan: OPTIMISMSCAN_API_KEY,
            // binance smart chain
            bsc: BSCSCAN_API_KEY,
            bscTestnet: BSCSCAN_API_KEY,
            // polygon
            polygon: POLYGONSCAN_API_KEY,
            polygonMumbai: POLYGONSCAN_API_KEY,
        },
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
    },
    gasReporter: {
        enabled: !!REPORT_GAS,
        // lets inspect how much will it cost in the currency below the key
        coinmarketcap: REPORT_CURRENCY ? COINMARKETCAP_API_KEY : '',
        currency: 'USD',
    },
};
