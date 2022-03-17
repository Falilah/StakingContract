//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IBored.sol";

contract BoaredApe is ERC20 {
    address bored = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;
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
    event stateChange(address from, address to, uint256 a_mount);

    address[] public _Stakers;

    function stakeBRT(uint256 amount) public {
        Stakers storage s = stakers[msg.sender];
        require(_balances[msg.sender] >= amount, "insufficient");
        require(ape.balanceOf(msg.sender) >= 1, "not a boredape holder");
        address checkOwner;
        for (uint256 i; i < _Stakers.length; i++) {
            if (_Stakers[i] == msg.sender) checkOwner = _Stakers[i];
        }
        if (msg.sender == checkOwner) {
            uint256 daySpent = block.timestamp - s.time;
            uint256 token = s.stakeAmount;

            if (daySpent >= 3 days) {
                uint256 interest = ((token * (daySpent / 86400)) / 300);
                uint256 total = token + interest + amount;
                s.stakeAmount = total;
            } else {
                s.stakeAmount = token + amount;
            }
        } else {
            _balances[msg.sender] -= amount;
            s.stakeAmount = amount;
            s.owner = msg.sender;
            _Stakers.push(msg.sender);
        }
        s.time = block.timestamp;
        emit stateChange(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public returns (uint256 total) {
        Stakers storage s = stakers[msg.sender];

        require(msg.sender == s.owner, "Not owner");
        require(s.valid == true, "you dont have money in the stake");
        uint256 daySpent = block.timestamp - s.time;
        if (daySpent >= 3 days) {
            uint256 token = s.stakeAmount;
            uint256 interest = ((token * (daySpent / 86400)) / 300);
            total = token + interest;
            s.stakeAmount = total;
        }

        s.stakeAmount -= amount;
        _balances[msg.sender] += amount;
        _balances[address(this)] -= amount;
        s.time = block.timestamp;
        s.stakeAmount == 0 ? false : true;
    }
}
