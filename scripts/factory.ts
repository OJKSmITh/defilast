import { ethers } from "hardhat";
import dotenv from "dotenv";
dotenv.config();

const deployAddress = process.env.DEPLOY_ADDRESS
const sdeployAddress = process.env.SDEPLOY_ADDRESS
const ethDeployAddress = process.env.ETHTOKEN_ADDRESS
async function main() {
  const deployer = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer);

  const ContractFactory = await ethers.getContractFactory("Factory_v1");
  const contract = await ContractFactory.deploy(deployAddress as string, sdeployAddress as string ,ethDeployAddress as string);

  await contract.deployed();

  console.log("YourContractName deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });