#!/bin/bash

set -e

echo "=== Organizador de Archivos ==="
echo ""

echo "[1/4] Creando directorios..."
mkdir -p organized/{documents,images,scripts,config,logs,temp}
echo "Directorios creados"

echo "[2/4] Moviendo docuemntos..."
mv *.txt *.md *,doc organized/docuemnts/ 2>/dev/null || true

echo "[3/4] Moviendo imagenes..."
mv *.jpg *.png organized/images/ 2>/dev/null || true

echo "[4/4] Moviendo scripts..."
mv script_*.sh utilidad_*.py organized/scripts/ 2>/dev/null ||true

mv config_*.conf settings_+.json organized/config/ 2>/dev/null || true

mv *.log organized/logs/ 2>/dev/null || true

echo ""
echo "Organizacion completada"
