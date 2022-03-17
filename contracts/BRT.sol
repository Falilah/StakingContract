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
        mapping(address => uint256) stakers;
        bool valid;
    }
    mapping(uint256 => Stakers) public stakers;
    uint256 private id = 1;

    function stakeBRT(uint256 amount) public {
        Stakers storage s = stakers[id];
        require(_balances[msg.sender] >= amount, "insufficient");
        require(ape.balanceOf(msg.sender) >= 1, "not a boredape holder");
        _balances[msg.sender] -= amount;
        s.stakers[msg.sender] += amount;
        s.owner = msg.sender;
        s.time = block.timestamp;
        s.valid = true;
        id++;
    }

    function withdraw(uint256 _id, uint256 amount)
        public
        returns (uint256 total)
    {
        Stakers storage s = stakers[_id];

        require(msg.sender == s.owner, "Not owner");
        require(s.valid == true, "you dont have money in the stake");
        uint256 daySpent = block.timestamp - s.time;
        if (daySpent >= 3 days) {
            uint256 token = s.stakers[msg.sender];
            uint256 interest = ((token * (daySpent / 86400)) / 300);
            total = token + interest;
            s.stakers[msg.sender] = total;
        }

        s.stakers[msg.sender] -= amount;
        _balances[msg.sender] += amount;
        _balances[address(this)] -= amount;
        s.time = block.timestamp;
        s.stakers[msg.sender] == 0 ? false : true;
    }
    // uint256 interest = (token * (daySpent / 30 days) * 10000) / 100;
}
