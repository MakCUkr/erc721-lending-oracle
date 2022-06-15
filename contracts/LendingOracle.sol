// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./libraries/BytesLib.sol";
import "hardhat/console.sol";

contract LendingOracle is IERC721Receiver{
    using BytesLib for bytes;
    uint256 constant NULL = 0;

    event LendingAgreementCreated(address contractAddress,uint tokenId,address tokenLord, address tokenRenter,uint deadline);

    struct LendingAgreement{
        address contractAddress;
        uint tokenId;
        address tokenLord;
        address tokenRenter;
        uint deadline;
    }

    mapping(address => mapping(uint=> LendingAgreement)) allAgreements;


    /*
        @desc Homonymous application
        @param _contractAddress - homonymous
        @param _tokenId - homonymous
        @return returns : 1. boolean if the mentioned token is rented currently
                          2. returns the address of the user to which the NFT is rented. 
                              returns zero address if the token is not rented
    */
    function isCurrentlyRented(address _contractAddress, uint _tokenId) public view returns(bool , address){
        if(_isCurrentlyRented(_contractAddress, _tokenId)){
            return (true, allAgreements[_contractAddress][_tokenId].tokenRenter);
        }
        else{
            return (false, address(0));
        }
    }

    function _isCurrentlyRented(address _contractAddress, uint _tokenId) internal view returns(bool){
        if(allAgreements[_contractAddress][_tokenId].deadline == NULL || allAgreements[_contractAddress][_tokenId].deadline < block.timestamp)
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
        require(data.length > 0 , "bytes.length must be more than 0");
        if(_createLendingAgreement(from,tokenId, data))
            return this.onERC721Received.selector;
        else
            return bytes4("");
    }

    /*
        This is called internally in onERC721Received
        @param _tokenLord - the owner of the NFT
        @param tokenId - the tokenId of the NFT that is being rented out
        @param data - encoded data. Must contain the following: 
            - address contractAddress;
            - address tokenRenter;
            - uint lendForBlocks
        @return boolean to confirm if an agreement was succesfully created
        Note: the function should be maintained private at all costs (otherwise non-owner of NFT will be able to spam allAgreements)
    */
    function _createLendingAgreement(address _tokenLord, uint _tokenId, bytes calldata data) private returns (bool)
    {
        // // data: 0x --> 20bytes of contract address --> 20 bytes of token address ==> 64 bytes of _lendForBlocks (because uint64)
        address _contractAddress = data.toAddress(0); 
        require(_isAnErc721Contract(_contractAddress));
        address _tokenRenter = data.toAddress(20); 
        uint _lendForBlocks = data.toUint256(40);
        // uint lendForBlocks = 69;
        uint _deadline = block.timestamp + _lendForBlocks;

        LendingAgreement memory agreement = LendingAgreement(
            _contractAddress, _tokenId, _tokenLord, _tokenRenter, _deadline);
        
        require(_addAgreementToMapping(agreement), "_createLendingAgreement: _addAgreement returned false");

        return true;
    }

    /*
        An internal call to add a lending agreement to the allAgreements mapping
        @param agreement - the LendingAgreement
        @return boolean to confirm if an agreement was succesfully added
    */
    function _addAgreementToMapping(LendingAgreement memory agreement) internal returns (bool)
    {
        allAgreements[agreement.contractAddress][agreement.tokenId] = agreement;
        // @explain kind of a double check to make sure that the lending agreement was succesfully added 
        require(allAgreements[agreement.contractAddress][agreement.tokenId].deadline > block.timestamp,
                    "_addAgreementToMapping: could not add agreement to the allAgreements mapping"); 
        emit LendingAgreementCreated(
            agreement.contractAddress, 
            agreement.tokenId,
            agreement.tokenLord, 
            agreement.tokenRenter, 
            agreement.deadline);
        return true;
    }

    /* 
        @desc The function returns output of passing the contract address, the address of the renter, and the amount of blocks for which the agreement will be to abi.encodePacked function. This output can further be used for passing to calldata in ERC721 safeTransferFrom() function
        @param contractAddress - homonymous
        @param tokenRenter - homonymous
        @param lendForBlocks - homonymous
        @return bytes memory
    */
    function dataEncoder(address _contractAddress, address _tokenRenter, uint _lendForBlocks) public view returns(bytes memory)
    {
        return abi.encodePacked(_contractAddress, _tokenRenter, _lendForBlocks);
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