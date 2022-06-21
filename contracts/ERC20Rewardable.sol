// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./IERC20Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/*
 * @dev Extension of the ERC20 contract that allows data to be transferred to a smart contract when completing a transfer of tokens.
 * Is a useful implementation that games can adopt to allow their ERC20 tokens to be used with the LendingOracle contract.
 *
 * The game contract will be able to transfer ERC20 rewards to the Lending Oracle with the data needed about who the ERC20 rewards 
 * belong to, the ratio of the rewards that goes to the owner, the renter etc. 
 */ 
 
 contract ERC20Rewardable is Context,ERC20 {
    using Address for address;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_)
    {}

    /**
     * See {ERC20Rewardable: _safeTransfer}
     */
    function safeTransfer(  
        address to,
        uint256 amount, 
        bytes calldata data
    ) public {
        _safeTransfer(to, amount, data);
    }


    /*
        @dev A transfer method that also allows to send calldata as a parameter intended for a smart contract
    */
    function _safeTransfer(  
        address to,
        uint256 amount, 
        bytes calldata data
    ) internal virtual {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        require(_checkOnERC20Received(owner, to, amount, data), "ERC20Rewardable: transfer to non ERC20Receiver implementer");
    }

    function safeMint(address to, uint256 amount, bytes calldata data) public
    {
        _safeMint(to,amount, data);
    }

    /*
        @dev A mint method that also allows to send calldata as a parameter intended for a smart contract
    */
    function _safeMint(address to, uint256 amount, bytes calldata data) internal
    {
        _mint(to, amount);
        require(_checkOnERC20Received(address(0), to, amount, data), "ERC20Rewardable: transfer to non ERC20Receiver implementer");
    }

    /**
     * see {ERC20Rewardable-_safeTransferFrom}
     */
    function safeTransferFrom(address from, address to, uint amount, bytes calldata data) public
    {
        _safeTransferFrom(from, to, amount, data);
    }

    /*
        @dev A transferFrom method that also allows to send calldata as a parameter intended for a smart contract
    */
    function _safeTransferFrom(address from, address to, uint amount, bytes calldata data) internal
    {
        transferFrom(from, to,amount);
        require(_checkOnERC20Received(from, to, amount, data), "ERC20Rewardable: transfer to non ERC20Receiver implementer");
    }


    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param amount uint256 amount of tokens to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC20Received(address from, address to, uint amount, bytes calldata data) private returns (bool){
        if (to.isContract()) {
            try IERC20Receiver(to).onERC20Received(_msgSender(), from, amount, data) returns (bytes4 retval) {
                return retval == IERC20Receiver.onERC20Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC20Rewardable: transfer to non ERC20Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * Temporary function to mint tokens for testing 
     */
    function mint(address account, uint256 amount) public  {
        _mint(account, amount);
    }


}
