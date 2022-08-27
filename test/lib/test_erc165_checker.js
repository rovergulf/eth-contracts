const {expect} = require("chai");
const hre = require("hardhat");
const {ethers} = hre;

const {singletons} = require('@openzeppelin/test-helpers');
require('@openzeppelin/test-helpers/configure');

describe("ERC165 Checker", function () {
    let user1, user2, user3;

    beforeEach(async () => {
        [user1, user2, user3] =
            await ethers.getSigners();

        const erc165CheckerFactory = await hre.ethers.getContractFactory("InterfaceChecker");
        const mockFactory = await hre.ethers.getContractFactory("InterfaceCheckerMock");

        this.erc165 = await erc165CheckerFactory.deploy();
        await this.erc165.deployed();
        this.mock = await mockFactory.deploy();
        await this.mock.deployed();
    });

    it("Should confirm that user1 is an owner of mock", async () => {
        expect(await this.mock.owner()).to.equal(user1.address);
    });

    it("Should confirm ERC721 interface", async () => {
        expect(await this.erc165.isERC721(this.mock.address)).to.equal(true);
    });

    it("Should confirm ERC721Enumerable interface", async () => {
        expect(await this.erc165.isERC721Enumerable(this.mock.address)).to.equal(true);
    });

    it("Should confirm ERC1155 interface", async () => {
        expect(await this.erc165.isERC1155(this.mock.address)).to.equal(true);
    });

    it("Should confirm ERC20 interface", async () => {
        expect(await this.erc165.isERC20(this.mock.address)).to.equal(true);
    });

    it("Should confirm ERC777 interface", async () => {
        expect(await this.erc165.isERC777(this.mock.address)).to.equal(true);
    });

    it("Should confirm ERC5313 (Light Contract Ownership) interface", async () => {
        expect(await this.erc165.isERC5313(this.mock.address)).to.equal(true);
    });

    it("Should confirm ERC4626 interface", async () => {
        expect(await this.erc165.isERC4626(this.mock.address)).to.equal(true);
    });
});
