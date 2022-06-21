// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ILendingOracle.sol";
import "./IERC20Receiver.sol";

import "./libraries/BytesLib.sol";
import "hardhat/console.sol";


abstract contract RewardHandler is Context, IERC20Receiver{
    using BytesLib for bytes;
    uint feesBps = 100; //100 bps = 1 %

    mapping(address => mapping(address=> uint256)) rewardsForOwner;
    mapping(address => mapping(address=> uint256)) rewardsForRenter;

    /**
     * @dev see {IERC20Receiver-onERC20Received}
     */
    function onERC20Received(
        address,
        address,
        uint256 amount,
        bytes calldata data
    ) external override returns (bytes4){
        require(data.length > 0 , "RewardHandler: bytes.length must be more than 0");

        address cAddress = tx.origin;
        require(cAddress != address(0), "RewardHandler: contract address can't be zero address");

        if(_addRewards(cAddress,amount, data))
            return this.onERC20Received.selector;
        else
            return bytes4("");
    }

    /**
     * @dev will decrypt the calldata transferred
     * @param _cAddress - the contract address of the erc20Rewardable token
     * @param _amount - amount of erc20tokens received
     * @param data - other calldata being send along with the transfer
     * @return result - returns true if all the data was passed correctly. returns false otherwise
     * Note: The owner's winnings ratio must be on a scale of 100 i.e. if owner gets 30% of the winnings, his ratio is 30
     */
    function _addRewards(address _cAddress, uint _amount, bytes calldata data) internal returns (bool result)
    {
        // data: 0x --> 20bytes of ownerAddress --> 20 bytes of renterAddress ==> 64 bytes of ownerRatio (because uint64)

        address ownerAddress = data.toAddress(0); 
        address renterAddress = data.toAddress(20); 
        uint ownerRatio = data.toUint256(40);

        require(ownerAddress != address(0), "RewardHandler: the token renter can't be the zero address");
        require(renterAddress != address(0), "RewardHandler: the token renter can't be the zero address");

        uint ownerShare = (_amount*ownerRatio)/100;
        uint renterShare = _amount - ownerShare;

        _tallyRewards( _cAddress, ownerAddress, ownerShare);
        _tallyRewards( _cAddress, renterAddress, renterShare);

        return true;
    }

    /**
     * See {RewardHandler - _addRewards}
     */

    function _tallyRewards(address _cAddress, address _addr, uint _amount) internal
    {
        rewardsForOwner[_cAddress][_addr] += _amount;
    }


    /**
     * @dev Lets the msg sender to claim all his erc20 rewards which were accrued with the msg sender as an owner
     */

    function claimRewardsAsOwner(address _cAddress) public 
    {
        rewardsForOwner[_cAddress][_msgSender()] = 0;
        IERC20(_cAddress).transfer(
            _msgSender(),
            rewardsForOwner[_cAddress][_msgSender()]
        );
    } 

    /**
     * @dev Lets the msg sender to claim all his erc20 rewards which were accrued with the msg sender as a renter
     */
    function claimRewardsAsRenter(address _cAddress) public 
    {
        rewardsForRenter[_cAddress][_msgSender()] = 0;
        IERC20(_cAddress).transfer(
            _msgSender(),
            rewardsForRenter[_cAddress][_msgSender()]
        );
    } 

    /**
     * @dev Allows the msg.sedner to claim all accrued rewards as an owner AND a renter whatsoever
     */
    function claimAllRewards(address _cAddress) public 
    {
        claimRewardsAsOwner(_cAddress);
        claimRewardsAsRenter(_cAddress);
    } 

}



