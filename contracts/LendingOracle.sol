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


contract LendingOracle is IERC721Receiver,Context, AccessControl, ILendingOracle, IERC20Receiver{
    using BytesLib for bytes;
    uint256 constant NULL = 0;
    uint feesBps = 100; //100 bps = 1 %
    event LendingAgreementCreated(address contractAddress,uint tokenId,address tokenLord, address tokenRenter,uint deadline);
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct LendingAgreement{
        address contractAddress;
        uint tokenId;
        address tokenLord;
        address tokenRenter;
        uint deadline;
    }

    struct RewardsAgreement{
        address tokenLord; 
        address tokenRenter; 
        address erc20; 
        uint amount; 
        uint ownerRatio;
        bool distributed;
    }

    RewardsAgreement[] allRewards;
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
    function onERC721Received(address, address from, uint256 tokenId, bytes calldata data ) public override returns (bytes4) {
        require(data.length > 0 , "LendingOracle: bytes.length must be more than 0");
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
        address _tokenRenter = data.toAddress(20); 
        uint _lendForBlocks = data.toUint256(40);

        require(_tokenRenter != address(0), "LendingOracle: the token renter can't be the zero address");
        require(_contractAddress != address(0), "LendingOracle: contract address can't be zero address");
        require(_lendForBlocks > 0, "LendingOracle: length of agreement can't be equal to 0 blocks");
        uint _deadline = block.timestamp + _lendForBlocks;

        LendingAgreement memory agreement = LendingAgreement(
            _contractAddress, _tokenId, _tokenLord, _tokenRenter, _deadline);
        
        require(_addAgreementToMapping(agreement), "LendingOracle: _addAgreement returned false");

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
    function dataEncoder(address _contractAddress, address _tokenRenter, uint _lendForBlocks) public pure returns(bytes memory){
        return abi.encodePacked(_contractAddress, _tokenRenter, _lendForBlocks);
    }


    /*
        @desc the function is used for extending the agreement for a certain NFT
        @param _contractAddress - ERC721 contract address
        @param _tokenId - homonymous
        @param _blocksExtended - number of blocks b which the agreement must be extended
    */
    function extendAgreement(address _contractAddress, uint _tokenId, uint _blocksExtended) public{
        require(allAgreements[_contractAddress][_tokenId].deadline > 0, "LendingOracle: Initial lending agreement doesn't exist");
        require(allAgreements[_contractAddress][_tokenId].deadline < block.timestamp, "LendingOracle: Previous agreement not expired");
        require(allAgreements[_contractAddress][_tokenId].tokenLord == _msgSender(), "LendingOracle: The msg sender should either be approved or owner of the token" );

        allAgreements[_contractAddress][_tokenId].deadline = block.timestamp + _blocksExtended;
    }

    /*
        @desc the function that will be called to transfer the NFT back after the agreement has ended
        @param _contractAddress - self-explanatory
        @param _tokenId - self-explanatory
        Note:  the purpose of "deleting" the agreement is gas refund + gettig rid of the uncertainty in case of new owner after the agreement has ended
    */
    function claimNftBack(address _contractAddress, uint _tokenId) public
    {
        require(_isCurrentlyRented(_contractAddress, _tokenId) == false, "LendingOracle: Previous agreement not expired");
        require(allAgreements[_contractAddress][_tokenId].deadline > 0, "LendingOracle: No agreement in place before this");
        require(allAgreements[_contractAddress][_tokenId].tokenLord == _msgSender(), "LendingOracle: The msg sender should either be approved or owner of the token" );
        delete allAgreements[_contractAddress][_tokenId] ;
        ERC721(_contractAddress).safeTransferFrom(address(this), _msgSender(), _tokenId, "");
    }


    function addERC20Reward(address _tokenLord, address _tokenRenter, address _erc20, uint _amount, uint _ownerRatio) public returns (uint)
    {
        allRewards[allRewards.length-1] = RewardsAgreement(_tokenLord, _tokenRenter, _erc20, _amount, _ownerRatio, false);
        return (allRewards.length - 1);
    }


    function claimReward(uint _rewardId, bool _isRenter) public
    {
        RewardsAgreement memory rewAgrmnt=  allRewards[_rewardId];
        if(_isRenter){
            require(rewAgrmnt.tokenRenter == msg.sender, "LendingOracle: only the NFT renter can claim the reward back");
            uint contractFees = (feesBps * rewAgrmnt.amount ) / 10000;
            uint ownerFees = ((rewAgrmnt.amount - contractFees) * rewAgrmnt.ownerRatio )/100;
            uint renterPrize = rewAgrmnt.amount - ownerFees;
            IERC20(rewAgrmnt.erc20).transfer(address(this), renterPrize);
        }
        else{
            require(rewAgrmnt.tokenLord == msg.sender, "LendingOracle: only the NFT owner can claim the reward back");
            uint contractFees = (feesBps * rewAgrmnt.amount ) / 10000;
            uint ownerFees = ((rewAgrmnt.amount - contractFees) * rewAgrmnt.ownerRatio )/100;
            IERC20(rewAgrmnt.erc20).transfer(address(this), ownerFees);
        }
    }
    

    /**
     * @dev The NFT must be currently rented - see {LendingOracle - isCurrentlyRented}
     * @return currRenter - the address of the current renter of the NFT
     */
    function currentRenter(address _contractAddress, uint _tokenId) public view returns(address currRenter)
    {
        require(_isCurrentlyRented(_contractAddress, _tokenId), "LendingOracle: The NFT is not rented currently");
        currRenter= allAgreements[_contractAddress][_tokenId].tokenRenter; 
    }

    /**
     * @dev The NFT must be currently rented - see {LendingOracle - isCurrentlyRented}
     * @return currOwner - the address of the real owner of the NFT
     */
    function realOwner(address _contractAddress, uint _tokenId) public view returns(address currOwner)
    {
        require(_isCurrentlyRented(_contractAddress, _tokenId), "LendingOracle: The NFT is not rented currently");
        currOwner = allAgreements[_contractAddress][_tokenId].tokenLord;
    }


    /**
     * @dev see {IERC20Receiver-onERC20Received}
     */
    function onERC20Received(
        address from,
        address to,
        uint256 amount,
        bytes calldata data
    ) external override returns (bytes4){
        require(data.length > 0 , "LendingOracle: bytes.length must be more than 0");

        address cAddress = tx.origin;

        if(_addRewardAgreement(cAddress,amount, data))
            return this.onERC721Received.selector;
        else
            return bytes4("");
    }

    /**
     * @dev will decrypt the calldat transferred
     * @param cAddress - the contract address of the erc20Rewardable token
     * @param amount - amount of erc20tokens received
     * @param data - other calldata being send along with the transfer
     * @return result - returns true if all the data was passed correctly. returns false otherwise
     */
    function _addRewardAgreement(address cAddress, uint amount, bytes calldata data) internal returns (bool result)
    {


    }


}