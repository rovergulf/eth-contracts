const hre = require("hardhat");
const {deploy} = require("../../utils/deploy");

async function main() {
    await deploy('InterfaceChecker');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
