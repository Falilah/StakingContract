import { ethers } from "hardhat";

async function verify() {
  const staking = await ethers.getContractFactory("W3BToken");
  const deployStaking = await staking.deploy("Web3Bridge", "W3B");

  await deployStaking.deployed();
  console.log("staking address", deployStaking.address);
  console.log("Sleeping.....");
  // Wait for etherscan to notice that the contract has been deployed
  await sleep(100000);

  // Verify the contract after deploying
  //@ts-ignore
  await hre.run("verify:verify", {
    address: deployStaking.address,
    constructorArguments: ["Web3Bridge", "W3B"],
  });
}
function sleep(ms: any) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
verify().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
