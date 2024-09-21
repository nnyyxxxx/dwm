#!/bin/sh -e

if command -v yay > /dev/null 2>&1; then
    aur_helper="yay"
elif command -v paru > /dev/null 2>&1; then
    aur_helper="paru"
fi

if command -v sudo > /dev/null 2>&1; then
    su="sudo"
elif command -v doas > /dev/null 2>&1; then
    su="doas"
fi

$aur_helper --noconfirm

$su pacman -Rns "$(pacman -Qdtq)" --noconfirm

yes | $aur_helper -Scc