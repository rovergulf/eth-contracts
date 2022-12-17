const {expect} = require("chai");
const hre = require("hardhat");
const {ethers} = hre;

describe("GenerativeERC721 tests", function () {
    let user1, user2, user3, user4, user5, user6;

    beforeEach(async () => {
        const erc721Factory = await hre.ethers.getContractFactory("GenerativeERC721");
        const claim721Factory = await hre.ethers.getContractFactory("ERC721ClaimFactory");
        const mockFactory = await hre.ethers.getContractFactory("GenerativeNFTsMock");

        [user1, user2, user3, user4, user5, user6] =
            await ethers.getSigners();

        this.erc721 = await erc721Factory.deploy("MyNFT_ERC721", "MNE7", 100);
        await this.erc721.deployed();

        this.claimFactory = await claim721Factory.deploy(this.erc721.address);
        await this.claimFactory.deployed();

        this.mock = await mockFactory.deploy(this.erc721.address);
        await this.mock.deployed();

        const operatorRole = await this.erc721.OPERATOR_ROLE();
        const minterRole = await this.erc721.MINTER_ROLE();
        const tx1 = await this.erc721.grantRole(operatorRole, this.mock.address);
        await tx1.wait();
        const tx2 = await this.erc721.grantRole(minterRole, this.claimFactory.address);
        await tx2.wait();
    });

    it("Should confirm that erc721 has valid owner", async () => {
        const owner = await this.erc721.owner();
        expect(owner).to.equal(user1.address);
    });

    it("Should confirm that claim factory has minter role for erc721", async () => {
        const minterRole = await this.erc721.MINTER_ROLE();
        const hasRole = await this.erc721.hasRole(minterRole, this.claimFactory.address);
        expect(hasRole).to.equal(true);
    });

    it("Should confirm that mock has operator role for erc721", async () => {
        const role = await this.erc721.OPERATOR_ROLE();
        const hasRole = await this.erc721.hasRole(role, this.mock.address);
        expect(hasRole).to.equal(true);
    });

    it("Should mint token for user2", async () => {
        const tx = await this.claimFactory.connect(user2).claim();
        const owner = await this.erc721.ownerOf(1);
        expect(owner).to.equal(user2.address);
    });

    it("Should mint token for user2", async () => {
        const tx = await this.claimFactory.connect(user2).claim();
        const owner = await this.erc721.ownerOf(1);
        expect(owner).to.equal(user2.address);
    });

    it("Should transfer token from user2 to user3 via operator call", async () => {
        const tx1 = await this.claimFactory.connect(user2).claim();
        await tx1.wait();

        const tx2 = await this.mock.transferToken(user2.address, user3.address, 1);
        await tx2.wait();

        const owner = await this.erc721.ownerOf(1);
        expect(owner).to.equal(user3.address);
    });


});
