const {expect} = require("chai");
const hre = require("hardhat");
const {ethers} = hre;

describe("Administrated", function () {
    let erc20;
    let user1, user2, user3;

    beforeEach(async () => {
        const erc20Factory = await hre.ethers.getContractFactory("DevERC20");
        [user1, user2, user3] =
            await ethers.getSigners();
        erc20 = await erc20Factory.deploy();
    });

    it("Should confirm that user1 is an owner of Administrated contract", async () => {
        expect(await erc20.owner()).to.equal(user1.address);
    });

    it("Should confirm that user1 successfully transferred ownership to user2", async () => {
        const tx = await erc20.transferOwnership(user2.address)
        await tx.wait();
        const admin = await erc20.defaultAdmin();
        const owner = await erc20.owner();
        expect(owner === user2.address && admin === user1.address).to.equal(true);
    });

    it("Should confirm that user1 successfully transferred ownership twice to user3", async () => {
        const tx1 = await erc20.transferOwnership(user2.address)
        await tx1.wait();

        const tx2 = await erc20.transferOwnership(user3.address)
        await tx2.wait();

        expect(await erc20.owner()).to.equal(user3.address);
    });

    it("Should confirm that user1 transferred and got back ownership back from new owner", async () => {
        const tx1 = await erc20.transferOwnership(user2.address)
        await tx1.wait();

        const tx2 = await erc20.connect(user2).transferOwnership(user1.address)
        await tx2.wait();

        expect(await erc20.owner()).to.equal(user1.address);
    });
});
