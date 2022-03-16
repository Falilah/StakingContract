import { messagePrefix } from "@ethersproject/hash";
import { Signer } from "ethers";
import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy

  const owner = "0x27E936b199a8EEb3980c468fc1802f1Ef78b1625";
  const boredaper = "0xcee749f1cfc66cd3fb57cefde8a9c5999fbe7b8f";

  await ethers.getSigners;

  //@ts-ignore
  await network.provider.send("hardhat_setBalance", [
    owner,
    "0x100000000000000000000",
  ]);

  //@ts-ignore
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [boredaper],
  });

  const border: Signer = await ethers.getSigner(boredaper);

  const staking = await ethers.getContractFactory("BoaredApe");
  const deployStaking = await staking.deploy("BoredApe", "BRT");

  await deployStaking.deployed();
  console.log("staking address", deployStaking.address);

  const transfer_ = await deployStaking.transfer(boredaper, "1000000000000");
  console.log(transfer_);
  const stake = await deployStaking.connect(border).stakeBRT("1000000000000");

  console.log(stake);
  const bal = await deployStaking.balanceOf(boredaper);
  const contractbal = await deployStaking.balanceOf(deployStaking.address);
  const ownerbal = await deployStaking.balanceOf(owner);
  console.log(bal, contractbal, ownerbal);

  console.log(minter);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
