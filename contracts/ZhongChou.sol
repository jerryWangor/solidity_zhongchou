// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract ZhongChou {

    // 合约创建人
    address owner;

    struct Needer {
        // 受益人地址
        address neederAddress;
        // 受益人目标筹款金额
        uint goal;
        // 账户金额（已经筹集的）
        uint amount;
        // 捐款人个数
        uint funderCount;
        // 捐款人地址与捐款人详细信息映射
        mapping(address => Funder) funderMap;
        // 是否存在
        bool isExists;
    }

    struct Funder {
        // 是否存在
        bool isExists;
        // 捐款人账户地址
        address funderAddress;
        // 捐款金额
        uint funderMoney;
        // 捐款人其他的一些信息
    }

    uint neederId;
    mapping(uint => Needer) neederMap;

    // 构造函数
    constructor() {
        owner = msg.sender;
    }

    /**
     * 这里理论上只能合约创始人才能创建众筹
     * 会返回一个众筹ID，捐款的时候传哪个ID就给哪个人捐
     */
    function CreateNeeder(address _addr, uint _goal) public returns(uint, uint, bool, address) {
        require(msg.sender == owner, "not solidity creator");
        neederId++;
        neederMap[neederId].neederAddress = _addr;
        neederMap[neederId].goal = _goal;
        neederMap[neederId].isExists = true;

        return (neederId, neederMap[neederId].goal, neederMap[neederId].isExists, neederMap[neederId].neederAddress);
    }

    /**
     * 捐献money
     */
    function Contribute(uint _neederId) public payable {
        // 判断有没有这个众筹数据
        require(neederMap[_neederId].isExists, "needer not exists");
        neederMap[neederId].amount += msg.value;

        // 判断这个是之前是否捐献过了
        if(!neederMap[neederId].funderMap[msg.sender].isExists) {
            neederMap[neederId].funderMap[msg.sender].isExists = true;
            neederMap[neederId].funderMap[msg.sender].funderAddress = address(msg.sender);
            neederMap[neederId].funderMap[msg.sender].funderMoney = msg.value;
        } else {
            neederMap[neederId].funderMap[msg.sender].funderMoney += msg.value;
        }
    }

    // 把某个众筹项目下的全部钱转移给某个人，必须是合约创建人才能操作
    function TransferNeederAmount(uint _neederId) public payable {
        require(msg.sender == owner, "not solidity creator");
        require(neederMap[_neederId].isExists, "needer not exists");
        // 判断是否大于等于目标筹款金额，筹集够了就直接打款到受益人地址
        if(neederMap[neederId].amount >= neederMap[neederId].goal) {
            payable(neederMap[neederId].neederAddress).transfer(neederMap[neederId].amount);
        } else {
            revert("money not enough");
        }
    }

    // 获取某个众筹项目下的众筹总金额，当前筹集到的金额
    function GetNeederContent(uint _neederId) public view returns(uint, uint) {
        require(neederMap[_neederId].isExists, "needer not exists");
        return (neederMap[neederId].goal, neederMap[neederId].amount);
    }

    
}