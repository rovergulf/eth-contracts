const {expect} = require("chai");
const {ethers, waffle} = require("hardhat");
const {singletons} = require('@openzeppelin/test-helpers');
require('@openzeppelin/test-helpers/configure');
const {ZERO_ADDRESS} = require("@openzeppelin/test-helpers/src/constants");
const {BigNumber} = require("ethers");

const provider = waffle.provider;
const abiCoder = ethers.utils.defaultAbiCoder;

const mintAmount = ethers.utils.parseEther('10000');
const transferAmount1 = ethers.utils.parseEther("1000");
const transferAmount2 = ethers.utils.parseEther("100");

describe("Exchange tests", function () {
    let user1, user2, user3, user4, user5, user6, user7, user8;
    beforeEach(async function () {
        [user1, user2, user3, user4, user5, user6, user7, user8] = await hre.ethers.getSigners();

        await singletons.ERC1820Registry(user1.address);
        const erc20Factory = await ethers.getContractFactory('DevERC20');
        const erc721Factory = await ethers.getContractFactory('DevERC721');
        const erc1155Factory = await ethers.getContractFactory('DevERC1155');
        const exchangeFactory = await ethers.getContractFactory('NFTExchange');

        this.tokenOne = await erc20Factory.deploy("TreasuryTest0", "TT0");
        await this.tokenOne.deployed();
        this.tokenTwo = await erc20Factory.deploy("TreasuryTest1", "TT1");
        await this.tokenTwo.deployed();
        this.erc721 = await erc721Factory.deploy();
        await this.erc721.deployed();
        this.erc1155 = await erc1155Factory.deploy();
        await this.erc1155.deployed();

        this.exchange = await exchangeFactory.deploy();
        await this.exchange.deployed();

        await this.tokenOne.mint(user2.address, mintAmount);
        await this.tokenOne.mint(user3.address, mintAmount);
        await this.tokenTwo.mint(user3.address, mintAmount);
        await this.tokenTwo.mint(user4.address, mintAmount);
        await this.erc721.safeMint(user2.address);
        await this.erc721.safeMint(user3.address);
        await this.erc1155.safeMint(user3.address, 1, 1, []);
        await this.erc1155.safeMint(user3.address, 2, 2, []);
        await this.erc1155.safeMint(user4.address, 1, 1, []);
    });

    it("Should validate that exchange has owner", async function () {
        const owner = await this.exchange.owner();
        expect(owner).to.equal(user1.address);
    });

    it("Should validate that user2 has valid tokenOne balance", async function () {
        const balance = await this.tokenOne.balanceOf(user2.address);
        expect(balance).to.equal(mintAmount);
    });

    it("Should validate that user4 has valid tokenTwo balance", async function () {
        const balance = await this.tokenTwo.balanceOf(user4.address);
        expect(balance).to.equal(mintAmount);
    });

    it("Should execute exchange order", async function () {

        const sellOrder = {
            maker: user2.address,
            taker: user4.address,
            target: this.tokenOne.address,
            callData: sellData,
        };

        const buyOrder = {
            maker: user4.address,
            taker: user2.address,
            target: this.tokenTwo.address,
            callData: buyData,
        };

        await this.exchange.atomicMatch(sellData, buyData, sellSig, buySig);

        const balance2 = this.tokenTwo.balanceOf(user2.address);
        expect(balance2).to.equal(transferAmount1);
    });

});
