#/bin/bash

LOGFILE="sample.log"

echo "=============================="
echo "ANALIZADOR DE LOGS"
echo "=============================="

echo "Archivo: $LOGFILE"
echo "Entradas: $(wc -l < $LOGFILE)"

echo ""
echo "TOP 10 DIRECCIONES IP"

cut -d'|' -f2 $LOGFILE | tr -d ' ' | sort | uniq -c | sort -rn | head -10 
