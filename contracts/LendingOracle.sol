// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./libraries/BytesLib.sol";

contract LendingOracle is IERC721Receiver{
    using BytesLib for bytes;
    uint256 constant NULL = 0;

    struct LendingAgreement{
        address contractAddress;
        uint tokenId;
        address tokenLord;
        address tokenRenter;
        uint deadline;
    }

    mapping(address => mapping(uint=> LendingAgreement)) agreements;

    function isCurrentlyRented(address _contractAddress, uint _tokenId) public view returns(bool){
        return _isCurrentlyRented(_contractAddress, _tokenId);
    }

    function _isCurrentlyRented(address _contractAddress, uint _tokenId) internal view returns(bool){
        if(agreements[_contractAddress][_tokenId].deadline == NULL || agreements[_contractAddress][_tokenId].deadline < block.timestamp)
            return false;
        return true;
    }

    /*
        The function onERC721Received returns the function hash if the LendingOracle can accept the legal agreement
        @param operator - is the message sender (can either be the owner or the approved address when sent fron ERC721)
        @param from - the owner of the NFT, must be the same as the operator
        @param tokenId - the tokenId of the NFT that is being rented out
        @param data - encoded data. Must contain the following: 
            - address contractAddress;
            - address tokenRenter;
            - uint lendForBlocks
    */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data ) public override returns (bytes4) {
        if(_createLendingAgreement(from,tokenId, data))
            return this.onERC721Received.selector;
        else
            return bytes4("");
    }


    function _createLendingAgreement(address _tokenLord, uint _tokenId, bytes calldata data) internal returns (bool)
    {
        // data: 0x --> 20bytes of contract address --> 20 bytes of token address ==> 64 bytes of lendForBlocks (because uint64)
        address _contractAddress = data.toAddress(1); 
        require(_isAnErc721Contract(_contractAddress));
        address _tokenRenter = data.toAddress(21); 
        uint lendForBlocks = data.toUint256(41);
        uint _deadline = block.timestamp + lendForBlocks;
        LendingAgreement memory agreement = LendingAgreement(_contractAddress, _tokenId, _tokenLord, _tokenRenter, _deadline);
    }

    /*
        Returns true if the contract address passed is an implementation of the ERC721 standard. 
        TBD: logic needs to be written.
    */
    function _isAnErc721Contract(address _contractAddress) private view returns (bool)
    {
        return true;
    }

}