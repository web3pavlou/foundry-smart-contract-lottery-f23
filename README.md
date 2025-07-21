# Foundry Smart Contract Lottery

![Build](https://img.shields.io/github/actions/workflow/status/web3pavlou/foundry-smart-contract-lottery-f23/ci.yml?branch=main)

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

---


## Description

A sample Ethereum smart contract lottery built with [Foundry](https://getfoundry.sh/), featuring robust testing, Chainlink VRF v2.5 support, mock infrastructure, and modular, maintainable scripts.  

**Chainlink VRF** integration ensures cryptographically secure randomness for winner selection.

---

## Getting Started

### Requirements

- [Git](https://git-scm.com/)
- [Foundry (Forge, Cast, Anvil)](https://getfoundry.sh/)
- [Make](https://www.gnu.org/software/make/) (optional, for scripts)
- Node.js (optional, for scripting utilities)

_Confirm your tools are installed:_
```bash
git --version
forge --version
anvil --version
````

---

## Quickstart

```bash
git clone https://github.com/web3pavlou/foundry-smart-contract-lottery-f23
cd foundry-smart-contract-lottery-f23
forge build
```

---

## Usage

### Start a Local Node

**Start Anvil in a separate terminal:**

```bash
anvil
# or with Makefile:
make anvil
```

---

## ⚠️ Common Issue: “You seem to be using Foundry's default sender”

### Block Underflow Error When Deploying Locally

*When running locally, you might see:*

```
[Revert] panic: arithmetic underflow or overflow (0x11)
```

**Why?**

* Some Chainlink mocks use `blockhash(block.number - 1)`. If the local chain is new (`block.number == 0`), this will underflow.

**Solution:**

* Open a second terminal and run:

  ```bash
  cast rpc evm_mine
  ```

  This increments the block number so `block.number - 1` is safe.
* Then re-run your deployment script.

---




If you see:

```
Error: You seem to be using Foundry's default sender. Be sure to set your own --sender.
```

* This appears if you don’t provide `--sender` explicitly.
* If you use `--private-key`, your script broadcasts from the correct account—**the warning can be safely ignored if everything else works**.
* To silence, use:

  ```bash
  forge script script/DeployRaffle.s.sol:DeployRaffle \
    --rpc-url http://localhost:8545 \
    --private-key <YOUR_PRIVATE_KEY> \
    --sender <YOUR_ADDRESS> \
    --broadcast
  ```

---

## Deployment to Testnet or Mainnet

1. **Setup Environment Variables**

   Create a `.env` file based on `.env.example`:

   * `PRIVATE_KEY`: your dev wallet (never use real funds!)
   * `SEPOLIA_RPC_URL`: Sepolia testnet RPC URL
   * `ETHERSCAN_API_KEY`: (optional) for contract verification

2. **Get Testnet ETH**

   Use [faucets.chain.link](https://faucets.chain.link/) to get Sepolia ETH.

3. **Deploy**

   ```bash
   make deploy ARGS="--network sepolia"
   ```

   * Sets up Chainlink VRF subscription
   * Adds your contract as VRF consumer
   * If you have an existing sub, update in `script/HelperConfig.s.sol`

4. **Register Chainlink Automation Upkeep**

   * Read [Automation docs](https://docs.chain.link/chainlink-automation/introduction/)
   * Register an upkeep at [automation.chain.link](https://automation.chain.link/)
     (choose “Custom logic” as the trigger)

---

## Testing

**Covers all four Foundry test tiers:**

* Unit
* Integration
* Forked (mainnet/testnet fork)
* Staging (public testnets)

### Running Tests

**Unit & Integration:**

```bash
forge test
forge test -vvv  # with traces
```

**Forked:**

```bash
forge test --fork-url $SEPOLIA_RPC_URL
```

**Staging (on testnet):**

```bash
forge script script/StagingTest.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

### Test Coverage

```bash
forge coverage
```

---

## Scripts

### Enter the Raffle

```bash
cast send <RAFFLE_CONTRACT_ADDRESS> "enterRaffle()" --value 0.1ether --private-key <PRIVATE_KEY> --rpc-url $SEPOLIA_RPC_URL
```

### Create a Chainlink VRF Subscription

```bash
make createSubscription ARGS="--network sepolia"
```

---

## Formatting

```bash
forge fmt
```

---

## Security

* Solidity >=0.8.x (overflow protection)
* Chainlink VRF/Upkeep best practices
* Comprehensive tests, access control, events
* **Never use mainnet private keys for dev/test!**

**Further reading:** [Smart Contract Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)

---

## Additional Resources

* [Foundry Book](https://book.getfoundry.sh/)
* [Chainlink VRF Docs](https://docs.chain.link/vrf/v2-5/)
* [Forge-std Reference](https://github.com/foundry-rs/forge-std)
* [Cyfrin Updraft Tutorials](https://github.com/Cyfrin/foundry-full-course-cu)

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Acknowledgements

* **Cyfrin Updraft** – Thanks to [@patrickalphaC](https://github.com/patrickalphaC)
* **Chainlink** – For the VRF service
* **Foundry** – For the dev tools

---
---
# Foundry-Smart-Contract-Lottery-f23
