# Semana 10: Gestión de Paquetes

## Objetivo

Instalar y configurar automáticamente el dev stack completo del curso usando técnicas profesionales: idempotencia, detección de OS, verificación y rollback.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| install-dev-stack.sh | Script principal de instalación |
| verify-install.sh | Verificación independiente del stack |
| rollback.sh | Desinstalación manual del stack |
| install.log | Log generado automáticamente |
| verification-report.md | Reporte de verificación generado |
| docs/packages.md | Lista y justificación de paquetes |

## Uso

```bash
# 1. Ejecutar instalación
sudo ./install-dev-stack.sh

# 2. Modo dry-run
bash ./install-dev-stack.sh --dry-run

# 3. Verificar instalación
./verify-install.sh

# 4. Rollback manual
sudo ./rollback.sh
