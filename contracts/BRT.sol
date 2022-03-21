//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IBored.sol";

contract BoaredApe is ERC20 {
    address private bored = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
    IBRT private ape = IBRT(bored);

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {
        _mint(msg.sender, 1000000 * 10**18);
    }

    //0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
    struct Stakers {
        uint256 time;
        address owner;
        uint256 stakeAmount;
        bool valid;
    }
    mapping(address => Stakers) public stakers;
    event StateChange(address from, address to, uint256 _mount);

    function stakeBRT(uint256 amount) public {
        Stakers storage s = stakers[msg.sender];
        require(_balances[msg.sender] >= amount, "insufficien t");
        require(ape.balanceOf(msg.sender) >= 1, "not a boredape holder");

        if (s.valid == true) {
            uint256 daySpent = block.timestamp - s.time;
            uint256 token = s.stakeAmount;
            _balances[msg.sender] -= amount;

            if (daySpent >= 3 days) {
                uint256 interest = ((token * (daySpent / 86400)) / 300);
                uint256 total = token + interest + amount;
                s.stakeAmount = total;
            } else {
                s.stakeAmount += amount;
            }
        } else {
            _balances[msg.sender] -= amount;
            s.stakeAmount = amount;
            s.owner = msg.sender;
            s.valid = true;
        }
        _balances[address(this)] += amount;
        s.time = block.timestamp;
        emit StateChange(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        Stakers storage s = stakers[msg.sender];

        require(msg.sender == s.owner, "Not owner");
        require(s.valid == true, "you dont have money in the stake");
        uint256 daySpent = block.timestamp - s.time;
        if (daySpent >= 3 days) {
            uint256 token = s.stakeAmount;
            uint256 interest = ((token * (daySpent / 86400)) / 300);
            s.stakeAmount += interest;
        }
        require(s.stakeAmount >= amount, "insufficient funds");
        s.stakeAmount -= amount;
        _balances[address(this)] -= amount;
        _balances[msg.sender] += amount;
        s.time = block.timestamp;
        s.stakeAmount == 0 ? s.valid = false : s.valid = true;
        emit StateChange(address(this), msg.sender, amount);
    }
}
