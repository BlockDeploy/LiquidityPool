// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/IERC20.sol";

contract LiquidityPool {
    IERC20 public token;
    address public owner;
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    uint256 public tokenReserve;
    uint256 public ethReserve;

    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event LiquidityRemoved(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event Swap(address indexed sender, uint256 ethIn, uint256 tokenOut, uint256 tokenIn, uint256 ethOut);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    function addLiquidity(uint256 tokenAmount) external payable {
        require(msg.value > 0, "ETH amount must be greater than 0");
        require(tokenAmount > 0, "Token amount must be greater than 0");

        uint256 ethAmount = msg.value;
        uint256 liquidityMinted;

        if (totalLiquidity == 0) {
            liquidityMinted = ethAmount;
        } else {
            uint256 tokenReserveBefore = tokenReserve;
            uint256 ethReserveBefore = ethReserve;
            require(tokenAmount * ethReserveBefore == ethAmount * tokenReserveBefore, "Incorrect token/ETH ratio");
            liquidityMinted = (ethAmount * totalLiquidity) / ethReserveBefore;
        }

        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        liquidity[msg.sender] += liquidityMinted;
        totalLiquidity += liquidityMinted;
        tokenReserve += tokenAmount;
        ethReserve += ethAmount;

        emit LiquidityAdded(msg.sender, ethAmount, tokenAmount);
    }

    function removeLiquidity(uint256 liquidityAmount) external {
        require(liquidity[msg.sender] >= liquidityAmount, "Insufficient liquidity");
        require(totalLiquidity > 0, "No liquidity in pool");

        uint256 ethAmount = (liquidityAmount * ethReserve) / totalLiquidity;
        uint256 tokenAmount = (liquidityAmount * tokenReserve) / totalLiquidity;

        liquidity[msg.sender] -= liquidityAmount;
        totalLiquidity -= liquidityAmount;
        tokenReserve -= tokenAmount;
        ethReserve -= ethAmount;

        payable(msg.sender).transfer(ethAmount);
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");

        emit LiquidityRemoved(msg.sender, ethAmount, tokenAmount);
    }

    function swapEthForToken(uint256 minTokensOut) external payable {
        require(msg.value > 0, "ETH amount must be greater than 0");
        require(ethReserve > 0 && tokenReserve > 0, "Pool is empty");

        uint256 ethIn = msg.value;
        uint256 tokensOut = getAmountOut(ethIn, ethReserve, tokenReserve);
        require(tokensOut >= minTokensOut, "Insufficient tokens out");

        ethReserve += ethIn;
        tokenReserve -= tokensOut;

        require(token.transfer(msg.sender, tokensOut), "Token transfer failed");
        emit Swap(msg.sender, ethIn, tokensOut, 0, 0);
    }

    function swapTokenForEth(uint256 tokenAmount, uint256 minEthOut) external {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        require(ethReserve > 0 && tokenReserve > 0, "Pool is empty");

        uint256 ethOut = getAmountOut(tokenAmount, tokenReserve, ethReserve);
        require(ethOut >= minEthOut, "Insufficient ETH out");

        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        tokenReserve += tokenAmount;
        ethReserve -= ethAmount;

        payable(msg.sender).transfer(ethOut);
        emit Swap(msg.sender, 0, 0, tokenAmount, ethOut);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "Invalid input");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        return numerator / denominator;
    }

    function getTokenPrice() public view returns (uint256) {
        require(ethReserve > 0, "No ETH in pool");
        return (tokenReserve * 1e18) / ethReserve;
    }
}