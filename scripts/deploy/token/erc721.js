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

    const erc721Factory = await hre.ethers.getContractFactory('DevERC721');
    const erc721 = await erc721Factory.deploy();

    await erc721.deployed();
    console.log(`DevERC721 deployed to: ${erc721.address}`);

    if (process.env.SKIP_VERIFICATION) {
        return;
    }

    console.log('Wait for 30 sec before verification');
    delay(30000);

    await run("verify:verify", {
        address: erc721.address,
        contract: "contracts/tokens/ERC721.sol:DevERC721",
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
