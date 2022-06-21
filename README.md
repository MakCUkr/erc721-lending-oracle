### Things to do: 
1. ~~Write logic for isNftContract~~
2. ~~Function to extend rental~~
3. ~~function to rent the nft to someone else after the deadline~~
4. Handling token rewards
5. A proper README.md
6. currentOwner function
7. need to add events
8. Create ILendingOracle.sol
9. Need to add function in Lending oracle to return if this oracle imlpements ILendingOracle.sol. 

Assumptions made: 
1. The NFT cannot be transferred back to the owner without deleting the agreement from EVM memory. Otherwise we risk the NFT being sold to some other user, but the tokenLord data doesn't get changed in our mapping.




### Background 
1. https://ethereum-magicians.org/t/eip4907-erc-721-user-and-expires-extension/8572
- Is an extension of IERC721 and hecne requires modification to the ERC721 contract itself
- Uses a new function `userOf` to differentiate the user form the owner fo the ERC721 contract.

2. https://ethereum-magicians.org/t/erc721-extension-to-enable-rental/8472
- Is an extension of IERC721 and hecne requires modification to the ERC721 contract itself
- Uses a new function `userOf` to differentiate the user form the owner fo the ERC721 contract.

3. https://eips.ethereum.org/EIPS/eip-4400
- Is an extension of IERC721 and hecne requires modification to the ERC721 contract itself
- Uses 2 new functions `consumerOf`, `changeConsumer` to differentiate the user form the owner fo the ERC721 contract.