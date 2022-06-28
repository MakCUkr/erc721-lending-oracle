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
requires (*optional): <EIP number(s)>
---
<!-- 
This is the suggested template for new EIPs.

Note that an EIP number will be assigned by an editor. When opening a pull request to submit your EIP, please use an abbreviated title in the filename, `eip-draft_title_abbrev.md`.

The title should be 44 characters or less. It should not repeat the EIP number in title, irrespective of the category.  -->
## Abstract
<!-- Abstract is a multi-sentence (short paragraph) technical summary. This should be a very terse and human-readable version of the specification section. Someone should be able to read only the abstract to get the gist of what this specification does. -->
The implementation for this contract allows an owner of a NFT contract to transfer his NFT to the "oracle" contract address by calling `safeTransferFrom` and sending relevant information in the 'bytes' calldata. The contract holds this information in mappings and also stores the deadlines until which a lending contract is valid. The relevant functions `isCurrentlyRented` , `extendAgreement`, `claimNftBack`, `realOwner` allow the mentioned functionality. The game contracts and the games' frontends can read data off the "oracle" and know about the lending agreements. 

Furthermore, the current contract can be deployed even once for different ERC721 contracts since the lending agreements also hold the information about the contract address of ERC721. 
## Motivation
The current specification is a suggested interface for a lending oracle to be implemented on chain. Currently, blockchain games utilize ERC721 tokens to represent a hero in the game or other in-game assets. In order to implement possibility for lending, the ERC721 contract has to be amended (which is not so convenient)/ The current specification allows the game devs to deploy a lending "oracle" contract on chain which keeps record of completed lending agreements.
## Specification
<!-- The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119. -->
### NOTES:
* The boolean false MUST be handled if returned by the `isCurrentlyRented` function. 

Returns whether a certain ERC721 contract is currently rented, and returns who is the renter if True.
<mark>function isCurrentlyRented(address _contractAddress, uint _tokenId) public view returns(bool, address)</mark>
## Rationale
The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages.

## Backwards Compatibility
All EIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The EIP must explain how the author proposes to deal with these incompatibilities. EIP submissions without a sufficient backwards compatibility treatise may be rejected outright.

## Test Cases
Test cases for an implementation are mandatory for EIPs that are affecting consensus changes.  If the test suite is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

## Reference Implementation
An optional section that contains a reference/example implementation that people can use to assist in understanding or implementing this specification.  If the implementation is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

## Security Considerations
All EIPs must contain a section that discusses the security implications/considerations relevant to the proposed change. Include information that might be important for security discussions, surfaces risks and can be used throughout the life cycle of the proposal. E.g. include security-relevant design decisions, concerns, important discussions, implementation-specific guidance and pitfalls, an outline of threats and risks and how they are being addressed. EIP submissions missing the "Security Considerations" section will be rejected. An EIP cannot proceed to status "Final" without a Security Considerations discussion deemed sufficient by the reviewers.

## Copyright
Copyright and related rights waived via [CC0](../LICENSE.md).=