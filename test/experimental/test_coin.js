const {expect} = require("chai");
const {ethers, waffle} = require("hardhat");
const {singletons} = require('@openzeppelin/test-helpers');
require('@openzeppelin/test-helpers/configure');
const {BigNumber} = require("ethers");
const {delay} = require("../../scripts/utils/helpers");

const provider = waffle.provider;

const mintAmount = ethers.utils.parseEther('1000000');
const mintAmount2 = ethers.utils.parseEther('10000');
const depositAmount = ethers.utils.parseEther("1000");
const withdrawAmount = ethers.utils.parseEther("100");
const maxLimitMint = ethers.utils.parseEther("100000000");

function prepareOperatorVestData(address, lock = BigNumber.from(0), period = BigNumber.from(10), parts = BigNumber.from(10)) {
    return ethers.utils.defaultAbiCoder.encode([
        'uint256', 'uint256', 'uint256', 'address'
    ], [
        lock, period, parts, address,
    ]);
}

describe("Rovergulf Coin tests", function () {
    let user1, user2, user3, user4, user5, user6, user7, user8;
    beforeEach(async function () {
        [user1, user2, user3, user4, user5, user6, user7, user8] = await hre.ethers.getSigners();

        await singletons.ERC1820Registry(user1.address);
        const coinMockFactory = await ethers.getContractFactory('CoinMock');
        const coinFactory = await ethers.getContractFactory('RovergulfCoin');
        const poolFactory = await ethers.getContractFactory('RCPoolManager');
        const stakeFactory = await ethers.getContractFactory('RCStake');
        const vestFactory = await ethers.getContractFactory('RCVault');

        const nonce = await user1.getTransactionCount();

        // const tokenAddr = ethers.utils.getContractAddress({from: user1.address, nonce});
        const poolAddr = ethers.utils.getContractAddress({from: user1.address, nonce: nonce + 1});
        const stakeAddr = ethers.utils.getContractAddress({from: user1.address, nonce: nonce + 2});
        const vestAddr = ethers.utils.getContractAddress({from: user1.address, nonce: nonce + 3});
        const mockAddr = ethers.utils.getContractAddress({from: user1.address, nonce: nonce + 5});

        const initialRecipients = [
            poolAddr, stakeAddr, user1.address, user2.address,
        ];
        const initialAmounts = [
            mintAmount, mintAmount, mintAmount2, mintAmount2,
        ];
        const defaultOperators = [
            poolAddr, stakeAddr, vestAddr, mockAddr,
        ];
        this.token = await coinFactory.deploy(initialRecipients, initialAmounts, defaultOperators);
        await this.token.deployed();

        this.pool = await poolFactory.deploy('Test RC pool', this.token.address);
        await this.pool.deployed();

        this.stake = await stakeFactory.deploy('Test stake', this.token.address, this.pool.address);
        await this.stake.deployed();

        this.vest = await vestFactory.deploy('Test vest', this.token.address, this.pool.address);
        await this.vest.deployed();

        this.mock = await coinMockFactory.deploy(this.token.address);
        await this.mock.deployed();
    });

    it("Should validate that deployer (user1) owns minted amount of tokens", async function () {
        const balance = await this.token.balanceOf(user1.address);
        expect(balance).to.equal(mintAmount2);
    });

    it("Should validate that pool owns minted amount of tokens", async function () {
        const balance = await this.token.balanceOf(this.pool.address);
        expect(balance).to.equal(mintAmount);
    });

    it("Should mint additional tokens for user6", async function () {
        await this.pool.mint(user6.address, mintAmount, []);
        const balance = await this.token.balanceOf(user6.address);
        expect(balance).to.equal(mintAmount);
    });

    it("Should not let mint more than max limit set", async function () {
        await expect(this.pool.mint(user4.address, maxLimitMint, []))
            .to.be.revertedWith('Amount exceeds token mint limit');
    });

    it("Should not let non-operator to mint tokens", async function () {
        await expect(this.token.connect(user4).mint(user4.address, mintAmount, []))
            .to.be.revertedWith('Restricted to token default operators');
    });

    it("Should transfer to vest specified amount of token for user1", async function () {
        const vestingData = prepareOperatorVestData(user1.address);
        const tx = await this.pool.operatorSend(
            this.vest.address, depositAmount, [], vestingData,
        );
        const balance = await this.token.balanceOf(this.vest.address);
        expect(balance).to.equal(depositAmount);
    });

    it("Should confirm vest deposit balance of user2", async function () {
        const vestingData = prepareOperatorVestData(user2.address);
        const tx = await this.pool.operatorSend(
            this.vest.address, depositAmount, [], ethers.utils.arrayify(vestingData),
        );
        const balance = await this.vest.balanceOf(user2.address);
        expect(balance).to.equal(depositAmount);
    });

    it("Should return shares after unlock delay for user3", async function () {
        const vestingData = prepareOperatorVestData(user3.address);
        await this.pool.operatorSend(
            this.vest.address, depositAmount, [], vestingData,
        );
        // console.log('Wait for 2100ms before checking unlocked balance');
        await delay(2100);

        const shares = await this.vest.computeShares(user3.address);
        expect(shares).to.gte(ethers.utils.parseEther("200"));
    });

    it("Should withdraw available amount of token for user4", async function () {
        const vestingData = prepareOperatorVestData(user4.address);
        await this.pool.operatorSend(
            this.vest.address, depositAmount, [], vestingData,
        );
        // console.log('Wait for 1100ms before withdraw');
        await delay(1100);
        const tx = await this.vest.connect(user4).release(withdrawAmount);
        const balance = await this.token.balanceOf(user4.address);
        expect(balance).to.equal(withdrawAmount);
    });

    it("Should withdraw available amount of token for user5 by user4", async function () {
        const vestingData = prepareOperatorVestData(user4.address);
        await this.pool.operatorSend(
            this.vest.address, depositAmount, [], vestingData,
        );
        // console.log('Wait for 1100ms before withdraw');
        await delay(1100);
        const tx = await this.vest.connect(user4).releaseTo(user5.address, withdrawAmount);
        const balance = await this.token.balanceOf(user5.address);
        expect(balance).to.equal(withdrawAmount);
    });

    it("Should not let withdraw due delayed release for user6", async function () {
        const vestingData = prepareOperatorVestData(user6.address, BigNumber.from(5));
        await this.pool.operatorSend(
            this.vest.address, depositAmount, [], vestingData,
        );
        await expect(this.vest.connect(user6).release(withdrawAmount))
            .to.be.revertedWith("Requested withdraw exceeds available balance");
    });

    it("Should not let withdraw due exceeded release limit for user6", async function () {
        const vestingData = prepareOperatorVestData(user6.address);
        await this.pool.operatorSend(
            this.vest.address, depositAmount, [], vestingData,
        );
        await delay(1100);
        await expect(this.vest.connect(user6).release(ethers.utils.parseEther("800")))
            .to.be.revertedWith("Requested withdraw exceeds available balance");
    });
});
