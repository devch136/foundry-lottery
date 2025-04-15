# 🎟️ Raffle Smart Contract

This project is a decentralized raffle (lottery) application built using **Solidity** and **Foundry**. It allows users to enter the raffle by paying a minimum fee. At regular time intervals, a random winner is automatically selected using **Chainlink VRF**, and the selection process is automated using **Chainlink Automation (Upkeep)**.

---

## 🛠️ Features

- ✅ Secure and decentralized random number generation with **Chainlink VRF v2.5**
- ⏱️ Automatic winner selection using **Chainlink Automation**
- 💸 Minimum entrance fee required to enter
- 🧠 Built with modular and testable architecture using **Foundry**
- 🧪 Includes deployment and interaction scripts for local and testnet development

---

## 📦 Tech Stack

- [Foundry](https://book.getfoundry.sh/) – development and testing framework
- [Solidity](https://docs.soliditylang.org/) – smart contract language
- [Chainlink VRF v2.5](https://docs.chain.link/vrf/v2-5/introduction) – for verifiable randomness
- [Chainlink Automation](https://docs.chain.link/chainlink-automation/introduction) – to automate on-chain tasks

---

## 📂 Project Structure

```bash
.
├── src/
│   └── Raffle.sol                # Main raffle contract
├── script/
│   ├── DeployRaffle.s.sol       # End-to-end deployment script
│   ├── Interactions.s.sol       # Create, fund, and register VRF consumer
│   └── HelperConfig.s.sol       # Environment-specific config
├── test/
│   └── RaffleTest.t.sol         # Test files
├── foundry.toml
└── README.md
```

---

## 🚀 How It Works

1. **Enter Raffle** – Users call `enterRaffle()` and pay a minimum fee.
2. **Check Upkeep** – Chainlink Automation periodically checks if:
   - Enough time has passed
   - Raffle is open
   - There are players
3. **Perform Upkeep** – If checks pass, the contract requests a random number from Chainlink VRF.
4. **Pick Winner** – Once randomness is returned, a winner is picked and rewarded with the entire pot.
5. **Reset** – Players list is reset and the raffle reopens.

---

## 🧪 Local Development

### 1. Install Dependencies

```bash
forge install
```

### 2. Compile Contracts

```bash
forge build
```

### 3. Run Raffle Deployment Script

```bash
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url <your_rpc_url> --broadcast --private-key <your_private_key> --verify
```

This will:
- Create a VRF subscription (if not already present)
- Fund it
- Deploy the `Raffle` contract
- Add the contract as a consumer

---

## 🔗 Chainlink Setup

- Uses **VRF v2.5** with mock or testnet coordinator
- Requires LINK tokens to fund the subscription
- Chainlink Automation calls `performUpkeep()` when `checkUpkeep()` conditions are met

---

## 🧰 Scripts Overview

- `CreateSubscription`: Creates a new Chainlink VRF subscription
- `FundSubscription`: Funds the subscription with LINK (or mocked LINK for local)
- `AddConsumer`: Registers the deployed raffle contract as a VRF consumer
- `DeployRaffle`: Runs full deployment + setup pipeline

---

## 📄 Contract Configuration

Change or set the following variables in `HelperConfig.s.sol`:

- `entranceFee`
- `interval`
- `vrfCoordinator`
- `subscriptionId`
- `keyHash`
- `callbackGasLimit`

---

## 🔐 Security

- Raffle only proceeds if all `checkUpkeep()` conditions are met
- Random number generation is tamper-proof using Chainlink VRF
- Funds are transferred only to a randomly selected winner

---

## 📬 License

[MIT](LICENSE)

---

## 🙌 Acknowledgments

- [Chainlink](https://chain.link/)
- [Foundry](https://book.getfoundry.sh/)
- [Solidity](https://soliditylang.org/)
