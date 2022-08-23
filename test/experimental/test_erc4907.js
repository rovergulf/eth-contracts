const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("ERC4907", function () {
    let user1, user2, user3;

    beforeEach(async () => {
        [user1, user2, user3] =
            await ethers.getSigners();

        const erc4907Factory = await hre.ethers.getContractFactory("ERC4907");
        this.erc4907 = await erc4907Factory.deploy();
        await this.erc4907.deployed();
    });

    it("Should confirm that user1 is an owner of erc721", async () => {
        expect(await this.erc4907.owner()).to.equal(user1.address);
    });

});
