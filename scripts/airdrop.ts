import { ethers } from "hardhat";

async function main() {
    const deployer = await ethers.getSigners();

    const ContractFactory = await ethers.getContractFactory("Airdrop");
    const contract = await ContractFactory.deploy();
    const AirdropFactory = await ethers.getContractFactory("SelfToken");
    const airdropContract = await AirdropFactory.deploy("Airdrop", "AIR1");

    await airdropContract.deployed();
    await contract.deployed();

    await airdropContract.mint(1000);

    await airdropContract.approve(contract.address, ethers.utils.parseEther("1000"));

    await contract.setToken(1, airdropContract.address);

    console.log("YourContractName deployed to:", contract.address, airdropContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
