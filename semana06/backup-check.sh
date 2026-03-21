#!/bin/bash
readonly VERSION="1.0.0"
readonly DIR_BACKUP="${1:-/backup}"
readonly DIR_LOGS="$(dirname "$0")/logs"
readonly LOGFILE="$DIR_LOGS/backup-check-$(date +%Y%m%d).log"

estado_global="OK"
log() {
    local nivel="$1"
    local mensaje="$2"
    local timestamp

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    printf "[%s] [%-7s] %s\n" "$timestamp" "$nivel" "$mensaje" \
    | tee -a "$LOGFILE"
}
verificar_directorio() {

    log "INFO" "Verificando directorio"

    if [ ! -e "$DIR_BACKUP" ]; then
        log "ERROR" "Directorio no existe"
        return 1
    fi

    if [ ! -d "$DIR_BACKUP" ]; then
        log "ERROR" "No es directorio"
        return 1
    fi

    if [ ! -r "$DIR_BACKUP" ]; then
        log "ERROR" "Sin permisos"
        return 1
    fi

    log "OK" "Directorio correcto"
    return 0
}
verificar_archivos() {

    log "INFO" "Buscando backups"

    total=$(find "$DIR_BACKUP" -maxdepth 1 -type f -name "*.tar.gz" | wc -l)

    if [ "$total" -eq 0 ]; then
        log "ERROR" "No hay backups"
        return 1
    fi

    log "OK" "Backups encontrados: $total"
}
verificar_antiguedad() {

    log "INFO" "Verificando antigüedad"

    recientes=$(find "$DIR_BACKUP" -mtime -1 | wc -l)

    if [ "$recientes" -eq 0 ]; then
        log "WARNING" "No hay backups recientes"
    else
        log "OK" "Backups recientes encontrados"
    fi
}
verificar_tamanio() {

    log "INFO" "Verificando tamaño"

    tamanio=$(du -sm "$DIR_BACKUP" | awk '{print $1}')

    if [ "$tamanio" -lt 10 ]; then
        log "WARNING" "Backup muy pequeño"
    else
        log "OK" "Tamaño correcto"
    fi
}
mkdir -p "$DIR_LOGS"

log "INFO" "Inicio verificación"

verificar_directorio || exit 1
verificar_archivos
verificar_antiguedad
verificar_tamanio

log "INFO" "Fin verificación"
log "INFO" "=== Verificación completada ==="

case "$estado_global" in
    OK)
        log "OK" "RESULTADO: todo correcto"
        ;;
    WARNING)
        log "WARNING" "RESULTADO: con advertencias"
        ;;
    ERROR)
        log "ERROR" "RESULTADO: errores detectados"
        ;;
esac
