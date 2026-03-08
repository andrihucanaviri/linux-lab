#!/usr/bin/env bash

# install.sh - instala los dotfiles

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/dotfiles" && pwd)"

instalar() {
    ln -sf "$DOTFILES_DIR/$1" "$HOME/.$1"
    echo "Instalado .$1"
}

instalar bashrc
instalar bash_aliases
instalar vimrc

echo "Instalación completa"
echo "Ejecuta: source ~/.bashrc"
