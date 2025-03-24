
### Instructions for Using LiquidityPool

**Description:**  This is a liquidity pool contract for an Automated Market Maker (AMM),  
similar to Uniswap or PancakeSwap. It creates your own market for swapping ETH and your ERC-20 token.  
Liquidity Providers (LPs) contribute ETH and tokens in equal proportions, while traders swap them using the  
formula  `x * y = k`  (constant product). LPs earn a 0.3% fee on each trade proportional to their share.  
**Difference from PancakeSwap:**  Unlike PancakeSwap, which is a ready-made exchange with multiple pools,  
a user-friendly website, and thousands of users,  `LiquidityPool`  is your personal pool that you create and  
control yourself. PancakeSwap offers infrastructure (website, routing, analytics), while here you decide how to  
organize trading — via Etherscan or your own interface. This gives you full control but requires more effort to  
attract traders.  
**What it offers:**  Decentralized swapping without intermediaries, passive income for LPs, and liquidity  
for your token. For example, add 1 ETH and 1000 tokens, and people can trade through your pool while you earn fees.

**Compilation:**  Go to the "Deploy Contracts" page in BlockDeploy,  
paste the code into the "Contract Code" field (it imports OpenZeppelin for ERC-20 functionality),  
select Solidity version 0.8.10 from the dropdown menu,  
click "Compile" — the "ABI" and "Bytecode" fields will populate automatically.

**Deployment:**  In the "Deploy Contract" section:  
- Select the network (e.g., Ethereum Mainnet ),  
- Enter the private key of a wallet with ETH into the "Private Key" field,  
- Specify the address of your ERC-20 token (e.g.,  `0xYourTokenAddress`) as the constructor parameter,  
- Click "Deploy" and confirm in the modal window. After deployment, you’ll get the pool address (e.g.,  `0xYourPoolAddress`).

**How to Set Up and Use the Liquidity Pool:**  
Here’s a step-by-step guide to creating and working with your pool:  

-   **Create an ERC-20 Token:**  If you don’t have a token, use  `SimpleToken`  from BlockDeploy.  
    Deploy it (e.g., "MyToken", "MTK", 18 decimals, 1,000,000 tokens) and note its address (e.g.,  `0xYourTokenAddress`).
-   **Add Liquidity:**  Call  `addLiquidity`.  
    - In the token’s interface, call  `approve`, specifying the pool address (`0xYourPoolAddress`) and amount (e.g., 1000 MTK).  
    - In BlockDeploy, locate the pool, select  `addLiquidity`, enter 1000 MTK, and send 1 ETH with the transaction.  
    - The first LP sets the ratio (1 ETH = 1000 MTK), and subsequent LPs must follow it.
-   **Best Way to Trade — via Etherscan "Write Contract":**  
    -  **Verify the Contract:**  After deployment, go to Etherscan ([etherscan.io](https://etherscan.io/)), find your contract by address.  
    Go to the "Contract" tab → "Verify and Publish," paste the contract code, select Solidity 0.8.10, enter the token address in the constructor, and verify.  
    -  **Trading:**  After verification, in the "Write Contract" tab:  
    1. Connect MetaMask via "Connect to Web3".  
    2. For  `swapEthForToken`: enter  `minTokensOut`  (e.g., 0 for simplicity), specify the ETH amount in the "Value" field (e.g., 0.1 ETH), click "Write," and confirm.  
    3. For  `swapTokenForEth`: first approve tokens via the token (`approve`), then enter  `tokenAmount`  (e.g., 100 MTK) and  `minEthOut`  (0), click "Write".  
    -  **Why this is the best way:**  It’s more convenient than manually via MetaMask, doesn’t require a website, shows all functions, but the contract must be verified for "Write" access.
-   **Remove Liquidity:**  Via Etherscan "Write Contract," call  `removeLiquidity`,  
    specifying the liquidity amount (e.g., your share in wei) to withdraw ETH and tokens.
-   **Check the Price:**  Via "Read Contract" on Etherscan, call  `getTokenPrice`,  
    to see the current token price in ETH (in wei).
