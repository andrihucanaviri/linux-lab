# Semana 08: Comandos Usados

## mapfile
mapfile -t archivos < <(find "$REPO" -type f | sort)
Sirve para cargar archivos en un array.

## Arrays asociativos
declare -A conteo
Permite guardar datos tipo clave-valor.

## Matriz simulada
matriz[i*COLS+col]
Simula una matriz usando arrays.

## column
column -t
Alinea datos en columnas.

## printf
printf "%-10s"
Permite dar formato a la salida. 
