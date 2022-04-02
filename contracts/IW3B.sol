//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IW3B {
    function balanceOf(address owner) external view returns (uint256 balance);
}
