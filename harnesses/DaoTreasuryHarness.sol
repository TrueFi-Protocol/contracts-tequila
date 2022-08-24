// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../DaoTreasury.sol";

contract DaoTreasuryHarness is DaoTreasury {
    function getEtherBalance(address account) public view returns (uint256) {
        return account.balance;
    }
}
