//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IBRT {
    function balanceOf(address owner) external view returns (uint256 balance);
}
