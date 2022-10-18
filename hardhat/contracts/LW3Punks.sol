//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** 
@title An NFT Minting system
@author Hafikraimy
@notice Use this contract to mint an NFT using the openzeppelin resources
*/

///@dev import the openzeppelin resources required for this project
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
@dev contract LW3Punks is inheriting the properties of the openzeppelin smart contracts in line 11 and 12
*/
contract LW3Punks is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string _baseTokenURI;
    bool public _paused;
    uint256 public tokenIds;

    constructor(string memory baseURI) ERC721("LW3Punks", "LW3P") {
        _baseTokenURI = baseURI;
    }

    

    /**
    @notice Mint Function to allow user to mint 1 nft per transaction
    @dev make _price and maxTokenIds variables local to reduce gas cost of contract than making it global 
    @dev increase the value of tokenIds by 1 and then mint to the sender with the tokenIds
    */
    function mint() public payable {
        uint256 _price = 0.01 ether;
        uint256 maxTokenIds = 10;
        require(!_paused, "Contract currently paused");
        require(tokenIds < maxTokenIds, "Exceed maximum LW3Punks supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds ++;
        _safeMint(msg.sender, tokenIds);
    }

    
    function _baseURI() internal view virtual override returns (string memory){
        return _baseTokenURI;
    }


    /**
    @dev Ensure that tokenId exists before assigning baseURI to _baseURI()
    @param tokenId The token ID of the ecr721 NFT
    @return the string from memory
    */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    /**
    @notice A function to make only the owner activate pause
    @param val A boolen value that is given which the _paused will be equated to
    */
    function setPaused(bool val)public onlyOwner{
        _paused = val;
    }

    /**
    @notice A function for withrawal
    @dev The onlyOwner is an inherited function from openzeppelin that tells ensures that only the owner can withdraw
    */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send ether");
    }
    receive() external payable {}
    fallback() external payable {}
}
