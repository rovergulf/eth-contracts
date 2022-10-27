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

const tokenInterfaceErc721 = 1;
const tokenInterfaceErc1155 = 2;

const fixedPrice1 = ethers.utils.parseEther('10');

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

        // mint erc20 supply assets
        await this.tokenOne.mint(user2.address, mintAmount);
        await this.tokenOne.mint(user3.address, mintAmount);
        await this.tokenTwo.mint(user3.address, mintAmount);
        await this.tokenTwo.mint(user4.address, mintAmount);
        await this.tokenTwo.mint(user5.address, mintAmount);
        // mint erc721 assets
        await this.erc721.safeMint(user2.address); // 1
        await this.erc721.safeMint(user2.address); // 2
        await this.erc721.safeMint(user2.address); // 3
        await this.erc721.safeMint(user3.address); // 4
        await this.erc721.safeMint(user3.address); // 5
        await this.erc721.safeMint(user5.address); // 6
        // mint erc1155 assets
        await this.erc1155.mint(user3.address, 1, 10, []);
        await this.erc1155.mint(user3.address, 2, 10, []);
        await this.erc1155.mint(user3.address, 2, 5, []);
        await this.erc1155.mint(user4.address, 3, 1, []);
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

    it("Should revert with ERC721 caller not approved", async function () {
        const sellOrder2 = {
            maker: user2.address,
            taker: ZERO_ADDRESS,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: ZERO_ADDRESS,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const buyOrder2 = {
            maker: user4.address,
            taker: user2.address,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: ZERO_ADDRESS,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const sellHash = await this.exchange.hashOrder(sellOrder2);
        const buyHash = await this.exchange.hashOrder(buyOrder2);

        const sellSig = await user2.signMessage(ethers.utils.arrayify(sellHash));
        const buySig = await user4.signMessage(ethers.utils.arrayify(buyHash));

        await expect(this.exchange.atomicMatch(sellOrder2, buyOrder2, sellSig, buySig)).to.be.revertedWith('ERC721: caller is not token owner nor approved');
    });

    it("Should execute exchange order for ETH", async function () {
        const sellOrder1 = {
            maker: user2.address,
            taker: ZERO_ADDRESS,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: ZERO_ADDRESS,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const buyOrder1 = {
            maker: user4.address,
            taker: user2.address,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: ZERO_ADDRESS,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const sellHash = await this.exchange.hashOrder(sellOrder1);
        const buyHash = await this.exchange.hashOrder(buyOrder1);

        const sellSig = await user2.signMessage(ethers.utils.arrayify(sellHash));
        const buySig = await user4.signMessage(ethers.utils.arrayify(buyHash));

        await this.erc721.connect(user2).approve(this.exchange.address, 1);

        const balance1 = await provider.getBalance(user2.address);

        await this.exchange.connect(user4).atomicMatch(sellOrder1, buyOrder1, sellSig, buySig, {value: fixedPrice1});

        const sellerFee = balance1.add(ethers.utils.parseEther('9.5'));
        const balance2 = await provider.getBalance(user2.address);
        expect(balance2).to.gt(sellerFee);
    });

    it("Should execute exchange order for testTokenTwo", async function () {
        const sellOrder3 = {
            maker: user2.address,
            taker: ZERO_ADDRESS,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: this.tokenTwo.address,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const buyOrder3 = {
            maker: user4.address,
            taker: user2.address,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: this.tokenTwo.address,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const sellHash = await this.exchange.hashOrder(sellOrder3);
        const buyHash = await this.exchange.hashOrder(buyOrder3);

        const sellSig = await user2.signMessage(ethers.utils.arrayify(sellHash));
        const buySig = await user4.signMessage(ethers.utils.arrayify(buyHash));

        await this.erc721.connect(user2).approve(this.exchange.address, 1);
        await this.tokenTwo.connect(user4).approve(this.exchange.address, fixedPrice1);

        await this.exchange.connect(user4).atomicMatch(sellOrder3, buyOrder3, sellSig, buySig, {value: fixedPrice1});

        const sellerFee = ethers.utils.parseEther('9.75');
        const balance3 = await this.tokenTwo.balanceOf(user2.address);
        expect(balance3).to.equal(sellerFee);
    });

    it("Should revert with ERC20 wrong allowance", async function () {
        const sellOrder2 = {
            maker: user2.address,
            taker: ZERO_ADDRESS,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: this.tokenTwo.address,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const buyOrder2 = {
            maker: user4.address,
            taker: user2.address,
            tokenInterface: tokenInterfaceErc721,
            nftAddress: this.erc721.address,
            nftTokenId: 1,
            nftAmount: 1,
            token: this.tokenTwo.address,
            value: fixedPrice1,
            feeRecipients: [user2.address, user1.address],
            feeAmounts: [9750, 250],
        };

        const sellHash = await this.exchange.hashOrder(sellOrder2);
        const buyHash = await this.exchange.hashOrder(buyOrder2);

        const sellSig = await user2.signMessage(ethers.utils.arrayify(sellHash));
        const buySig = await user4.signMessage(ethers.utils.arrayify(buyHash));

        await this.erc721.connect(user2).approve(this.exchange.address, 1);

        await expect(this.exchange.atomicMatch(sellOrder2, buyOrder2, sellSig, buySig)).to.be.revertedWith('ERC20: insufficient allowance');
    });

});
