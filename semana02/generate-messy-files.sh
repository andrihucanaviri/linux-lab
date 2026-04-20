# !/bin/bash

  echo "Generando 50 archivos mezclados..."

# Documentos (15 archivos)
  for i in {1..5}; do
      echo "Documento de prueba $i" > "documento_$i.txt"
  done

  for i in {1..5}; do
      echo "# Notas $i > "notas_$i.md"
  done

  for i in {1..5}; do
      echo "Reporte $i > "reporte_$i.doc"
  done

# Imagenes (10 archivos)
  for i in {1..5}; do
      echo "FAKE JPG DATA" > "foto_$i.jpg"
  done

  for i in {1..5}; do
      echo "FAKE PNG DATA" > "screenshot_$i.png"
  done

# Scripts (10 archivos)
  for i in {1..5}; do
      echo '#!/bin/bash' > "scrips_$i.sh"
      echo "echo 'Script numero $i'" >> "script_$i.sh"
  done

  for i in {1..5}; do
      echo '#!/usr/bin/env python3' > "utilidad_$i.py"
      echo "print('Python script $i')" >>"utilidad_$i.py"
  done

# Configuraciones (8 archivos)
  for i in {1..4}; do
      echo "key=value$i" > "config_$i.conf"
      echo "setting$i=true" >> "config_$i.conf"
  done

  for i in {1..4}; do
      echo "{\"setting\": $i}" > "settings_$i.json"
  done

# Logs (7 archivos)
  for i in {1..4}; do
      date >> "sistema_$i.log"
      echo "ERROR: Error de prueba $i" >> "sistema_$i.log"
  done

  for i in {1..3}; do
      echo "[$(date)] Evento $i" > "app_$i.log"
      echo "[$(date)] INFO: Informacion" >> "app_$i.log"
  done

  echo "      50 archivos creados exitosamente"
  echo "Archivos totales: $(ls -1 | wc -1)" 

