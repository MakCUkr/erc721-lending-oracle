---
eip: <to be assigned>
title: ERC721 Lending Oracle
description: Implementation of an on-chain lending oracle for gaming NFTs
author: Maksimjeet Chowdhary (chowdharymaksimjeet@gmail.com), Maksimjeet Chowdhary (@MakC-Ukr)
discussions-to: <URL>
status: Draft
type: Standards Track
category: ERC
created: 2022-06-08
requires (*optional): 721
---


## Abstract

The implementation for this contract allows an owner of a NFT contract to transfer his NFT to the "oracle" contract address by calling `safeTransfer` (or `safeTransferFrom`) and sending relevant information in the 'bytes' parmaeter as calldata. The contract holds this information in mappings and also stores the deadlines until which a lending contract is valid. The relevant functions `isCurrentlyRented` , `extendAgreement`, `claimNftBack`, `realOwner` allow the mentioned functionality. The game contracts and the games' frontends can read data off the "oracle" and know about the lending agreements.
  

Furthermore, the current contract can be deployed even once for different ERC721 contracts since the lending agreements also hold the information about the contract address of ERC721.

## Motivation

The current specification is a suggested interface for a lending oracle to be implemented on chain. Currently, blockchain games utilize ERC721 tokens to represent a hero in the game or other in-game assets. In order to implement possibility for lending, the ERC721 contract has to be amended (which is not so convenient). The current specification allows the game devs to deploy a lending "oracle" contract on chain which keeps record of completed lending agreements without changing the core ERC721 contract of the game asset NFTs. 


## Specification

<!-- The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119. -->

### NOTES:

* The boolean false MUST be handled if returned by the `isCurrentlyRented` function.

### Functions

##### isCurrentlyRented
Returns whether a certain ERC721 contract is currently rented, and returns who is the renter if True.

==function isCurrentlyRented(address _contractAddress, uint _tokenId) public view returns(bool, address)==

##### onERC721Received

Returns The functions selector of `onERC721Received` 
SHOULD handle the logic of creating lending agreements whenever an ERC721 is transferred using `safeTransferFrom`

==function onERC721Received(address, address from, uint256 tokenId, bytes calldata data ) public override returns (bytes4)==

##### extendAgreement

Returns the new deadline for the mentioned non fungible's lending agreement. 
OPTIONAL - Should extend the lending agreement. MUST be called only by an the actual owner of the ERC721 (tokenLord).

==function extendAgreement(address _contractAddress, uint _tokenId, uint _blocksExtended) public  returns (uint)==

##### realOwner

Returns the address of the actual owner (tokenLord) of a rented ERC721. MUST make sure that the ERC721 is currently rented.

==function realOwner(address _contractAddress, uint _tokenId) public  view  returns(address currOwner)==

##### currentRenter

Returns the address of the renter of a rented ERC721. MUST make sure that the ERC721 is currently rented.

==function currentRenter(address _contractAddress, uint _tokenId) public  view  returns(address currRenter)==

##### dataEncoder

Returns the byte representation of the data that must be sent to the current contract with the `safeTransferFrom` function. Each contract may have its on implementation of the same. The data may include the information about the deadline of the lending agreement, the address which is renting the token.

==function dataEncoder(address _contractAddress, address _tokenRenter, uint _lendForBlocks) public pure returns(bytes memory)==

##### isLendingOracle

Returns the selector of the isLendingOracle function itself. Will be used by the gaming contract in order to confirm if the owner of an NFT is a lending oracle. 

==function isLendingOracle() external pure virtual returns (bytes4)==


## Rationale

The design of the interface was motivated by the requirement of lending agreements to be made possible for ERC721-standard tokens without having to change the code of the Non-fungible Tokens themselves and having cross-contract interoperability of lending protocols. Many ERC721 tokens today have their own lending systems implemented but they lack the generalised approach to solving the problem of lending and borrowing. The current implementation ensures that previosuly deployed games/applications can allow their users to lend/borrow ERC721's by simply tweaking the code in the frontend of the game/application (to check if the owner of the ERC721 is a "Lending Oracle" and take appropriate actions if yes). 

A diagram on working of an example interaction structure can be found [here](https://ibb.co/72RwX5c)

## Backwards Compatibility
The ERC standard that we propose does not require the ERC721 standard to implement any new functions. The `safeTransfer` and `safeTransferFrom` functions were present in the [standard implementation])(https://eips.ethereum.org/EIPS/eip-721) put forward by EIP721 in January 2018. The current lending protocol would be compatible with all the ERC721's written as per the standard. 

In use case of gaming especially the issue of backwards compatibility may be benign. Many blockchain-based games have systems of ERC20 token emissions as prizes (incentives) for playing the game. With the added logic of an ERC721 being rented it may be unclear of how the distribution of the ERC20 tokens must be handled. In the Reference Implementation section, we also propose a standard way fo handling ERC20 token rewards, however that method needs to tweak the smart contract of the ERC20 utility (reward) token. If the same is not possible, the games should explicitly discourage users from lending out their ERC721 to some other user using the "Lending oracles" currently being put forward.

## Reference Implementation

An optional section that contains a reference/example implementation that people can use to assist in understanding or implementing this specification. If the implementation is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

  

## Security Considerations
* The ERC721 tokens should be transferred to the contract only with the `safeTransferFrom` function as implemented in [EIP721](https://eips.ethereum.org/EIPS/eip-721).
* When transferring the token, the bytes argument passed in calldata must be ensured to be in a correct format (as specified by the "oracle" contract to which the ERC721 is being transferred). Note: the `dataEncoder` funciton (if implemented) may be used for a more clear understanding.
  
## Copyright

Copyright and related rights belong to Maksimjeet Chowdhary (DOB 09.08.2002). For more information contact at [mail](mailto:chowdharymaksimjeet@gmail.com).
