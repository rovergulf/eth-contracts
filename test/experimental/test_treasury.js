const {expect} = require("chai");
const {ethers, waffle} = require("hardhat");
const {singletons} = require('@openzeppelin/test-helpers');
require('@openzeppelin/test-helpers/configure');
const {BigNumber} = require("ethers");

const provider = waffle.provider;

const mintAmount = ethers.utils.parseEther('10000');
const depositAmount = ethers.utils.parseEther("1000");
const withdrawAmount = ethers.utils.parseEther("100");

describe("Treasury tests", function () {
    let user1, user2, user3, user4, user5, user6, user7, user8;
    beforeEach(async function () {
        [user1, user2, user3, user4, user5, user6, user7, user8] = await hre.ethers.getSigners();

        await singletons.ERC1820Registry(user1.address);
        const erc20Factory = await ethers.getContractFactory('DevERC20');
        const treasuryFactory = await ethers.getContractFactory('Treasury');

        this.tokenOne = await erc20Factory.deploy("TreasuryTest0", "TT0");
        await this.tokenOne.deployed();
        this.tokenTwo = await erc20Factory.deploy("TreasuryTest1", "TT1");
        await this.tokenTwo.deployed();

        this.treasury = await treasuryFactory.deploy();
        await this.treasury.deployed();

        await this.tokenOne.mint(user2.address, mintAmount);
        await this.tokenOne.mint(user3.address, mintAmount);
        await this.tokenTwo.mint(user4.address, mintAmount);
        await this.tokenTwo.mint(this.treasury.address, mintAmount);
    });

    it("Should validate that treasury contract deployed and has owner", async function () {
        const owner = await this.treasury.owner();
        expect(owner).to.equal(user1.address);
    });

    it("Should validate that deployer (user2) owns minted amount of tokens", async function () {
        const balance = await this.tokenOne.balanceOf(user2.address);
        expect(balance).to.equal(mintAmount);
    });

    it("Should successfully deposit ETH", async function () {
        const oldBalance = await provider.getBalance(this.treasury.address);
        const tx = await user2.sendTransaction({
            to: this.treasury.address,
            value: depositAmount,
        });

        const balance = await provider.getBalance(this.treasury.address);
        expect(balance).to.gt(oldBalance);
    });

    it("Should successfully withdraw ETH", async function () {
        await user3.sendTransaction({
            to: this.treasury.address,
            value: depositAmount,
        });

        const oldBalance = await provider.getBalance(user5.address);
        const tx = await this.treasury.releaseEth(
            user5.address, withdrawAmount,
        );
        const balance = await provider.getBalance(user5.address);
        expect(balance).to.equal(oldBalance.add(withdrawAmount));
    });

    it("Should successfully withdraw second token funds", async function () {
        const tx = await this.treasury.releaseToken(
            this.tokenTwo.address, user1.address, withdrawAmount,
        );
        const balance = await this.tokenTwo.balanceOf(user1.address);
        expect(balance).to.equal(withdrawAmount);
    });
});
