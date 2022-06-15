// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


/*
    ERC721 implementation : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
    The ERC721 contract inherits from the following interfaces: IERC721Metadata
    The ERC721 contract inherits from the following contracts: Context, ERC165, IERC721
*/
contract PlayerHero is ERC721,  Ownable{
    using Strings for uint256;

    string private _stringBaseURI = "";
    uint public mintCost = 0.1 ether;
    constructor(string memory _name, string memory _symbol, string memory _newStringBaseURI)
    ERC721(_name, _symbol)
    {
        _stringBaseURI = _newStringBaseURI;
    }

    function setBaseUri(string memory _newBaseUri) public onlyOwner {
        _stringBaseURI = _newBaseUri;
    }


    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return _stringBaseURI;
    }

    function mint(address to, uint256 tokenId) public payable {
        require(msg.value == mintCost, string(abi.encodePacked("mintCost not paid. mintCost: ", mintCost.toString(), " wei")));
        _mint(to, tokenId);
    }

}
