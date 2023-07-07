import { ethers } from "hardhat";
import { Contract } from "@ethersproject/contracts";
import { expect } from "chai";

describe("Timelock", function () {
    let timelock: Contract;
    let admin: any;

    beforeEach(async function () {
        const [deployer] = await ethers.getSigners();
        admin = deployer;
        const Timelock = await ethers.getContractFactory("Timelock");
        timelock = await Timelock.deploy(172800, admin.address);
        await timelock.deployed();
    });

    it("should set a new delay", async function () {
        const newDelay = 259200;
        await timelock.setDelay(newDelay);
    });

    it("should queue a transaction", async function () {
        const callData = "0x12345678"; // Replace with your desired call data
        const blockTime = Math.floor(Date.now() / 1000) + 172800;
        await timelock.queueTransaction(callData, blockTime);
        const proposal = await timelock.getTransaction(callData);
        expect(proposal.status).to.equal(false);
        expect(proposal.blockTime).to.equal(blockTime);
    });

    it("should cancel a transaction", async function () {
        const callData = "0x12345678"; // Replace with the call data of the transaction you want to cancel
        await timelock.cancelTransaction(callData);
        const proposal = await timelock.getTransaction(callData);
        expect(proposal.canceled).to.equal(true);
    });

    it("should execute a transaction", async function () {
        const callData = "0x12345678"; // Replace with the call data of the transaction you want to execute
        const etc = Math.floor(Date.now() / 1000) + 259200;
        await timelock.executeTransaction(callData, etc);
        const proposal = await timelock.getTransaction(callData);
        expect(proposal.status).to.equal(true);
    });
});

