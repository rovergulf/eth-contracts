const {expect} = require("chai");
const {ethers} = require("hardhat");
const {singletons} = require('@openzeppelin/test-helpers');
require('@openzeppelin/test-helpers/configure');

const mintAmount = ethers.utils.parseEther('1');

describe("ERC777 Token tests", function () {
    beforeEach(async function () {
        const deployers = await hre.ethers.getSigners();
        this.deployer = deployers[0];

        this.erc1820 = await singletons.ERC1820Registry(this.deployer.address);

        const erc777Factory = await ethers.getContractFactory('DevERC777')
        this.token = await erc777Factory.deploy([]);
        console.info('token deployed to', this.token.address);
    });

    it("Should validate that deployer owns minted amount of tokens", async function () {
        const balance = await this.token.balanceOf(this.deployer.address);
        expect(balance).to.equal(0);
    });
});
