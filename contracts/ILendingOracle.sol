// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

abstract contract ILendingOracle {

    /**
    * @dev is a 
    * @return ret - a bytes representation of the string "is a lending oracle"  
    */
    function isLendingOracle() external virtual returns (bytes memory ret){
        return bytes(string("is a lending oracle"));
    }

}
