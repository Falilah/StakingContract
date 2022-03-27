//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IBored.sol";
import "hardhat/console.sol";

contract BoaredApe is ERC20 {
    IBRT constant ape = IBRT(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);

    uint256 constant INTERESTPERSECONDS = (86400 * 300);

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
        // require(ape.balanceOf(msg.sender) >= 1, "not a boredape holder");
        transfer(address(this), amount);
        if (s.valid == true) {
            uint256 secondsSpent = block.timestamp - s.time;
            if (secondsSpent >= 259200) {
                interest = (secondsSpent / INTERESTPERSECONDS) * s.stakeAmount;
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
            uint256 interest = (secondsSpent / INTERESTPERSECONDS) *
                s.stakeAmount;
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
        reward = (secondsSpent / INTERESTPERSECONDS) * s.stakeAmount;
    }
}
