// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./contracts/Gold.sol";
import "hardhat/console.sol";

contract SuperChad is Ownable, ReentrancyGuard {

Gold public payToken;
address public payTokenAddress;
address public currentHighScorer;
address public gameowner;
uint public playCount = 0;
uint256 public highestScore;
uint256 public currentHighScore = 0;
address public highestScorer;
bool public beatHighScoreRequirement = false;
uint256 public contractMinimum = 10000000000000000000000; // 10000 tokens

    constructor(address _gold) {
        setPayToken(_gold);    
        gameowner = msg.sender;
    }

    function setContractMinimum(uint256 _contractMinimum) public onlyOwner {
        contractMinimum = _contractMinimum;
    }

    function setPayToken(address _payTokenAddress) public onlyOwner {
        payTokenAddress = _payTokenAddress;
        payToken = Gold(_payTokenAddress);
        payToken.approve(address(this),10000000000000000000000);
    }

    event CollectTokens(address _player, uint256 _score);

    function submitScore(uint256 _score) external nonReentrant returns (bool success) {
        if(beatHighScoreRequirement){
            require(_score > currentHighScore, "You did not beat the high score this time");
        }
        if(highestScore < _score){
            highestScore = _score;
            highestScorer = msg.sender;
        }
        if(currentHighScore < _score){
            currentHighScore = _score;
            currentHighScorer = msg.sender;
        }

        uint256 _tokensEarned = _score * 1 ether;
        payToken.mint(address(this), _tokensEarned);

        payToken.approve(address(this), _tokensEarned);
        payToken.transferFrom(address(this), msg.sender, _tokensEarned);

        //return playCount;
        emit CollectTokens(msg.sender, _tokensEarned);
        return true;
    }

}