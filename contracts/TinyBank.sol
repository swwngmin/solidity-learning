// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ManagedAccess.sol";

interface IMyToken {
    function transfer(uint256 amount, address to) external;
    function transferFrom(address from, address to, uint256 amount) external;
}

contract TinyBank is ManagedAccess {
    event Staked(address, uint256);
    event Withdraw(uint256 amount, address to);

    IMyToken public stakingToken;
    mapping(address => uint256) public staked;
    uint256 public totalStaked;
    uint256 public rewardPerBlock;

    constructor(IMyToken _stakingToken, address[] memory _managers)
        ManagedAccess(msg.sender, msg.sender)
    {
        require(_managers.length >= 3, "Need at least 3 managers");
        stakingToken = _stakingToken;

        for (uint256 i = 0; i < _managers.length; i++) {
            _addManager(_managers[i]);
        }
    }

    function distributeReward() internal {
        // dummy function
    }

    function setRewardPerBlock(uint256 _amount) external onlyAllConfirmed {
        rewardPerBlock = _amount;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be bigger than zero");

        distributeReward();

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staked[msg.sender] += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(staked[msg.sender] >= _amount, "Insufficient staked token");

        distributeReward();

        stakingToken.transfer(_amount, msg.sender);
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;

        emit Withdraw(_amount, msg.sender);
    }
}