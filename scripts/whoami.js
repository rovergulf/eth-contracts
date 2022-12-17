const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const balance = await deployer.getBalance();
    const chainId = await deployer.getChainId();

    console.log(`ChainID: ${chainId}`);
    console.log(`Deployer: ${deployer.address}`);
    console.log(`Balance: ${hre.ethers.utils.formatEther(balance)}`);

    const netResults = await deployer.provider.getNetwork();
    const gasPrice = await deployer.provider.getGasPrice();
    console.log(`Network: ${netResults.chainId} / ${netResults.name}`)
    console.log(`Gas price: ${gasPrice.toString()} Wei / ${hre.ethers.utils.formatUnits(gasPrice, 'gwei')} GWei`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
