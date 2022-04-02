//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IW3B.sol";
import "hardhat/console.sol";

contract W3BToken is ERC20 {
    IW3B constant W3B = IW3B(0x524108C1261dc8CA5A6AE5E188CA020220d87D75);

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        _mint(msg.sender, 1000000 * 10**18);
    }

    struct Stake {
        uint256 time;
        bool valid;
        uint256 stakeAmount;
        address owner;
    }
    mapping(address => Stake) public stake;
    event StateChange(address from, uint256 _mount, uint256 time);

    function stakeBRT(uint256 amount) public returns (uint256 interest) {
        Stake storage s = stake[msg.sender];
        require(W3B.balanceOf(msg.sender) >= 1, "not a w3bNFT holder");
        transfer(address(this), amount);
        if (s.valid == true) {
            uint256 secondsSpent = block.timestamp - s.time;
            if (secondsSpent >= 259200) {
                interest = (s.stakeAmount * 386 * secondsSpent) / 1000000000;
                s.stakeAmount += interest + amount;
            } else {
                s.stakeAmount += amount;
            }
        } else {
            s.stakeAmount += amount;
            s.owner = msg.sender;
            s.valid = true;
        }

        s.time = block.timestamp;
        emit StateChange(msg.sender, amount, block.timestamp);
    }

    function withdrawBRT(uint256 amount) public {
        Stake storage s = stake[msg.sender];

        require(s.valid == true, "you dont have money in the stake");
        uint256 secondsSpent = block.timestamp - s.time;
        if (secondsSpent >= 259200) {
            uint256 interest = (s.stakeAmount * 386 * secondsSpent) /
                1000000000;
            s.stakeAmount += interest;
        }
        require(s.stakeAmount >= amount, "insufficient funds");
        s.stakeAmount -= amount;
        _transfer(address(this), msg.sender, amount);
        s.time = block.timestamp;
        s.stakeAmount == 0 ? s.valid = false : s.valid = true;
        emit StateChange(msg.sender, amount, block.timestamp);
    }

    function myStake() external view returns (Stake memory) {
        return stake[msg.sender];
    }

    function calcReward()
        public
        view
        returns (uint256 reward, uint256 secondsSpent)
    {
        Stake storage s = stake[msg.sender];
        require(s.valid == true, "you dont have money in the stake");
        secondsSpent = block.timestamp - s.time;
        reward = (s.stakeAmount * 386 * secondsSpent) / 1000000000;
    }
}
