const { expect, should, assert } = require("chai");
const { ethers } = require("hardhat");
require("@nomiclabs/hardhat-ethers");

const nameErc721 = "Thetan Hero";
const symbolErc721 = "THTN";
const uriErc721 = "https://antonymnft.s3.us-west-1.amazonaws.com/json/";

const nameErc20 = "GameCoin";
const symbolErc20 = "GCN";

describe("Greeter", function () {
  it("Should create a greeting", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");
  });
});


describe("NFT Lending in Oracle", function () {
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
  let erc20R;

  before(async function () {
    const PlayerHero = await ethers.getContractFactory("PlayerHero");
    playerHero = await PlayerHero.deploy(nameErc721, symbolErc721, "");
    await playerHero.deployed();
    const LendingOracle = await ethers.getContractFactory("LendingOracle");
    lendingOracle = await LendingOracle.deploy();
    await lendingOracle.deployed();

    // console.log("PlayerHero deployed at: ", playerHero.address);
    // console.log("LendingOracle deployed at: ", lendingOracle.address);
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
    const returnCallData = await lendingOracle.dataEncoder(playerHero.address, nft1Owner.address, 100);
    expect(returnCallData).to.equal((playerHero.address +
      nft1Owner.address.slice(2) +
      "0000000000000000000000000000000000000000000000000000000000000064").toLowerCase());
  });

  /* it("encoded data should work to create lending agreements", async function () {
       won't work now since have made the fuction private
     const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();

     const returnCallData = await lendingOracle.dataEncoder(playerHero.address, nft1Renter.address, 100);
     const createAgrTxn = await lendingOracle.connect(nft1Owner)._createLendingAgreement(nft1Owner.address, 1, returnCallData);
     const agreementCreated = await lendingOracle.isCurrentlyRented(playerHero.address, 1);

     expect(agreementCreated).to.equal(true);
   })
   */

  it("transferring an NFT with data should create a lending agreement ", async function () {
    const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();

    const returnCallData = await lendingOracle.dataEncoder(playerHero.address, nft1Renter.address, 100);
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


  it("Extending the contract should not be possible if the term hasn't expired yet", async function () {
    const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();
    try {
      const agreementExtended = await lendingOracle.connect(nft1Owner).extendAgreement(playerHero.address, 1, 100);
    }
    catch (e) {
      expect(e.toString()).to.
        equal("Error: VM Exception while processing transaction: reverted with reason string 'LendingOracle: Previous agreement not expired'");
    }
  })

  it("Extending the contracts should be possible after the term has expired", async function () {
    const [owner, nft1Owner, nft1Renter] = await ethers.getSigners();
    // mining 101 blocks to fastforward
    let x = 101;
    while (x > 0) { x--;
      await hre.network.provider.request({
        method: "evm_mine",
        params: [],
      });
    }        

    const check1 = await lendingOracle.isCurrentlyRented(playerHero.address, 1);
    expect(check1[0]).to.equal(false);
    await lendingOracle.connect(nft1Owner).extendAgreement(playerHero.address, 1, 100);
    const check2 = await lendingOracle.isCurrentlyRented(playerHero.address, 1);
    expect(check2[0]).to.equal(true);
  })
});


describe( "ERC20 basic tests" , function(){
  let erc20R;

  before(async function () {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();
    const ERC20Rewardable = await ethers.getContractFactory("ERC20Rewardable");
    erc20R = await ERC20Rewardable.deploy(nameErc20, symbolErc20);
  })

  it("mint and safetransfer works", async function(){
      const [owner, addr1, addr2, addr3] = await ethers.getSigners();
      await erc20R.connect(addr1).mint(addr1.address, ethers.utils.parseEther("10", "ether"));
      let bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("10", "ether"));
      
      await erc20R.connect(addr1).safeTransfer(addr2.address, ethers.utils.parseEther("5", "ether"), 0x00);
      let bal2 = await erc20R.balanceOf(addr2.address);
      expect(bal2).to.equal(ethers.utils.parseEther("5", "ether"));
      bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("5", "ether"));

      await erc20R.connect(addr2).safeTransfer(addr1.address, ethers.utils.parseEther("5", "ether"), 0x00);
      bal2 = await erc20R.balanceOf(addr2.address);
      expect(bal2).to.equal(ethers.utils.parseEther("0", "ether"));
      bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("10", "ether"));

    });
    
    it("safeTransferFrom works", async function(){
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();
      await erc20R.connect(addr1).approve(addr3.address, ethers.utils.parseEther("100", "ether"));
      await erc20R.connect(addr3).safeTransferFrom(addr1.address, addr2.address,  ethers.utils.parseEther("3", "ether"), 0x00);
      let bal2 = await erc20R.balanceOf(addr2.address);
      expect(bal2).to.equal(ethers.utils.parseEther("3", "ether"));
      let bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("7", "ether"));
      let bal3 = await erc20R.balanceOf(addr3.address);
      expect(bal3).to.equal(ethers.utils.parseEther("0", "ether"));
    });

    it("safeMint works", async function(){
        const [owner, addr1, addr2, addr3] = await ethers.getSigners();
        await erc20R.connect(addr3).safeMint(addr3.address, ethers.utils.parseEther("100", "ether"), 0x00);
        let bal3 = await erc20R.balanceOf(addr3.address);
        expect(bal3).to.equal(ethers.utils.parseEther("100", "ether"));
    });

});



