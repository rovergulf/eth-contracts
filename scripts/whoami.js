const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const balance = await deployer.getBalance();
    const chainId = await deployer.getChainId();

    console.log(`ChainID: ${chainId}`);
    console.log(`Deployer: ${deployer.address}`);
    console.log(`Balance: ${hre.ethers.utils.formatEther(balance)}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
