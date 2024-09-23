#!/bin/sh -e

clear

if ! command -v yay > /dev/null 2>&1 && ! command -v paru > /dev/null 2>&1
then
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si
    cd
fi

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

$su sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 5/' /etc/pacman.conf

$su sed -i 's/^Inherits=Adwaita$/Inherits=BreezeX-Black/' /usr/share/icons/default/index.theme

$su pacman -S --needed --noconfirm \
    maim bleachbit xorg-xsetroot xorgproto xorg-xset xorg-xrdb xorg-fonts-encodings \
    xorg-xrandr xorg-xprop xorg-setxkbmap xorg-server-common xorg-server xorg-xauth \
    xorg-xmodmap xorg-xkbcomp xorg-xinput xorg-xinit xorg-xhost fastfetch xclip \
    pipewire ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-liberation ttf-dejavu \
    ttf-fira-sans ttf-fira-mono pamixer polkit-kde-agent xdg-desktop-portal zip unzip \
    qt5-graphicaleffects qt5-quickcontrols2 noto-fonts-extra noto-fonts-cjk noto-fonts \
    cmatrix gtk3 neovim hsetroot

$aur_helper -S --needed --noconfirm \
    cava pipes.sh checkupdates-with-aur picom-ftlabs-git

rm -rf ~/suckless/

$su cp -R ~/dwm/extra/BreezeX-Black /usr/share/icons/
$su cp -R ~/dwm/extra/catppuccin-mocha /usr/share/themes/
cp -R ~/dwm/extra/cava ~/.config/
cp -R ~/dwm/extra/fastfetch ~/.config/
cp -R ~/dwm/extra/nvim ~/.config/ 
cp -R ~/dwm/extra/gtk-3.0 ~/.config/
cp -R ~/dwm/extra/picom ~/.config/
cp ~/dwm/extra/.xinitrc ~/
cp ~/dwm/extra/.bashrc ~/

mkdir -p ~/Documents
cp ~/dwm/extra/debloat.sh ~/Documents/
chmod +x ~/Documents/debloat.sh

cp -R ~/dwm/suckless ~/
cd ~/suckless/st && $su make clean install && cd
cd ~/suckless/dwm && $su make clean install && cd
cd ~/suckless/dmenu && $su make clean install && cd

if pacman -Q grub > /dev/null 2>&1; then
    $su cp -R ~/dwm/extra/grub/catppuccin-mocha-grub/ /usr/share/grub/themes/
    $su cp ~/dwm/extra/grub/grub /etc/default/
    $su grub-mkconfig -o /boot/grub/grub.cfg
fi

clear # Remove this line and re-run the script if you're encountering issues.

echo '(!) Installation complete.'
