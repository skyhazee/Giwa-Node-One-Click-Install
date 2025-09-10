# Giwa Node — One‑Click Installer (Sepolia Testnet)

This repository provides a **One‑Click Installer** to run a **Giwa Node** (Ethereum L2 built on Optimism's OP Stack) on **Sepolia Testnet**.

> Your repo: `https://github.com/skyhazee/Giwa-Node-One-Click-Install`  
> Upstream Giwa: [`giwa-io/node`](https://github.com/giwa-io/node)

---

## ✨ Features
- Auto‑installs **Docker** & **Docker Compose v2**
- Clones the public upstream **Giwa Node** (`giwa-io/node`)
- Creates `.env.sepolia` interactively (you provide **L1 RPC** & **L1 Beacon**)
- Builds & starts services with `docker compose`
- Handy commands for logs, stop, and cleanup

---

## 🧰 Minimum Server Specs
| Resource | Minimum | Recommended |
|---|---:|---:|
| CPU | 4 cores | 8+ cores |
| RAM | 8 GB | 16+ GB |
| Disk | 500 GB NVMe | 1+ TB NVMe |

**OS**: Ubuntu 22.04/24.04 (root or sudo user)

---

## 🚀 Quick Usage (One‑Click)

1) **Clone your installer repo**
```bash
git clone https://github.com/skyhazee/Giwa-Node-One-Click-Install.git
cd Giwa-Node-One-Click-Install
```

2) **Run the installer**
```bash
chmod +x giwa_install.sh
./giwa_install.sh
```
During the run you’ll be asked for:
- **Ethereum L1 RPC URL** (e.g., Alchemy/Infura)
- **Ethereum L1 Beacon URL** (your Beacon endpoint)

3) **Verify logs**
```bash
# Execution (EL)
docker compose logs -f giwa-el
# Consensus (CL)
docker compose logs -f giwa-cl
```

If all looks good, your node is syncing to Sepolia.

---

## ⚙️ Sync Modes
Default: **snap** (fastest & recommended). Change in `.env.sepolia` if needed.
- `snap` — fast, practical, recommended for most operators.
- `archive` — executes from genesis & keeps full historical state; very slow and heavy.
- `consensus` — execution driven by consensus client; slower, but more trust‑minimized.

```env
# inside .env.sepolia
SYNC_MODE=snap   # or: archive | consensus
```

---

## 💾 Data & Paths
- By default, execution data is stored in `./execution_data` (inside the cloned Giwa repo).
- You can override with `EXECUTION_DATA_DIR` in `.env.sepolia`.

Example:
```env
# Optional override
# EXECUTION_DATA_DIR=./execution_data
```

---

## 🧪 Common Commands
```bash
# Build containers (usually done by installer)
docker compose build --parallel

# Start (using .env.sepolia)
NETWORK_ENV=.env.sepolia docker compose up -d

# Stop
docker compose down

# Logs
docker compose logs -f giwa-el
docker compose logs -f giwa-cl

# Full cleanup (remove volumes + local chain data)
docker compose down -v && rm -rf ./execution_data
```

---

## 🛠️ Troubleshooting
**Clone error / GitHub credentials prompt**
- This installer clones the public repo `https://github.com/giwa-io/node.git`. If you see auth prompts, make sure you didn’t override `REPO_URL` to a private one.

**`docker: command not found` / `permission denied`**
- Re‑run the installer. If you’re **not root**, open a new shell (or run `newgrp docker`) so your user group changes take effect.

**`docker compose` not found**
- The installer installs Compose v2 at `/usr/lib/docker/cli-plugins/docker-compose`. Re‑run the installer if needed.

**Disk full**
- Stick to `snap`, expand disk space, or prune old data.

---

## 🔐 Security
- Treat your **RPC** and **Beacon** URLs as secrets if they are paid endpoints.
- **Do not commit** `.env.sepolia` to Git.

Suggested `.gitignore`:
```
.env.sepolia
execution_data/
*.log
```

---

## 📄 License
Add a license (e.g., MIT) if you want to make this public/open source.

---

## 🙌 Credits
- Upstream: [`giwa-io/node`](https://github.com/giwa-io/node)
- Installer: by @skyhazee

---

## 📎 Script Reference
The main script: `giwa_install.sh` will:
1. Install Docker + Compose v2 if missing
2. Clone `giwa-io/node` into `giwa-node/`
3. Create `.env.sepolia` from your input
4. Build & start services with `docker compose`

Override variables at runtime (optional):
```bash
REPO_URL=https://github.com/giwa-io/node.git \
CLONE_DIR=giwa-node \
./giwa_install.sh
