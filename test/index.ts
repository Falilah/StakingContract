import { expect } from "chai";
import { utils } from "ethers";
import { ethers } from "hardhat";
import { BoaredApe } from "../typechain";


describe("BRT TOKEN", function () {
  let  boredApeContract: BoaredApe;
  beforeEach(async() => {
    const BoaredApe = await ethers.getContractFactory("BoaredApe");
    const boredApe = await BoaredApe.deploy("Bored Ape", "BRT");
    boredApeContract = await boredApe.deployed();
  })

  it("should allow should allocate correct total supply to deployer", async function () {
    

    const [signer1, signer2, signer3] = await ethers.getSigners();

    let ownerBal = await boredApeContract.balanceOf(signer1.address);

    let parsedBal = ethers.utils.formatEther(ownerBal);

    expect(parsedBal).to.equal("1000000.0")

  });

  it("should revert due to insufficient allowance", async () => {
    const [signer1, signer2, signer3] = await ethers.getSigners();
    expect(boredApeContract.stakeBRT(100)).to.be.reverted;
  })



  it("user stake balance should be correct after stake", async () => {
    const [signer1, signer2, signer3] = await ethers.getSigners();
    // const aproveTx = await boredApeContract.approve(boredApeContract.address, ethers.utils.parseEther("100"));
    // await  aproveTx.wait()
    const amt = ethers.utils.parseEther("100")
    const stakeTx = await boredApeContract.stakeBRT(amt);
    await stakeTx.wait()
    let stake = await boredApeContract.myStake();

    expect(stake.stakeAmount).to.equal(amt);
  })


  it("should handle multiple stake correctly", async () => {
    const [signer1, signer2, signer3] = await ethers.getSigners();
    const amt = ethers.utils.parseEther("100")
    const amt2 = ethers.utils.parseEther("200")
    const stake1Tx = await boredApeContract.stakeBRT(amt);
    await stake1Tx.wait()

    const stake2Tx = await boredApeContract.stakeBRT(amt2);
    await stake2Tx.wait()

    let stake = await boredApeContract.myStake();


    expect(stake.stakeAmount).to.equal(utils.parseEther("300"));
    expect(stake.valid).to.equal(true);
  })


  it("should set valid to to false after withdrawal of all stake", async () => {
    const [signer1, signer2, signer3] = await ethers.getSigners();
    const amt = ethers.utils.parseEther("100")
    const amt2 = ethers.utils.parseEther("200")
    const stake1Tx = await boredApeContract.stakeBRT(amt);
    await stake1Tx.wait()

    const stake2Tx = await boredApeContract.stakeBRT(amt2);
    await stake2Tx.wait()

    const total = ethers.utils.parseEther("300")
    const withdrawalTx = await boredApeContract.withdraw(total);
    await withdrawalTx.wait()

    let stake = await boredApeContract.myStake();


    expect(stake.stakeAmount).to.equal(utils.parseEther("0"));
    expect(stake.valid).to.equal(false);
  })


});
