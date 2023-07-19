import { ethers } from "hardhat";

async function main() {
    const deployer = await ethers.getSigners();
    const ContractFactory = await ethers.getContractFactory("Governance");
    const ContractTimelock = await ethers.getContractFactory("Timelock");
    const contract = await ContractFactory.deploy("0xBb2Cb9aa911bE2aDB977D97Ba4f9Ac9526E7364a");
    const timelockcontract = await ContractTimelock.deploy(30, contract.address);

    await contract.deployed();
    await timelockcontract.deployed();

    const timelockaddress = timelockcontract.address;
    await contract.setTokenAddress("0x7452193F39949F59212D6CC808774b3d97D0bd2A");
    await contract.setTimelockAddress(timelockaddress);
    await contract.setFactoryAddress("0x94bD30e9fcBae16119B44D6024883d3a0f3C45Ad");

    console.log("YourContractName deployed to:", contract.address, timelockaddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
