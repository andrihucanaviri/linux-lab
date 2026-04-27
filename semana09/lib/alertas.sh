#!/bin/bash
# lib/alertas.sh - Funciones de logging y alertas

readonly COLOR_OK="\033[0;32m"
readonly COLOR_WARN="\033[0;33m"
readonly COLOR_ERR="\033[0;31m"
readonly COLOR_RST="\033[0m"

LOG_FILE="${LOG_FILE:-/tmp/monitor-procesos.log}"

log() {
    local nivel="$1"
    local mensaje="$2"
    local ts
    ts=$(date "+%Y-%m-%d %H:%M:%S")

    local linea="[$ts] [$nivel] $mensaje"

    # Guardar sin colores en archivo
    echo "$linea" >> "$LOG_FILE"

    # Mostrar con colores en pantalla
    case "$nivel" in
        OK)
            echo -e "${COLOR_OK}${linea}${COLOR_RST}"
            ;;
        WARNING)
            echo -e "${COLOR_WARN}${linea}${COLOR_RST}"
            ;;
        ERROR)
            echo -e "${COLOR_ERR}${linea}${COLOR_RST}"
            ;;
        *)
            echo "$linea"
            ;;
    esac
}

