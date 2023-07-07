import { ethers } from "hardhat";

async function main() {
  const deployer = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer);

  const ContractFactory = await ethers.getContractFactory("SelfToken");
  const contract = await ContractFactory.deploy("ASD","ASD");

  await contract.deployed();

  console.log("YourContractName deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });