#!/bin/bash

OUTPUT="sample.log"

echo "Generando $OUTPUT..."

for i in $(seq 1 500); do
echo "2026-02-15 12:00:00 | 192.168.1.10 | INFO | Test log entry $i" >> $OUTPUT
done 

echo "Generadas 500 entradas en $OUTPUT"
echo "Lineas: $(wc -l < $OUTPUT)"
