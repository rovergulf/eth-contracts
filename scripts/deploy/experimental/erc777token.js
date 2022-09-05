const {getDevSigners, deploy} = require("../../utils/deploy");

async function main() {
    const {deployer} = await getDevSigners();


    const nonce = await deployer.getTransactionCount();
    const tokenAddr = ethers.utils.getContractAddress({
        from: deployer.address,
        nonce,
    });
    const poolAddr = ethers.utils.getContractAddress({
        from: deployer.address,
        nonce: nonce + 1,
    });
    const vaultAddr = ethers.utils.getContractAddress({
        from: deployer.address,
        nonce: nonce + 2,
    });
    const stakeAddr = ethers.utils.getContractAddress({
        from: deployer.address,
        nonce: nonce + 3,
    });

    const defaultOperators = [poolAddr, vaultAddr, stakeAddr];

    await deploy('RovergulfCoin', []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
