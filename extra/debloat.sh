#!/bin/sh -e

yay --noconfirm

sudo pacman -Rns $(pacman -Qtdq) --noconfirm

yes | yay -Scc