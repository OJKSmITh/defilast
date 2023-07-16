//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfToken.sol";
import "./timelock.sol";
import "./Factory_v1.sol";

contract Governance {
    address private owner;
    address private govToken;
    uint256 private proposalAmount;
    address private goverAddress;
    address private timelock;
    address private factory;

    event ExecuteResult(bool success, string message);

    struct Receipt {
        bool vote;
        bool agree;
    }

    struct Proposal {
        address proposer;
        uint startBlock;
        uint endBlock;
        bytes callFunction; // ex) createPool_ETH, changeLevel_ETH
        bool canceled;
        bool executed;
        uint256 amountVote;
        mapping(address => Receipt) hasVotes;
    }

    struct returnValue {
        bool success;
        string messege;
    }

    address[] public participants;

    mapping(uint => Proposal) private proposes;
    mapping(uint => address[]) private votes;

    constructor(address _owner) {
        owner = _owner;
        goverAddress = address(this);
    }

    function propose(address _proposer, string memory _callFunction) public {
        require(
            SelfToken(govToken).balanceOf(_proposer) > 0,
            "Governance : Do not have a vASD token."
        );

        uint startBlock = block.number;
        uint endBlock = block.number + 17280;
        Proposal storage newProposal = proposes[proposalAmount + 1];
        newProposal.proposer = _proposer;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.callFunction = bytes(_callFunction);
        newProposal.canceled = false;
        newProposal.executed = false;
        newProposal.amountVote = 0;
        // newProposal.hasVotes[_proposer] = Receipt(true, true);
        proposalAmount += 1;

        SelfToken(govToken)._burn(_proposer, 1); // burn 시킬 govtoken의 가치에 대해서 ?
    }

    function voting(address _participant, uint _proposal, bool _agree) public {
        require(
            SelfToken(govToken).balanceOf(_participant) > 0,
            "Governance : Do not have a vASD token."
        );
        require(
            proposes[_proposal].hasVotes[_participant].vote == false,
            "Governance : It is a proposal that has already been voted on."
        );
        // require(proposes[_proposal].endBlock > block.number, "Governance : It's an overdue vote.");
        proposes[_proposal].hasVotes[_participant] = Receipt(true, _agree);
        votes[_proposal].push(_participant);
        proposes[_proposal].amountVote +=
            (uint256(SelfToken(govToken).balanceOf(_participant) * 10 ** 18) *
                100) /
            SelfToken(govToken).totalSupply();
    }

    function timelockExecute(uint _proposal) public returns (bool) {
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days."); //3일 > 17,280
        if (proposes[_proposal].amountVote >= 51 * 10 ** 18) {
            proposes[_proposal].executed = true;
            Timelock(timelock).queueTransaction(
                proposes[_proposal].callFunction,
                block.timestamp
            );
            emit ExecuteResult(true, "success");
        } else {
            proposes[_proposal].canceled = true;
            emit ExecuteResult(
                false,
                "Governance : It's a vote that didn't pass."
            );
        }
    }

    function proposalExecute(uint _proposal) public {
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days.");
        if (proposes[_proposal].executed == true) {
            if (
                Timelock(timelock).executeTransaction(
                    proposes[_proposal].callFunction,
                    block.timestamp
                ) == true
            ) {
                if (
                    Timelock(timelock)
                        .getTransaction(proposes[_proposal].callFunction)
                        .status == false
                ) {
                    emit ExecuteResult(
                        false,
                        "Governance : Timelock status false."
                    );
                } else {
                    emit ExecuteResult(true, "success");
                }
            } else
                emit ExecuteResult(false, "Governance : Timelock is running.");
        } else
            emit ExecuteResult(
                false,
                "Governance : It's a vote that didn't pass."
            );

        //실행
    }

    function changeLevel(
        address _token,
        uint256 _level,
        uint256 _proposal
    ) public {
        // timeLock queue, time 비교
        // require(Timelock(timelock).getTransaction(bytes("changeLevel")).status);
        require(isStatus(proposes[_proposal].callFunction));
        require(!isClose(proposes[_proposal].callFunction), "Is Closed");
        Factory_v1(factory).poolLvup(_token, _level);
        Timelock(timelock).closePropose(proposes[_proposal].callFunction);
        emit ExecuteResult(true, "success");
        //factory 로 보내서 levelchange 시키는것, 의제에 의해서 실행될것.
        //factory 에 보내야할것 > ca랑 level 입력해서 보내주기 > callData
    }

    function createPool(
        address _differentToken,
        address _AsdToken,
        uint256 _proposal
    ) public returns (bool) {
        // require(Timelock(timelock).getTransaction(bytes("createPool")).status);
        // timeLock queue, time 비교
        require(isStatus(proposes[_proposal].callFunction));
        require(!isClose(proposes[_proposal].callFunction), "Is Closed");
        Factory_v1(factory).createPool(_differentToken, _AsdToken);
        Timelock(timelock).closePropose(proposes[_proposal].callFunction);
        return true;
    }

    function isStatus(bytes memory funcName) public view returns (bool) {
        return Timelock(timelock).getTransaction(funcName).status;
    }

    function isClose(bytes memory funcName) public view returns (bool) {
        return Timelock(timelock).getTransaction(funcName).close;
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

    function setFactoryAddress(address _factory) public {
        require(owner == msg.sender);
        factory = _factory;
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
            proposal.callFunction,
            proposal.canceled,
            proposal.executed,
            proposal.amountVote
        );
    }

    function getCallFunction(
        uint _proposal
    ) public view returns (bytes memory) {
        return proposes[_proposal].callFunction;
    }

    function getHasVote(uint _proposal) public view returns (bool) {
        return proposes[_proposal].hasVotes[msg.sender].vote;
    }

    function checkedToken(address proposal) public view returns (uint256) {
        return SelfToken(govToken).balanceOf(proposal);
    }

    function getTokenAddress() public view returns (address) {
        return govToken;
    }
}
