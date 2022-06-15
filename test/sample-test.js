const { expect, should, assert } = require("chai");
const { ethers } = require("hardhat");

const nameErc721 = "Thetan Hero";
const symbolErc721 = "THTN";
const uriErc721 = "https://antonymnft.s3.us-west-1.amazonaws.com/json/";

describe("Greeter", function () {
  it("Should create a greeting", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");
  });
});


describe("Testing Contracts", function () {
  /*
    The state of the chain after all the tests are run:
    1. playerHero is the deployed PlayerHero contract
    2. lendingOracle is the deployed LendingOracle contract
    3. nft1Owner owns the nft with tokenId 
    4. nft1Owner has a lednign agreement to rent his Nft to nft1Renter
    5. token id 1 is in our oracle and is rented to nftowner2 for 10k blocks
  */


  let playerHero;
  let lendingOracle;

  before(async function () {
    const PlayerHero = await ethers.getContractFactory("PlayerHero");
    playerHero = await PlayerHero.deploy(nameErc721, symbolErc721, "");
    await playerHero.deployed();
    const LendingOracle = await ethers.getContractFactory("LendingOracle");
    lendingOracle = await LendingOracle.deploy();
    await lendingOracle.deployed();

    console.log("PlayerHero deployed at: ", playerHero.address);
    console.log("LendingOracle deployed at: ", lendingOracle.address);

  })

  it("Should mint an NFT and assign base Uri", async function () {
    const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();

    expect(await playerHero.owner()).to.equal(owner.address);

    const setBaseUriTxn = await playerHero.setBaseUri(uriErc721);
    // wait until the transaction is mined
    await setBaseUriTxn.wait();
    const mintTokenIdTxn = await playerHero.connect(nft1Owner).mint(nft1Owner.address, 1, { value: ethers.utils.parseEther("0.1") })
    expect(await playerHero.tokenURI(1)).to.equal(uriErc721 + "1");
  });

  it("dataEncoder should encode data ", async function () {
    const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();

    // calling the function in 
    const returnCallData = await lendingOracle.dataEncoder(playerHero.address, nft1Owner.address, 10000);
    expect(returnCallData).to.equal((playerHero.address +
      nft1Owner.address.slice(2) +
      "0000000000000000000000000000000000000000000000000000000000002710").toLowerCase());
  });

  /* it("encoded data should work to create lending agreements", async function () {
       won't work now since have made the fuction private
     const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();

     const returnCallData = await lendingOracle.dataEncoder(playerHero.address, nft1Renter.address, 10000);
     const createAgrTxn = await lendingOracle.connect(nft1Owner)._createLendingAgreement(nft1Owner.address, 1, returnCallData);
     const agreementCreated = await lendingOracle.isCurrentlyRented(playerHero.address, 1);

     expect(agreementCreated).to.equal(true);
   })
   */

   it("transferring an NFT with data should create a lending agreement ", async function () {
    const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();

    const returnCallData = await lendingOracle.dataEncoder(playerHero.address, nft1Renter.address, 10000);
    await playerHero.connect(nft1Owner)['safeTransferFrom(address,address,uint256,bytes)'](nft1Owner.address, lendingOracle.address, 1, returnCallData);
    const agreementCreated = await lendingOracle.isCurrentlyRented(playerHero.address, 1);

    expect(agreementCreated[0]).to.equal(true);
    expect(agreementCreated[1]).to.equal(nft1Renter.address);

   })

   it("isCurrentlyRented should return fasle if NFT is not rented ", async function () {
    const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();

    const agreementCreated = await lendingOracle.isCurrentlyRented(playerHero.address, 2);

    expect(agreementCreated[0]).to.equal(false);
    expect(agreementCreated[1]).to.equal("0x0000000000000000000000000000000000000000");

   })

});