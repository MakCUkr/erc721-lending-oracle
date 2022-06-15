Things to do: 
1. ~~Write logic for isNftContract~~
2. ~~Function to extend rental~~
3. ~~function to rent the nft to someone else after the deadline~~
4. Handling token rewards
5. A proper README.md


Assumptions made: 
1. The NFT cannot be transferred back to the owner without deleting the agreement from EVM memory. Otherwise we risk the NFT being sold to some other user, but the tokenLord data doesn't get changed in our mapping.
