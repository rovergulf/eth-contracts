const {expect} = require("chai");
const {ethers, waffle} = require("hardhat");
const {BigNumber} = require("ethers");

const provider = waffle.provider;

const mintAmount = ethers.utils.parseEther("10000");

describe("SimpleForwarder tests", function () {
    let user1, user2, user3, user4, user5, user6, user7, user8;
    beforeEach(async function () {
        [user1, user2, user3, user4, user5, user6, user7, user8] = await hre.ethers.getSigners();

        const erc20Factory = await ethers.getContractFactory('DevERC20');
        const simpleForwarderFactory = await ethers.getContractFactory('SimpleForwarder');

        this.tokenOne = await erc20Factory.deploy("SimpleForwarderTest0", "SFT0");
        await this.tokenOne.deployed();
        this.tokenTwo = await erc20Factory.deploy("SimpleForwarderTest1", "SFT1");
        await this.tokenTwo.deployed();

        this.frw = await simpleForwarderFactory.deploy();
        await this.frw.deployed();

        await this.tokenOne.transferOwnership(this.frw.address);
        await this.tokenTwo.transferOwnership(this.frw.address);
    });

    it("Should validate that simple forwarder has owner", async function () {
        const owner = await this.frw.owner();
        expect(owner).to.equal(user1.address);
    });

    it("Should validate that simple forwarder is owner of token one", async function () {
        const owner = await this.tokenOne.owner();
        expect(owner).to.equal(this.frw.address);
    });

    it("Should prepare and execute multiple calls", async function () {
        const callData1 = this.tokenOne.interface.encodeFunctionData(
            'mint',
            [user2.address, mintAmount],
        );
        const callData2 = this.tokenOne.interface.encodeFunctionData(
            'mint',
            [user3.address, mintAmount],
        );

        const callArgs = [
            [this.tokenOne.address, this.tokenOne.address],
            [0, 0],
            [callData1, callData2],
            "test mints"
        ];

        await this.frw.execute(...callArgs);

        const balance1 = await this.tokenOne.balanceOf(user2.address);
        expect(balance1).to.equal(mintAmount);

        const balance2 = await this.tokenOne.balanceOf(user3.address);
        expect(balance2).to.equal(mintAmount);
    });

    it("Should transfer ownership of token two to user4", async function () {
        const callData = this.tokenTwo.interface.encodeFunctionData(
            'transferOwnership',
            [user4.address],
        );

        const callArgs = [
            [this.tokenTwo.address],
            [0],
            [callData],
            "test transfer ownership"
        ];

        await this.frw.execute(...callArgs);
        const owner = await this.tokenTwo.owner();
        expect(owner).to.equal(user4.address);
    });

    it("Should revert with invalid targets length", async function () {
        const callData = this.tokenTwo.interface.encodeFunctionData(
            'transferOwnership',
            [user4.address],
        );

        const callArgs = [
            [],
            [0],
            [callData],
            "test transfer ownership"
        ];

        await expect(this.frw.execute(...callArgs))
            .to.be.revertedWith("At least one target are required");
    });

    it("Should revert with invalid values length", async function () {
        const callData = this.tokenTwo.interface.encodeFunctionData(
            'transferOwnership',
            [user4.address],
        );

        const callArgs = [
            [this.tokenTwo.address],
            [0, 0],
            [callData],
            "test transfer ownership"
        ];

        await expect(this.frw.execute(...callArgs))
            .to.be.revertedWith("Targets length must be equal to values");
    });

    it("Should revert with invalid callDatas length", async function () {
        const callData = this.tokenTwo.interface.encodeFunctionData(
            'transferOwnership',
            [user4.address],
        );

        const callArgs = [
            [this.tokenTwo.address],
            [0],
            [],
            "test transfer ownership"
        ];

        await expect(this.frw.execute(...callArgs))
            .to.be.revertedWith("Values length must be equal to callDatas");
    });
});
