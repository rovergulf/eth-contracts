const {getDevSigners, deploy} = require("../../utils/deploy");

async function main() {
    const {deployer} = await getDevSigners();
    await deploy('SimpleForwarder', []);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
