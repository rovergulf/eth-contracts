const {expect} = require("chai");
const hre = require("hardhat");
const {ethers} = hre;

describe("DevERC721", function () {
    let erc721;
    let user1, user2, user3, user4;

    beforeEach(async () => {
        const erc721Factory = await hre.ethers.getContractFactory("DevERC721");
        [user1, user2, user3, user4] =
            await ethers.getSigners();

        erc721 = await erc721Factory.deploy();
        await erc721.deployed();

        // const mintTx1 = await erc721.safeMint(user2.address);
        // await mintTx1.wait();
    });

    it("Should confirm that user1 is an original owner", async () => {
        expect(await erc721.owner()).to.equal(user1.address);
    });

});
