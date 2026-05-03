#!/bin/bash
# install-dev-stack.sh
# Instala y configura el dev stack del curso Linux
# Uso: sudo ./install-dev-stack.sh [--dry-run] [--verbose]

set -euo pipefail

# === CONSTANTES ===
readonly VERSION="1.0.0"
readonly LOG_FILE="install.log"
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# === COLORES ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# === FLAGS ===
DRY_RUN=false
VERBOSE=false

# === ESTADO ===
PAQUETES_INSTALADOS=()
PAQUETES_OMITIDOS=()
ERRORES=0

# === PROCESAR ARGUMENTOS ===
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true ;;
        --verbose) VERBOSE=true ;;
        --help|-h)
            echo "Uso: $0 [--dry-run] [--verbose]"
            echo "--dry-run   Mostrar que haría sin ejecutar"
            echo "--verbose   Salida detallada"
            exit 0
            ;;
        *)
            echo "Opción desconocida: $1"
            exit 1
            ;;
    esac
    shift
done

# === FUNCIONES DE LOG ===
log() {
    local nivel=$1
    shift
    local mensaje="$*"
    local linea="[$TIMESTAMP] [$nivel] $mensaje"

    echo "$linea" >> "$LOG_FILE"

    case $nivel in
        INFO) echo -e "${BLUE}[INFO]${NC} $mensaje" ;;
        OK) echo -e "${GREEN}[OK]${NC} $mensaje" ;;
        WARN) echo -e "${YELLOW}[WARN]${NC} $mensaje" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $mensaje" ;;
        STEP) echo -e "\n${BLUE}===== $mensaje =====${NC}" ;;
    esac
}

# === INICIAR LOG ===
echo "Dev Stack Installer v$VERSION" > "$LOG_FILE"
echo "Iniciado: $TIMESTAMP" >> "$LOG_FILE"
echo "-----------------------------------" >> "$LOG_FILE"
# === DETECCIÓN DE OS ===
detectar_os() {
    log STEP "Detectando sistema operativo"

    if [ -f /etc/os-release ]; then
    OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    OS_VERSION=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
else
    log ERROR "No se puede detectar el OS (/etc/os-release no existe)"
    exit 1
fi

    case $OS_ID in
        ubuntu|debian|linuxmint|pop)
            PKG_UPDATE="apt update -qq"
            PKG_INSTALL="apt install -y"
            PKG_CHECK="dpkg -l"
            log OK "OS soportado: $OS_NAME"
            ;;
        fedora|rhel|centos|rocky)
            PKG_UPDATE="dnf check-update -q || true"
            PKG_INSTALL="dnf install -y"
            PKG_CHECK="rpm -q"
            log WARN "OS Red Hat detectado. Algunos paquetes pueden diferir."
            ;;
        *)
            log ERROR "OS no soportado: $OS_ID"
            log INFO "Soportados: ubuntu, debian, linuxmint, fedora, rhel"
            exit 1
            ;;
    esac

    log INFO "OS: $OS_ID | Version: $OS_VERSION"
}

# === ROLLBACK ===
rollback() {
    local exit_code=$?
    if [ $exit_code -ne 0 ] && [ ${#PAQUETES_INSTALADOS[@]} -gt 0 ]; then
        log WARN "Error detectado. Iniciando rollback..."
        sudo apt purge -y "${PAQUETES_INSTALADOS[@]}" 2>/dev/null || true
        sudo apt autoremove -y 2>/dev/null || true
        log OK "Rollback completado. Paquetes revertidos: ${PAQUETES_INSTALADOS[*]}"
    fi
}

trap rollback EXIT

# === INSTALACIÓN ===
instalar_paquete() {
    local paquete=$1
    local descripcion=${2:-$paquete}

    if $DRY_RUN; then
        log INFO "[DRY-RUN] Se instalaría: $paquete"
        return 0
    fi

    if dpkg -l "$paquete" &>/dev/null; then
        local version
        version=$(dpkg -l "$paquete" | grep "^ii" | awk '{print $3}')
        log OK "$descripcion ya instalado (v$version) -- omitido"
        PAQUETES_OMITIDOS+=("$paquete")
    else
        log INFO "Instalando $descripcion ($paquete)..."
        if sudo $PKG_INSTALL "$paquete" >> "$LOG_FILE" 2>&1; then
            log OK "$descripcion instalado correctamente"
            PAQUETES_INSTALADOS+=("$paquete")
        else
            log ERROR "Falló al instalar $paquete"
            ERRORES=$((ERRORES + 1))
            return 1
        fi
    fi
}

# === DEV STACK ===
instalar_dev_stack() {
    log STEP "Actualizando lista de paquetes"

    if ! $DRY_RUN; then
        sudo $PKG_UPDATE >> "$LOG_FILE" 2>&1
        log OK "Lista de paquetes actualizada"
    fi

    log STEP "Instalando herramientas esenciales"
    instalar_paquete "git" "Git"
    instalar_paquete "curl" "curl"
    instalar_paquete "wget" "wget"
    instalar_paquete "vim" "Vim"
    instalar_paquete "tree" "tree"
    instalar_paquete "htop" "htop"
    instalar_paquete "jq" "jq"

    log STEP "Instalando entorno de desarrollo"
    instalar_paquete "python3" "Python 3"
    instalar_paquete "python3-pip" "pip3"
    instalar_paquete "build-essential" "build-essential"

    log STEP "Instalando utilidades del sistema"
    instalar_paquete "net-tools" "net-tools"
    instalar_paquete "unzip" "unzip"
    instalar_paquete "tmux" "tmux"
    instalar_paquete "shellcheck" "ShellCheck"
}
# === CONFIGURACIÓN GIT ===
configurar_git_global() {
    log STEP "Verificando configuración de Git"

    if git config --global user.name &>/dev/null; then
        log OK "Git ya configurado: $(git config --global user.name)"
    else
        log WARN "Git no tiene nombre de usuario configurado."
        log INFO "Ejecuta: git config --global user.name 'Tu Nombre'"
        log INFO "Ejecuta: git config --global user.email 'tu@email.com'"
    fi
}

# === RESUMEN FINAL ===
mostrar_resumen() {
    local total_nuevo=${#PAQUETES_INSTALADOS[@]}
    local total_omitido=${#PAQUETES_OMITIDOS[@]}

    echo ""
    echo "=============================="
    echo " RESUMEN DE INSTALACIÓN "
    echo "=============================="
    echo "Nuevos instalados: $total_nuevo"
    echo "Ya existían: $total_omitido"
    echo "Errores: $ERRORES"
    echo "=============================="

    if [ $ERRORES -eq 0 ]; then
        log OK "Instalación completada exitosamente"
        echo "Ejecuta: ./verify-install.sh"
    else
        log WARN "Instalación completada con errores"
        echo "Revisa install.log"
    fi
}
# === MAIN ===
main() {
    detectar_os
    instalar_dev_stack
    configurar_git_global
    mostrar_resumen
}

main "$@"
