// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YieldFarm is Ownable {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardRate = 100; // Reward per block
    uint256 public totalStaked;
    
    struct Staker {
        uint256 amount;
        uint256 rewardDebt;
    }
    
    mapping(address => Staker) public stakers;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    
    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }
    
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakers[msg.sender].amount += amount;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }
    
    function unstake(uint256 amount) external {
        require(stakers[msg.sender].amount >= amount, "Insufficient staked amount");
        stakingToken.transfer(msg.sender, amount);
        stakers[msg.sender].amount -= amount;
        totalStaked -= amount;
        emit Unstaked(msg.sender, amount);
    }
    
    function claimRewards() external {
        uint256 reward = stakers[msg.sender].amount * rewardRate / 1000;
        require(reward > 0, "No rewards available");
        rewardToken.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }
}

// TypeScript Frontend Setup (React + Ethers.js)
// 1. Install dependencies: `npm install ethers web3 react`
// 2. Connect to MetaMask and call contract functions

import { ethers } from "ethers";

const contractAddress = "YOUR_CONTRACT_ADDRESS";
const abi = [
    "function stake(uint256 amount) external",
    "function unstake(uint256 amount) external",
    "function claimRewards() external",
    "function totalStaked() public view returns (uint256)"
];

export async function connectWallet() {
    if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        await window.ethereum.request({ method: "eth_requestAccounts" });
        return provider.getSigner();
    } else {
        console.error("MetaMask not detected");
    }
}

export async function stakeTokens(amount) {
    const signer = await connectWallet();
    const contract = new ethers.Contract(contractAddress, abi, signer);
    const tx = await contract.stake(ethers.utils.parseEther(amount));
    await tx.wait();
}

export async function unstakeTokens(amount) {
    const signer = await connectWallet();
    const contract = new ethers.Contract(contractAddress, abi, signer);
    const tx = await contract.unstake(ethers.utils.parseEther(amount));
    await tx.wait();
}

export async function claimRewards() {
    const signer = await connectWallet();
    const contract = new ethers.Contract(contractAddress, abi, signer);
    const tx = await contract.claimRewards();
    await tx.wait();
}
