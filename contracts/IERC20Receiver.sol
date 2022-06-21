// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


interface IERC20Receiver {
    /**
     * @dev Whenever an {IERC20Rewardable} `tokenId` token is transferred to this contract via {ERC20Rewardable-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC20Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
    
}