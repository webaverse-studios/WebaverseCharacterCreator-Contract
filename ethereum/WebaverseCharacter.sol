// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";


contract WebaverseCharacter is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using SafeMath for uint256;

    uint256 public constant tokenPrice = 0.001 ether; // 0.0444 ETH
    uint public maxTokenPurchase = 20;
    uint public maxTokenPerWallet = 44;
    uint256 public MAX_TOKENS = 10000;
    address private _treasuryAddress; 
    
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint) private _numberOfWallets;

    constructor(address treasuryAddress) ERC721("Webaverse Character", "WCC") {
      _treasuryAddress = treasuryAddress;
    }

    // Withdraw contract balance to creator (mnemonic seed address 0)
    function withdraw() public onlyOwner {
        // This will transfer the remaining contract balance to the owner.
        (bool os, ) = payable(_treasuryAddress).call{value: address(this).balance}('');
        require(os);
    }

    function mintToken(uint numberOfTokens, string memory _tokenURI) public payable {
        uint256 currentTokenId = totalSupply();
        require(numberOfTokens <= maxTokenPurchase, "Exceeded max token purchase");
        require(_numberOfWallets[msg.sender] + numberOfTokens <= maxTokenPerWallet, "Exceeded max token purchase per wallet");
        require(currentTokenId + numberOfTokens <= MAX_TOKENS, "Purchase would exceed max supply of tokens");
        require(tokenPrice * numberOfTokens <= msg.value, "Ether value sent is not correct");
        _safeMint(msg.sender, numberOfTokens);
        _tokenURIs[currentTokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );

        return bytes(_tokenURIs[tokenId]).length > 0
            ? _tokenURIs[tokenId]
            : "";
    }

    function setMaxTokensPurchase(uint _maxTokens) external onlyOwner {
        maxTokenPurchase = _maxTokens;
        emit SetMaxTokensPurchase(_maxTokens);
    }

    function setMaxTokensWallet(uint _maxTokens) external onlyOwner {
        maxTokenPerWallet = _maxTokens;
        emit SetMaxTokensWallet(_maxTokens);
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyOwner {
      treasuryAddress = _treasuryAddress;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}