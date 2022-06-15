const { expect } = require("chai");
const { ethers } = require("hardhat");

const nameErc721 = "Thetan Hero";
const symbolErc721 = "THTN";
const uriErc721 = "https://antonymnft.s3.us-west-1.amazonaws.com/json/";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});


describe("Testing Contracts", function () {
  it("Should mint an NFT and assign base Uri", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const PlayerHero = await ethers.getContractFactory("PlayerHero");
    const playerHero = await PlayerHero.deploy(nameErc721, symbolErc721, "");
    await playerHero.deployed();

    expect(await playerHero.owner()).to.equal(owner.address);

    const setBaseUriTxn = await playerHero.setBaseUri(uriErc721);
    // wait until the transaction is mined
    await setBaseUriTxn.wait();
    const mintTokenIdTxn = await playerHero.connect(addr1).mint(addr1.address, 1, {value: ethers.utils.parseEther("0.1")})
    expect(await playerHero.tokenURI(1)).to.equal(uriErc721+"1");
  });

  it("Lending Oracle deployment", async function () {
    const [owner, addr1] = await ethers.getSigners();

    const LendingOracle = await ethers.getContractFactory("LendingOracle");
    const lendingOracle = await LendingOracle.deploy();
    await lendingOracle.deployed();

    expect(await playerHero.owner()).to.equal(owner.address);

    const setBaseUriTxn = await playerHero.setBaseUri(uriErc721);
    // wait until the transaction is mined
    await setBaseUriTxn.wait();
    const mintTokenIdTxn = await playerHero.connect(addr1).mint(addr1.address, 1, {value: ethers.utils.parseEther("0.1")})
    expect(await playerHero.tokenURI(1)).to.equal(uriErc721+"1");
  });
  
});