describe( "Handlin token rewards" , function(){
  let erc20R;

  before(async function () {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();
    const ERC20Rewardable = await ethers.getContractFactory("ERC20Rewardable");
    erc20R = await ERC20Rewardable.deploy(nameErc20, symbolErc20);
  })

  it("mint and safetransfer works", async function(){
      const [owner, addr1, addr2, addr3] = await ethers.getSigners();
      await erc20R.connect(addr1).mint(addr1.address, ethers.utils.parseEther("10", "ether"));
      let bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("10", "ether"));
      
      await erc20R.connect(addr1).safeTransfer(addr2.address, ethers.utils.parseEther("5", "ether"), 0x00);
      let bal2 = await erc20R.balanceOf(addr2.address);
      expect(bal2).to.equal(ethers.utils.parseEther("5", "ether"));
      bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("5", "ether"));

      await erc20R.connect(addr2).safeTransfer(addr1.address, ethers.utils.parseEther("5", "ether"), 0x00);
      bal2 = await erc20R.balanceOf(addr2.address);
      expect(bal2).to.equal(ethers.utils.parseEther("0", "ether"));
      bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("10", "ether"));

    });
    
    it("safeTransferFrom works", async function(){
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();
      await erc20R.connect(addr1).approve(addr3.address, ethers.utils.parseEther("100", "ether"));
      await erc20R.connect(addr3).safeTransferFrom(addr1.address, addr2.address,  ethers.utils.parseEther("3", "ether"), 0x00);
      let bal2 = await erc20R.balanceOf(addr2.address);
      expect(bal2).to.equal(ethers.utils.parseEther("3", "ether"));
      let bal1 = await erc20R.balanceOf(addr1.address);
      expect(bal1).to.equal(ethers.utils.parseEther("7", "ether"));
      let bal3 = await erc20R.balanceOf(addr3.address);
      expect(bal3).to.equal(ethers.utils.parseEther("0", "ether"));
    });

    it("safeMint works", async function(){
        const [owner, addr1, addr2, addr3] = await ethers.getSigners();
        await erc20R.connect(addr3).safeMint(addr3.address, ethers.utils.parseEther("100", "ether"), 0x00);
        let bal3 = await erc20R.balanceOf(addr3.address);
        expect(bal3).to.equal(ethers.utils.parseEther("100", "ether"));
    });

});