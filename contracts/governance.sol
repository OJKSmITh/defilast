//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfToken.sol";
import "./timelock.sol";
import "./Factory.sol";

contract Governance {
    address private owner;
    address private govToken;
    uint256 private proposalAmount;
    address private goverAddress;
    address private timelock;
    address private factory;

    struct Receipt {
        bool vote;
        bool agree;
    }

    struct Proposal {
        address proposer;
        uint startBlock;
        uint endBlock;
        bytes callData;
        bool canceled;
        bool executed;
        uint256 amountVote;
        mapping(address => Receipt) hasVotes;
    }

    address[] public participants;

    mapping(uint => Proposal) private proposes;
    mapping(uint => address[]) private votes;

    constructor(address _owner) {
        owner = _owner;
        goverAddress = address(this);
    }

    function propose(address _proposer, bytes memory _callData) public {
        require(SelfToken(govToken).balanceOf(_proposer) > 0, "Governance : Do not have a vASD token.");

        uint startBlock = block.number;
        uint endBlock = block.number + 17280;
        Proposal storage newProposal = proposes[proposalAmount + 1];
        newProposal.proposer = _proposer;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.callData = _callData;
        newProposal.canceled = false;
        newProposal.executed = false;
        newProposal.amountVote = 0;
        newProposal.hasVotes[_proposer] = Receipt(true, true);
        proposalAmount += 1;

        SelfToken(govToken)._burn(_proposer, 1); // burn 시킬 govtoken의 가치에 대해서 ?
    }

    function voting(address _participant, uint _proposal, bool _agree) public {
        require(SelfToken(govToken).balanceOf(_participant) > 0, "Governance : Do not have a vASD token.");
        require(proposes[_proposal].hasVotes[_participant].vote == false, "Governance : It is a proposal that has already been voted on.");
        // require(proposes[_proposal].endBlock > block.number, "Governance : It's an overdue vote.");
        proposes[_proposal].hasVotes[_participant] = Receipt(true, _agree);
        votes[_proposal].push(_participant);
        proposes[_proposal].amountVote +=
            uint256(SelfToken(govToken).balanceOf(_participant) * 10 ** 18) /
            SelfToken(govToken).totalSupply();
    }

    function timelockExecute(uint _proposal) public returns (bool) {
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days."); //3일 > 17,280
        if (proposes[_proposal].amountVote > 0.51 * 10 ** 18) {
            proposes[_proposal].executed = true;

            if (proposes[_proposal].callData.length % 2 != 0) {

            bytes memory paddedCallData = abi.encodePacked(proposes[_proposal].callData);
            proposes[_proposal].callData = paddedCallData;
            Timelock(timelock).queueTransaction(paddedCallData, block.timestamp);
            return true;
            } else {
            Timelock(timelock).queueTransaction(proposes[_proposal].callData, block.timestamp);
            return true;
            }
        } else {
            proposes[_proposal].canceled = true;
            return false;
        }
        //작동 안됨. < 수정 후 반영
        /*
                    if (proposes[_proposal].callData.length % 2 != 0) {
            bytes memory paddedCallData = new bytes(proposes[_proposal].callData.length + 1);
            proposes[_proposal].callData = paddedCallData;
            paddedCallData[0] = 0;
            for (uint256 i = 0; i < proposes[_proposal].callData.length; i++) {
            paddedCallData[i + 1] = proposes[_proposal].callData[i];
            }
            Timelock(timelock).queueTransaction(paddedCallData, block.timestamp);
            return true;
            } else {
            Timelock(timelock).queueTransaction(proposes[_proposal].callData, block.timestamp);
            return true;
            }
        */
    }
    
    function proposalExecute(uint _proposal) public returns(bool){
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days.");
        require(proposes[_proposal].executed, "Governance : It's a vote that didn't pass.");
        require(Timelock(timelock).executeTransaction(proposes[_proposal].callData, block.timestamp), "Governance : Timelock is running.");
        require(Timelock(timelock).getTransaction(proposes[_proposal].callData).status);
        //proposes.callData 실행시켜야함
        return true;
    }

    function changeLevel(address token) public {
        //factory 로 보내서 levelchange 시키는것, 의제에 의해서 실행될것.
        //factory 에 보내야할것 > ca랑 level 입력해서 보내주기 > callData
    }

    function changeOwner(address _newOwner) private {
        owner = _newOwner;
    }

    function setTokenAddress(address _token) public {
        require(owner == msg.sender);
        govToken = _token;
    }

    function setTimelockAddress(address _timelock) public {
        require(owner == msg.sender);
        timelock = _timelock;
    }

    function getProposal(
        uint _idx
    )
        public
        view
        returns (address, uint, uint, bytes memory, bool, bool, uint)
    {
        Proposal storage proposal = proposes[_idx];
        return (
            proposal.proposer,
            proposal.startBlock,
            proposal.endBlock,
            proposal.callData,
            proposal.canceled,
            proposal.executed,
            proposal.amountVote
        );
    }

    function getCallData(uint _proposal)public view returns (bytes memory){
        return proposes[_proposal].callData;
    }
}
