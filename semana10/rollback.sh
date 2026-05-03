#!/bin/bash
# rollback.sh - Desinstala el dev stack instalado por install-dev-stack.sh

set -euo pipefail

PAQUETES=(
    git
    curl
    wget
    vim
    tree
    htop
    jq
    net-tools
    python3
    python3-pip
    build-essential
    unzip
    tmux
    shellcheck
)

echo "========================================"
echo " ROLLBACK: Desinstalación del Dev Stack "
echo "========================================"
echo ""
echo "ADVERTENCIA: Esto desinstalará los siguientes paquetes:"
printf '%s\n' "${PAQUETES[@]}"
echo ""

read -rp "Confirmar desinstalación? [s/N]: " respuesta

if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo ""
    echo "Desinstalando paquetes..."
    sudo apt purge -y "${PAQUETES[@]}" 2>/dev/null || true
    sudo apt autoremove -y
    sudo apt clean
    echo ""
    echo "[OK] Rollback completado."
else
    echo "Operación cancelada."
    exit 0
fi
