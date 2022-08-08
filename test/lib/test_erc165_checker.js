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
        // const erc20Factory = await hre.ethers.getContractFactory("DevERC20");
        const erc721Factory = await hre.ethers.getContractFactory("DevERC721");
        // const erc777Factory = await hre.ethers.getContractFactory("DevERC777");
        const erc1155Factory = await hre.ethers.getContractFactory("DevERC1155");

        this.erc1820 = await singletons.ERC1820Registry(user1.address);

        this.erc165 = await erc165CheckerFactory.deploy();
        // this.erc20 = await erc20Factory.deploy();
        this.erc721 = await erc721Factory.deploy();
        // this.erc777 = await erc777Factory.deploy([]);
        this.erc1155 = await erc1155Factory.deploy();
    });

    it("Should confirm that user1 is an owner of erc721", async () => {
        expect(await this.erc721.owner()).to.equal(user1.address);
    });

    it("Should confirm ERC721 interface", async () => {
        expect(await this.erc165.isERC721(this.erc721.address)).to.equal(true);
    });

    it("Should confirm ERC1155 interface", async () => {
        expect(await this.erc165.isERC1155(this.erc1155.address)).to.equal(true);
    });
});
