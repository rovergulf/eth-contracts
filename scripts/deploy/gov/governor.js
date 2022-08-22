const hre = require("hardhat");
const {deploy, getDevSigners} = require("../../utils/deploy");

const rinkebyAddrs = require('../../chains/rinkeby/tokens');
const bsctestAddrs = require('../../chains/bsctest/tokens');

async function main() {
    const {chainId} = await getDevSigners();

    let erc20VotesAddress;

    switch (chainId) {
        case 4:
            erc20VotesAddress = rinkebyAddrs.erc20;
            break;
        case 97:
            erc20VotesAddress = bsctestAddrs.erc20;
            break;
        default:
            console.log(`Unsupported chain id: ${chainId}`);
            return;
    }

    await deploy('DevGovernor', [
        erc20VotesAddress,
    ]);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
