// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const {delay} = require("../../utils/helpers");
const {run} = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    const chainId = await deployer.getChainId();
    console.log(`ChainID: ${chainId}; Deployer: ${deployer.address}`);

    const erc777Factory = await hre.ethers.getContractFactory('DevERC777');
    const erc777 = await erc777Factory.deploy();

    await erc777.deployed();
    console.log(`DevERC777 deployed to: ${erc777.address}`);

    if (process.env.SKIP_VERIFICATION) {
        return;
    }

    console.log('Wait for 30 sec before verification');
    delay(30000);

    await run("verify:verify", {
        address: erc777.address,
        contract: "contracts/tokens/ERC777.sol:DevERC777",
        constructorArguments: []
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
