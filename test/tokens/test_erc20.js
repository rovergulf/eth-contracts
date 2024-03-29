const {expect} = require("chai");
const hre = require("hardhat");
const {ethers} = hre;

describe("DevERC20", function () {
    let erc20;

    const nilAmount = ethers.utils.parseEther('0');
    const minAmount = ethers.utils.parseEther("100");
    const maxAmount = ethers.utils.parseEther("10000");
    const minAllowance = ethers.utils.parseEther("10");
    const maxAllowance = ethers.utils.parseEther("75");
    const allowanceDiff = ethers.utils.parseEther("65");

    beforeEach(async () => {
        const erc20Factory = await hre.ethers.getContractFactory("DevERC20");
        [user1, user2, user3, user4, user5, user6] =
            await ethers.getSigners();
        erc20 = await erc20Factory.deploy("TestTokenZero", "TT0");


        // deploy contracts
        await erc20.deployed();

        await erc20.mint(user1.address, maxAmount);
        await erc20.mint(user3.address, maxAllowance);
        await erc20.mint(user4.address, maxAmount);
    });

    it("Should confirm that user2 has requested token balance", async () => {
        const tx = await erc20.mint(user2.address, minAmount);
        await tx.wait();
        expect(await erc20.balanceOf(user2.address)).to.equal(minAmount);
    });

    it("Should confirm that user3 has requested token balance", async () => {
        expect(await erc20.balanceOf(user3.address)).to.equal(maxAllowance);
    });

    it("Should confirm that user2 has allowed user3 to spend from its balance", async () => {
        const tx = await erc20.connect(user2).approve(user3.address, minAllowance);
        await tx.wait();
        expect(await erc20.allowance(user2.address, user3.address)).to.equal(minAllowance);
    });

    it("Should confirm that user2 has increased allowance for user3 to spend", async () => {
        const tx = await erc20.connect(user2).increaseAllowance(user3.address, allowanceDiff);
        await tx.wait();
        expect(await erc20.allowance(user2.address, user3.address)).to.equal(allowanceDiff);
    });

    it("Should confirm that user2 has increased allowance for user3 to spend", async () => {
        expect(await erc20.allowance(user2.address, user3.address)).to.equal(nilAmount);
    });

    it("Should be reverted for non owner/admin caller", async () => {
        await expect(erc20.connect(user2).mint(user2.address, maxAmount)).be.revertedWith('Administrated: caller is not an owner, nor admin');
    });

});
