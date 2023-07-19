import { ethers } from "hardhat";
import dotenv from "dotenv";
import { token } from "../typechain-types/@openzeppelin/contracts";
dotenv.config();

async function main() {
    const deployer = await ethers.getSigners();
    const DeployContractFactory = await ethers.getContractFactory("Deploy");
    const Deploycontract = await DeployContractFactory.deploy(3);
    await Deploycontract.deployed();

    const SdeployContractFactory = await ethers.getContractFactory("Sdeploy");
    const Sdeploycontract = await SdeployContractFactory.deploy();
    await Sdeploycontract.deployed();

    const SelfTokenContractFactory = await ethers.getContractFactory("SelfToken");
    const ASDcontract = await SelfTokenContractFactory.deploy("ASD", "ASD");
    const ETHcontract = await SelfTokenContractFactory.deploy("ETH", "ETH");
    const ARBcontract = await SelfTokenContractFactory.deploy("ARB", "ARB");
    const USDTcontract = await SelfTokenContractFactory.deploy("USDT", "USDT");
    await ASDcontract.deployed();
    await ETHcontract.deployed();
    await ARBcontract.deployed();
    await USDTcontract.deployed();

    const FactoryContractFactory = await ethers.getContractFactory("Factory_v1");
    const Factorycontract = await FactoryContractFactory.deploy(Deploycontract.address, Sdeploycontract.address, ETHcontract.address);

    await Factorycontract.deployed();

    await Factorycontract.createPool(ETHcontract.address, ASDcontract.address);
    await Factorycontract.createPool(ARBcontract.address, ASDcontract.address);
    await Factorycontract.createPool(USDTcontract.address, ASDcontract.address);

    const [ArbLpaddress, UsdtLpaddress, EthLpaddress] = await Factorycontract.checkPool();
    const vASDaddress = await Sdeploycontract.tokenAddress();

    await ASDcontract.mint(300000);
    await ETHcontract.mint(200);
    await ARBcontract.mint(300000);
    await USDTcontract.mint(300000);

    await ETHcontract.transferFrom(ETHcontract.address, "0xECC5F150a1bE04792137e24C4bb1C7bBB855b72a", ethers.utils.parseEther("20"));

    await ASDcontract.transferFrom(ASDcontract.address, Factorycontract.address, ethers.utils.parseEther("100000"));
    await ARBcontract.transferFrom(ARBcontract.address, Factorycontract.address, ethers.utils.parseEther("100000"));
    await USDTcontract.transferFrom(USDTcontract.address, Factorycontract.address, ethers.utils.parseEther("100000"));
    await ETHcontract.transferFrom(ETHcontract.address, Factorycontract.address, ethers.utils.parseEther("50"));

    await ETHcontract.transferFrom(ETHcontract.address, "0xBb2Cb9aa911bE2aDB977D97Ba4f9Ac9526E7364a", ethers.utils.parseEther("20"));

    await ETHcontract.transferFrom(ETHcontract.address, "0xa8eaef888a4e3abf6efbbc92029bbc09221434b8", ethers.utils.parseEther("20"));

    console.log(
        "NEXT_PUBLIC_DEPLOY_ADDRESS:",
        Deploycontract.address,
        "NEXT_PUBLIC_SDEPLOY_ADDRESS:",
        Sdeploycontract.address,
        "NEXT_PUBLIC_ETHTOKEN_ADDRESS:",
        ETHcontract.address,
        "NEXT_PUBLIC_ASDTOKEN_ADDRESS:",
        ASDcontract.address,
        "NEXT_PUBLIC_ARBTTOKEN_ADDRESS:",
        ARBcontract.address,
        "NEXT_PUBLIC_USDTTOKEN_ADDRESS:",
        USDTcontract.address,
        "NEXT_PUBLIC_FACTORY_ADDRESS:",
        Factorycontract.address,
        "NEXT_PUBLIC_ARBLP_ADDRESS:",
        ArbLpaddress,
        "NEXT_PUBLIC_USDTLP_ADDRESS:",
        UsdtLpaddress,
        "NEXT_PUBLIC_ETHLP_ADDRESS:",
        EthLpaddress,
        "NEXT_PUBLIC_VASDTOKEN_ADDRESS",
        vASDaddress
    );
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
