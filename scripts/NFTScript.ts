import { ethers } from "hardhat";

async function main() {
  const NFTawait = await ethers.getContractFactory("NFT");
  const NFTToken = await NFTawait.deploy();

  await NFTToken.deployed();
  await NFTToken.createNFT(
    "https://ipfs.io/ipfs/QmY4kfpZskzVaHa7Wxhu8kmgR4jYxCPTyku2JVHCHyn9iK"
  );

  // await NFTToken.tokenURI(1);
  console.log("NFT deployed to:", NFTToken.address);

  console.log("Sleeping.....");
  // Wait for etherscan to notice that the contract has been deployed
  await sleep(100000);
  // Verify the contract after deploying
  //@ts-ignore

  await hre.run("verify:verify", {
    address: NFTToken.address,
    constructorArguments: [],
  });
}
function sleep(ms: any) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
