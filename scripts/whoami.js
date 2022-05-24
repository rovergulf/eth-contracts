// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const balance = await deployer.getBalance();
    const chainId = await deployer.getChainId();

    console.log(`ChainID: ${chainId}`);
    console.log(`Account: ${deployer.address}`);
    console.log(`Balance: ${hre.ethers.utils.formatEther(balance)}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
