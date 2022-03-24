//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IBored.sol";
import "hardhat/console.sol";

contract BoaredApe is ERC20 {
    address private bored = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    IBRT private ape = IBRT(bored);

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        _mint(msg.sender, 1000000 * 10**18);
    }

    //0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
    struct Stake {
        uint256 time;
        address owner;
        uint256 stakeAmount;
        bool valid;
    }
    mapping(address => Stake) public stake;
    event StateChange(address from, uint256 _mount, uint256 time);

    function stakeBRT(uint256 amount) public returns (uint256 interest) {
        Stake storage s = stake[msg.sender];
        require(ape.balanceOf(msg.sender) >= 1, "not a boredape holder");
        transfer(address(this), amount);
        if (s.valid == true) {
            uint256 daySpent = block.timestamp - s.time;
            if (daySpent >= 3 days) {
                interest = ((s.stakeAmount * (daySpent / 86400)) / 300);
                s.stakeAmount += interest + amount;
            } else {
                s.stakeAmount += amount;
            }
        } else {

            s.stakeAmount += amount;
            s.staker = msg.sender;
            s.valid = true;
        }
        

        s.time = block.timestamp;
        emit StateChange(msg.sender, amount, block.timestamp);
    }

    function myStake() external view returns (Stake memory) {
        return stakes[msg.sender];
    }

    function getStakeByAddress(address staker) external view returns (Stake memory) {
        return stakes[staker];
    }



    function withdraw(uint256 amount) public {
        Stake storage s = stake[msg.sender];
        require(s.valid == true, "you dont have money in the stake");
        uint256 daySpent = block.timestamp - s.time;
        if (daySpent >= 3 days) {
            uint256 interest = ((s.stakeAmount * (daySpent / 86400)) / 300);
            s.stakeAmount += interest;
        }
        require(s.stakeAmount >= amount, "insufficient funds");
        s.stakeAmount -= amount;
        transfer(msg.sender, amount);
        s.time = block.timestamp;
        s.stakeAmount == 0 ? s.valid = false : s.valid = true;
        emit StateChange(msg.sender, amount, block.timestamp);
    }

    function calcReward()
        public
        view
        returns (uint256 reward, uint256 daySpent)
    {
        Stake storage s = stake[msg.sender];
        require(s.valid == true, "you dont have money in the stake");
        daySpent = block.timestamp - s.time;
        reward = ((s.stakeAmount * (daySpent / 86400)) / 300);
    }

    }
