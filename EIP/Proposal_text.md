
---
eip: <to be assigned>
title: ERC721 Lending Oracle
description: Implementation of an on-chain lending oracle for gaming NFTs
author: Maksimjeet Chowdhary <chowdharymaksimjeet@gmail.com>, Maksimjeet Chowdhary (@MakC-Ukr)
discussions-to: <URL>
status: Draft
type: Standards Track
category (*only required for Standards Track): ERC
created: 2022-06-28
requires (*optional): 721
---

<!--

This is the suggested template for new EIPs.

  

Note that an EIP number will be assigned by an editor. When opening a pull request to submit your EIP, please use an abbreviated title in the filename, `eip-draft_title_abbrev.md`.

  

The title should be 44 characters or less. It should not repeat the EIP number in title, irrespective of the category. -->

## Abstract

<!-- Abstract is a multi-sentence (short paragraph) technical summary. This should be a very terse and human-readable version of the specification section. Someone should be able to read only the abstract to get the gist of what this specification does. -->

The implementation for this contract allows an owner of a NFT contract to transfer his NFT to the "oracle" contract address by calling `safeTransferFrom` and sending relevant information in the 'bytes' calldata. The contract holds this information in mappings and also stores the deadlines until which a lending contract is valid. The relevant functions `isCurrentlyRented` , `extendAgreement`, `claimNftBack`, `realOwner` allow the mentioned functionality. The game contracts and the games' frontends can read data off the "oracle" and know about the lending agreements.

  

Furthermore, the current contract can be deployed even once for different ERC721 contracts since the lending agreements also hold the information about the contract address of ERC721.

## Motivation

The current specification is a suggested interface for a lending oracle to be implemented on chain. Currently, blockchain games utilize ERC721 tokens to represent a hero in the game or other in-game assets. In order to implement possibility for lending, the ERC721 contract has to be amended (which is not so convenient). The current specification allows the game devs to deploy a lending "oracle" contract on chain which keeps record of completed lending agreements.



## Specification

<!-- The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119. -->

### NOTES:

* The boolean false MUST be handled if returned by the `isCurrentlyRented` function.

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


## Rationale

The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages.

A diagram on working of an example interaction structure can be found [here]()
    <!-- ADD IPFS LINK HERE -->

## Backwards Compatibility
<!-- All EIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The EIP must explain how the author proposes to deal with these incompatibilities. EIP submissions without a sufficient backwards compatibility treatise may be rejected outright. -->

  

## Test Cases

<!-- Test cases for an implementation are mandatory for EIPs that are affecting consensus changes. If the test suite is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`. -->
Not needed (probably).
  

## Reference Implementation

An optional section that contains a reference/example implementation that people can use to assist in understanding or implementing this specification. If the implementation is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

  

## Security Considerations
* The ERC721 tokens should be transferred to the contract only with the `safeTransferFrom` function as implemented in [EIP721](https://eips.ethereum.org/EIPS/eip-721).
* When transferring the token, the bytes argument passed in calldata must be ensured to be in a correct format (as specified by the "oracle" contract to which the ERC721 is being transferred). Note: the `dataEncoder` funciton (if implemented) may be used for a more clear understanding.
  
## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).=