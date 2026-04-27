#!/usr/bin/env bash
# =============================================================================
# Hermes Cloud Brain — First-Run Bootstrap
# =============================================================================
# Run this ONCE on your VPS before `docker compose up -d`.
#
# What it does:
#   1. Creates required data directories
#   2. Copies .env.example → .env (if not exists)
#   3. Runs the interactive Hermes setup wizard
#   4. Prints next steps
#
# Usage:
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Hermes Cloud Brain — First-Run Bootstrap           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ─── Step 1: Create directories ──────────────────────────────────────────────
echo "▸ Creating data directories..."
mkdir -p hermes-data
mkdir -p open-webui-data
mkdir -p dozzle-data
mkdir -p code-server
echo "  ✓ Directories created"
echo ""

# ─── Step 2: Environment file ───────────────────────────────────────────────
if [ ! -f .env ]; then
    echo "▸ Copying .env.example → .env"
    cp .env.example .env
    echo "  ✓ .env created — EDIT IT NOW before continuing!"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │  Required: Open .env and fill in:                      │"
    echo "  │    • OPENROUTER_API_KEY                                │"
    echo "  │    • HERMES_API_SERVER_KEY  (openssl rand -hex 32)     │"
    echo "  │    • OPENWEBUI_SECRET_KEY   (openssl rand -hex 16)     │"
    echo "  │    • CODE_SERVER_PASSWORD                              │"
    echo "  │    • CADDY_ADMIN_HASH       (see .env for instructions)│"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    read -rp "  Press Enter after editing .env to continue, or Ctrl+C to abort..."
    echo ""
else
    echo "▸ .env already exists — skipping copy"
    echo ""
fi

# ─── Step 3: Hermes interactive setup ────────────────────────────────────────
echo "▸ Running Hermes setup wizard..."
echo "  This will configure OpenRouter, model selection, and SOUL.md."
echo "  Choose 'openrouter' as provider when prompted."
echo ""

docker run -it --rm \
    -v "$SCRIPT_DIR/hermes-data:/opt/data" \
    nousresearch/hermes-agent setup

echo ""
echo "  ✓ Hermes configured"
echo ""

# ─── Step 4: Verify master-gateway network ───────────────────────────────────
echo "▸ Checking for master-gateway Docker network..."
if docker network inspect master-gateway >/dev/null 2>&1; then
    echo "  ✓ master-gateway network exists"
else
    echo "  ✗ master-gateway network NOT found!"
    echo "    Your caddy-docker-proxy must create this network."
    echo "    Make sure your Caddy compose is running first."
    exit 1
fi
echo ""

# ─── Done ────────────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Bootstrap Complete!                      ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                            ║"
echo "║  Next steps:                                               ║"
echo "║                                                            ║"
echo "║  1. Verify .env is filled in correctly                     ║"
echo "║  2. Start the stack:                                       ║"
echo "║       docker compose up -d                                 ║"
echo "║                                                            ║"
echo "║  3. Open https://hermes.sentimentalk.com                   ║"
echo "║     → Sign up (first user = admin)                         ║"
echo "║                                                            ║"
echo "║  4. Verify Hermes connection in Open WebUI:                ║"
echo "║     → Admin Panel > Settings > Connections                 ║"
echo "║     → Check that Hermes model appears                     ║"
echo "║                                                            ║"
echo "║  5. Check logs:                                            ║"
echo "║       https://hermes-logs.sentimentalk.com                 ║"
echo "║                                                            ║"
echo "║  6. Maintenance IDE:                                       ║"
echo "║       https://hermes-code.sentimentalk.com                 ║"
echo "║                                                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
