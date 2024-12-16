// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Governancetoken is ERC20 {
    address public admin;
    event Mint(address indexed to, uint256 amount);
    uint256 immutable tokensperether = 1;

    constructor() ERC20("Insuraceapprovaltoken", "IAT") {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(
            admin == msg.sender,
            "Admin is not the user so cannot mint newtoken"
        );
        _;
    }

    function mint(address to, uint256 contribution) public onlyAdmin {
       uint256 tokenstomint = contribution * tokensperether;
       _mint(to,tokenstomint);
       emit Mint(to,tokenstomint);
    }
}
