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

    const erc20Factory = await hre.ethers.getContractFactory('DevERC20');
    const erc20 = await erc20Factory.deploy();

    await erc20.deployed();
    console.log(`DevERC20 deployed to: ${erc20.address}`);

    if (process.env.SKIP_VERIFICATION) {
        return;
    }

    console.log('Wait for 30 sec before verification');
    delay(30000);

    await run("verify:verify", {
        address: erc20.address,
        contract: "contracts/tokens/ERC20.sol:DevERC20",
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
