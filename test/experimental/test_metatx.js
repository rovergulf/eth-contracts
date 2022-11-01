const {expect} = require("chai");
const {ethers, waffle} = require("hardhat");
const {singletons} = require('@openzeppelin/test-helpers');
require('@openzeppelin/test-helpers/configure');
const {BigNumber} = require("ethers");

const provider = waffle.provider;

const mintAmount = ethers.utils.parseEther('10000');
const depositAmount = ethers.utils.parseEther("1000");
const withdrawAmount = ethers.utils.parseEther("100");

describe("MetaTransaction tests", function () {
    let user1, user2, user3, user4, user5, user6, user7, user8;
    beforeEach(async function () {
        [user1, user2, user3, user4, user5, user6, user7, user8] = await hre.ethers.getSigners();

        await singletons.ERC1820Registry(user1.address);
        const erc20Factory = await ethers.getContractFactory('DevERC20');
        const registryFactory = await ethers.getContractFactory('MetaTxRegistry');
        const forwarderFactory = await ethers.getContractFactory('MetaForwarder');

        this.tokenOne = await erc20Factory.deploy("TreasuryTest0", "TT0");
        await this.tokenOne.deployed();
        this.tokenTwo = await erc20Factory.deploy("TreasuryTest1", "TT1");
        await this.tokenTwo.deployed();

        this.forwarder = await forwarderFactory.deploy();
        await this.forwarder.deployed();

        this.registry = await registryFactory.deploy(this.forwarder.address);
        await this.registry.deployed();

        await this.tokenOne.mint(user2.address, mintAmount);
        await this.tokenOne.mint(user3.address, mintAmount);
        await this.tokenTwo.mint(user4.address, mintAmount);
    });

    it("Should validate that MetaTxForwarder contract deployed and has owner", async function () {
        const owner = await this.forwarder.owner();
        expect(owner).to.equal(user1.address);
    });

});
