const hre = require("hardhat");
const {delay} = require("./helpers");
const {run} = require("hardhat");

async function getDevSigners() {
    const signers = await hre.ethers.getSigners();
    const deployer = signers[0];
    const chainId = await deployer.getChainId();
    return {
        deployer, chainId,
        signers: signers.length > 0 ? signers : undefined,
    }
}

async function deploy(factoryName, constructorArgs = []) {
    const {deployer, chainId} = await getDevSigners();
    console.log(`ChainID: ${chainId}; Deployer: ${deployer.address}`);

    const ercFactory = await hre.ethers.getContractFactory(factoryName);
    const erc = await ercFactory.deploy(...constructorArgs);

    await erc.deployed();
    console.log(`${factoryName} deployed to: ${erc.address}`);

    if (process.env.SKIP_VERIFICATION) {
        return;
    }

    console.log('Wait for 30 sec before verification');
    await delay(30000);

    await verify(erc.address, constructorArgs, factoryName);

    return erc.address;
}

async function verify(address, args, factoryName) {
    return run("verify:verify", {
        address,
        contract: contractByFactoryName(factoryName),
        constructorArguments: [...args]
    });
}

function contractByFactoryName(v) {
    switch (v) {
        // token
        case 'DevERC20':
            return "contracts/tokens/ERC20.sol:DevERC20";
        case 'DevERC721':
            return "contracts/tokens/ERC721.sol:DevERC721";
        case 'DevERC777':
            return "contracts/tokens/ERC777.sol:DevERC777";
        case 'DevERC1155':
            return "contracts/tokens/ERC1155.sol:DevERC1155";
        case 'DevGovernor':
            return "contracts/common/Governance.sol:DevGovernor";
        // introspection
        case 'InterfaceChecker':
            return "contracts/lib/ERC165Checker.sol:InterfaceChecker";
        // experimental
        case 'SimpleForwarder':
            return "contracts/experimental/SimpleForwarder.sol:SimpleForwarder";
        default:
            return '';
    }
}

module.exports = {
    getDevSigners,
    deploy,
    verify
};
