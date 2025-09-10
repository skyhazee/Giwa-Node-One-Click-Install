#!/bin/bash
set -euo pipefail

echo "🚀 Giwa Node One-Click Installer (Testnet Sepolia)"
echo "==============================================="

# --- Config repo (can be overridden via ENV) ---
REPO_URL="${REPO_URL:-https://github.com/giwa-io/node.git}"
CLONE_DIR="${CLONE_DIR:-giwa-node}"

# --- Helper: use sudo if not root ---
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
fi

echo "📦 Installing dependencies..."
$SUDO apt update -y || true
$SUDO apt upgrade -y || true
$SUDO apt install -y git curl jq build-essential ca-certificates || true

# --- Install Docker ---
if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Installing Docker..."
  curl -fsSL https://get.docker.com | $SUDO sh
  # Add user to docker group if not root
  if [ -n "$SUDO" ]; then
    $SUDO usermod -aG docker "$USER" || true
    echo "ℹ️  Please log out and log back in (or run 'newgrp docker') to activate docker group."
  fi
fi

# --- Install Docker Compose v2 (plugin 'docker compose') ---
if ! docker compose version >/dev/null 2>&1; then
  echo "⚙️ Installing Docker Compose v2 plugin..."
  $SUDO mkdir -p /usr/lib/docker/cli-plugins
  ARCH="$(uname -m)"
  OS="$(uname -s)"
  $SUDO curl -sSL "https://github.com/docker/compose/releases/latest/download/docker-compose-${OS}-${ARCH}" \
    -o /usr/lib/docker/cli-plugins/docker-compose
  $SUDO chmod +x /usr/lib/docker/cli-plugins/docker-compose
fi

# --- Clone repo (no auth prompt) ---
if [ ! -d "$CLONE_DIR" ]; then
  echo "📂 Cloning Giwa Node repository from: $REPO_URL"
  export GIT_TERMINAL_PROMPT=0
  git clone --depth 1 "$REPO_URL" "$CLONE_DIR"
fi

cd "$CLONE_DIR"

# --- Create .env.sepolia if not exists ---
if [ ! -f ".env.sepolia" ]; then
  echo "⚙️ Creating .env.sepolia file..."

  read -rp "👉 Enter your Ethereum L1 RPC URL: " L1_RPC
  read -rp "👉 Enter your Ethereum L1 Beacon URL: " L1_BEACON

  cat > .env.sepolia <<EOF
# Giwa Node Sepolia Configuration
NETWORK=sepolia
OP_NODE_L1_ETH_RPC=$L1_RPC
OP_NODE_L1_BEACON=$L1_BEACON

# Sync strategy (snap|archive|consensus)
SYNC_MODE=snap

# Optional: custom data dir (relative to project root)
# EXECUTION_DATA_DIR=./execution_data
EOF
fi

# --- Build & Run ---
echo "🔨 Building Docker containers..."
docker compose build --parallel

echo "🚀 Starting Giwa Node..."
NETWORK_ENV=.env.sepolia docker compose up -d

echo ""
echo "✅ Giwa Nod
