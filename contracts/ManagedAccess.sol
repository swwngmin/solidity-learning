// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract ManagedAccess {
    // --- Single owner/manager (MyToken용) ---
    address public owner;
    address public manager;

    constructor(address _owner, address _manager) {
        owner = _owner;
        manager = _manager;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized");
        _;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "You are not manageble this token"
        );
        _;
    }

    // ----------------------------------------
    // --- Multi-manager (TinyBank용) ---
    address[] public managers;
    mapping(address => bool) public isManager;
    mapping(address => bool) public confirmed;
    uint256 public confirmCount;

    // TinyBank constructor에서 manager 추가 시 사용
    function _addManager(address _manager) internal {
        require(_manager != address(0), "Invalid manager address");
        require(!isManager[_manager], "Duplicate manager");

        managers.push(_manager);
        isManager[_manager] = true;
    }

    // 각 manager가 개별적으로 confirm 호출
    function confirmAction() external {
        require(isManager[msg.sender], "You are not a manager");
        require(!confirmed[msg.sender], "Already confirmed");

        confirmed[msg.sender] = true;
        confirmCount++;
    }

    // 실행 후 confirm 상태 전체 초기화
    function _resetConfirmations() internal {
        for (uint256 i = 0; i < managers.length; i++) {
            confirmed[managers[i]] = false;
        }
        confirmCount = 0;
    }

    modifier onlyAllConfirmed() {
        require(isManager[msg.sender], "You are not a manager");
        require(confirmCount == managers.length, "Not all confirmed yet");
        _;
        _resetConfirmations();
    }
}