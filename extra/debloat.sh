#!/bin/bash

if command -v yay &> /dev/null; then
    aur_helper="yay"
elif command -v paru &> /dev/null; then
    aur_helper="paru"
fi

if command -v sudo &> /dev/null; then
    su="sudo"
elif command -v doas &> /dev/null; then
    su="doas"
fi

$aur_helper --noconfirm

$su pacman -Rns $(pacman -Qdtq) --noconfirm

yes | $aur_helper -Scc