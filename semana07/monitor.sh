#!/bin/bash

# monitor.sh - Monitor de recursos del sistema
# Semana 7: Ciclos en Bash

readonly VERSION="1.0.0"
readonly LOGFILE="monitor.log"

UMBRAL_DISCO=80
UMBRAL_RAM=85
INTERVALO=10
MAX_ITER=0

uso() {
    echo "Uso: $0 [opciones]"
    echo " --intervalo N      Segundos entre iteraciones"
    echo " --max N            Max. iteraciones (0=sin limite)"
    echo " --umbral-disco N   Alerta de disco en %"
    echo " --umbral-ram N     Alerta de RAM en %"
    echo " --version          Version"
    exit 2
}
# Procesar argumentos
while [ $# -gt 0 ]; do
    case "$1" in
        --intervalo) INTERVALO="$2"; shift 2 ;;
        --max) MAX_ITER="$2"; shift 2 ;;
        --umbral-disco) UMBRAL_DISCO="$2"; shift 2 ;;
        --umbral-ram) UMBRAL_RAM="$2"; shift 2 ;;
        --version) echo "monitor.sh v$VERSION"; exit 0 ;;
        --help|-h) uso ;;
        *) echo "Opcion desconocida: $1"; uso ;;
    esac
done
trap 'echo ""; resumen_log; registrar "INFO" "Monitor detenido por el usuario."; exit 0' INT
iteraccion=0
uso_disco() {
    df / | awk 'NR==2 {gsub(/%/,"",$5); print $5}'
}

uso_ram() {
    free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}'
}

carga_cpu() {
    uptime | awk -F'load average:' '{print $2}' | awk '{gsub(/,/,"",$1); print $1}'
}
registrar() {
    local nivel="$1"
    local mensaje="$2"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[%s] [%-7s] %s\n" "$ts" "$nivel" "$mensaje" | tee -a "$LOGFILE"
}

iteracion=0
> "$LOGFILE"
resumen_log() {
    echo ""
    echo "=================================="
    echo " RESUMEN DE LA SESION"
    echo "=================================="

    total=$((iteracion-1))
    alertas=$(grep -c "\[ALERTA" "$LOGFILE" 2>/dev/null || echo 0)

    printf "%-25s %d\n" "Comprobaciones:" "$total"
    printf "%-25s %d\n" "Alertas:" "$alertas"

    echo ""
    echo "Ultimas entradas:"

    tail -3 "$LOGFILE" | while IFS= read -r linea; do
        echo " $linea"
    done

    echo "=================================="
}

while true; do
    iteracion=$((iteracion + 1))

    if [ "$MAX_ITER" -gt 0 ] && [ "$iteracion" -gt "$MAX_ITER" ]; then
        registrar "INFO" "Limite de $MAX_ITER iteraciones alcanzado."
        break
    fi

    disco=$(uso_disco)
    ram=$(uso_ram)
    cpu=$(carga_cpu)

    registrar "INFO" "Iteracion $iteracion - Disco:${disco}% RAM:${ram}% CPU:${cpu}"

    if [ "$disco" -ge "$UMBRAL_DISCO" ]; then
        registrar "ALERTA" "Disco al ${disco}% (umbral ${UMBRAL_DISCO}%)"
    fi

    if [ "$ram" -ge "$UMBRAL_RAM" ]; then
        registrar "ALERTA" "RAM al ${ram}% (umbral ${UMBRAL_RAM}%)"
    fi

    sleep "$INTERVALO"
done
resumen_log
