const {expect} = require("chai");
const hre = require("hardhat");
const {ethers} = hre;

describe("DevERC1155", function () {
    let erc1155;
    let user1, user2, user3, user4;

    beforeEach(async () => {
        const erc1155Factory = await hre.ethers.getContractFactory("DevERC1155");
        [user1, user2, user3, user4] =
            await ethers.getSigners();

        erc1155 = await erc1155Factory.deploy();
        await erc1155.deployed();

        // const mintTx1 = await erc1155.safeMint(user2.address);
        // await mintTx1.wait();
    });

    it("Should confirm that user1 is an original owner", async () => {
        expect(await erc1155.owner()).to.equal(user1.address);
    });

});
