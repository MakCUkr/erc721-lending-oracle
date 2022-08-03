# ERC721 Lending Oracle

The current repository is an implementation of the suggest [EIP1972, submitted on Ethereum Magicians](https://ethereum-magicians.org/t/eip-1972-erc-721-lending-oracle/9901). 

The current specification is a suggested interface for a lending oracle to be implemented on chain. Currently, blockchain games utilize ERC721 tokens to represent a hero in the game or other in-game assets. In order to implement possibility for lending, the ERC721 contract has to be amended (which is not very convenient for the game developers). The current specification allows the game devs to deploy a lending “oracle” contract on chain which keeps record of completed lending agreements without changing the core ERC721 contract 
of the game asset NFTs.

### Pipeline of the model

<img src="./diagram-lendingNft.drawio.svg">


### Run tests

Several test are written for the working of the contracts and are in `./test` folder. To run the tests, run the following commands in the root folder:
1. `npm install`
2. `npm test`

### Background Research
1. https://ethereum-magicians.org/t/eip4907-erc-721-user-and-expires-extension/8572
- Is an extension of IERC721 and hecne requires modification to the ERC721 contract itself
- Uses a new function `userOf` to differentiate the user form the owner fo the ERC721 contract.

2. https://ethereum-magicians.org/t/erc721-extension-to-enable-rental/8472
- Is an extension of IERC721 and hecne requires modification to the ERC721 contract itself
- Uses a new function `userOf` to differentiate the user form the owner fo the ERC721 contract.

3. https://eips.ethereum.org/EIPS/eip-4400
- Is an extension of IERC721 and hecne requires modification to the ERC721 contract itself
- Uses 2 new functions `consumerOf`, `changeConsumer` to differentiate the user form the owner fo the ERC721 contract.
