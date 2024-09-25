#!/bin/sh -e

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

warning() {
    if ! command -v pacman > /dev/null 2>&1; then
        printf "%b\n" "${RED}Automated installation is only available for Arch Linux, install manually.${RC}"
        exit 1
    fi
}

setEscalationTool() {
    if command -v sudo > /dev/null 2>&1; then
        ESCALATION_TOOL="sudo"
    elif command -v doas > /dev/null 2>&1; then
        ESCALATION_TOOL="doas"
    fi
}

# This is here only for aesthetics, without it the script will request elevation after printing the first print statement; and we don't want that.
requestElevation() {
  if [ "$ESCALATION_TOOL" = "sudo" ]; then
    sudo -v && clear || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
  elif [ "$ESCALATION_TOOL" = "doas" ]; then
    doas true && clear || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
  fi
}

# Moves the user to their home directory incase they are not already in it.
moveToHome() {
    cd "$HOME" || { printf "%b\n" "${RED}Failed to move to home directory.${RC}"; exit 1; }
}

cloneRepo() {
    printf "%b\n" "${YELLOW}Cloning repository...${RC}"
    rm -rf "$HOME/dwm" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove old dwm directory.${RC}"; exit 1; }
    $ESCALATION_TOOL pacman -S --needed --noconfirm git > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install git.${RC}"; exit 1; }
    git clone https://github.com/nnyyxxxx/dwm "$HOME/dwm" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to clone dwm.${RC}"; exit 1; }
}

installAURHelper() {
    if ! command -v yay > /dev/null 2>&1 && ! command -v paru > /dev/null 2>&1; then
        git clone https://aur.archlinux.org/yay-bin.git "$HOME/yay-bin" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to clone yay.${RC}"; exit 1; }
        cd "$HOME/yay-bin"
        makepkg -si > /dev/null 2>&1
        cd "$HOME"
        rm -rf "$HOME/yay-bin"
    fi

    if command -v yay > /dev/null 2>&1; then
        AUR_HELPER="yay"
    elif command -v paru > /dev/null 2>&1; then
        AUR_HELPER="paru"
    fi
}

setSysOps() {
    printf "%b\n" "${YELLOW}Setting up Parallel Downloads...${RC}"
    $ESCALATION_TOOL sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 5/' /etc/pacman.conf > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set Parallel Downloads.${RC}"; exit 1; }

    printf "%b\n" "${YELLOW}Setting up default cursor...${RC}"
    $ESCALATION_TOOL sed -i 's/^Inherits=Adwaita$/Inherits=BreezeX-Black/' /usr/share/icons/default/index.theme > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set breeze cursor.${RC}"; exit 1; }
}

setupAutoLogin() {
    USERNAME=$(whoami)
    printf "%b\n" "${YELLOW}Setting up TTY auto-login for user ${USERNAME}...${RC}"
    
    $ESCALATION_TOOL mkdir -p /etc/systemd/system/getty@tty1.service.d
    echo "[Service]
    ExecStart=
    ExecStart=-/sbin/agetty --autologin ${USERNAME} --noclear %I \$TERM" | $ESCALATION_TOOL tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up TTY auto-login.${RC}"; exit 1; }
}

installDeps() {
    printf "%b\n" "${YELLOW}Installing dependencies...${RC}"
    total_steps=2
    current_step=1

    $ESCALATION_TOOL pacman -S --needed --noconfirm \
        maim bleachbit xorg-xsetroot xorgproto xorg-xset xorg-xrdb xorg-fonts-encodings \
        xorg-xrandr xorg-xprop xorg-setxkbmap xorg-server-common xorg-server xorg-xauth \
        xorg-xmodmap xorg-xkbcomp xorg-xinput xorg-xinit xorg-xhost fastfetch xclip \
        pipewire ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-liberation ttf-dejavu \
        ttf-fira-sans ttf-fira-mono polkit-kde-agent xdg-desktop-portal zip unzip \
        qt5-graphicaleffects qt5-quickcontrols2 noto-fonts-extra noto-fonts-cjk noto-fonts \
        cmatrix gtk3 neovim hsetroot pamixer vlc > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dependencies.${RC}"; exit 1; }
    printf "%b\n" "${GREEN}Dependencies installed (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    $AUR_HELPER -S --needed --noconfirm \
        cava pipes.sh checkupdates-with-aur picom-ftlabs-git > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install AUR dependencies.${RC}"; exit 1; }
    printf "%b\n" "${GREEN}AUR dependencies installed (${current_step}/${total_steps})${RC}"
}

setupConfigurations() {
    printf "%b\n" "${YELLOW}Setting up configuration files...${RC}"

    rm -rf "$HOME/suckless" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove old suckless directory.${RC}"; exit 1; }

    $ESCALATION_TOOL cp -R "$HOME/dwm/extra/BreezeX-Black" /usr/share/icons/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up breeze cursor.${RC}"; exit 1; }
    $ESCALATION_TOOL cp -R "$HOME/dwm/extra/catppuccin-mocha" /usr/share/themes/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up catppuccin-mocha theme.${RC}"; exit 1; }
    cp -R "$HOME/dwm/extra/cava" "$HOME/.config/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up cava configuration.${RC}"; exit 1; }
    cp -R "$HOME/dwm/extra/fastfetch" "$HOME/.config/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up fastfetch configuration.${RC}"; exit 1; }
    cp -R "$HOME/dwm/extra/nvim" "$HOME/.config/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up nvim configuration.${RC}"; exit 1; }
    cp -R "$HOME/dwm/extra/gtk-3.0" "$HOME/.config/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up gtk-3.0 configuration.${RC}"; exit 1; }
    cp -R "$HOME/dwm/extra/picom" "$HOME/.config/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up picom configuration.${RC}"; exit 1; }
    cp "$HOME/dwm/extra/.xinitrc" "$HOME/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up .xinitrc.${RC}"; exit 1; }
    cp "$HOME/dwm/extra/.bashrc" "$HOME/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up .bashrc.${RC}"; exit 1; }
    cp "$HOME/dwm/extra/.bash_profile" "$HOME/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up .bash_profile.${RC}"; exit 1; }

    mkdir -p "$HOME/Documents" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to create Documents directory.${RC}"; exit 1; }
    cp "$HOME/dwm/extra/debloat.sh" "$HOME/Documents/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up debloat.sh.${RC}"; exit 1; }
    chmod +x "$HOME/Documents/debloat.sh" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to make debloat.sh executable.${RC}"; exit 1; }

    cp -R "$HOME/dwm/suckless" "$HOME/" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up suckless directory.${RC}"; exit 1; }

    if pacman -Q grub > /dev/null 2>&1; then
        $ESCALATION_TOOL cp -R "$HOME/dwm/extra/grub/catppuccin-mocha-grub/" /usr/share/grub/themes/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up grub theme.${RC}"; exit 1; }
        $ESCALATION_TOOL cp "$HOME/dwm/extra/grub/grub" /etc/default/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up grub configuration.${RC}"; exit 1; }
        $ESCALATION_TOOL grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to generate grub configuration.${RC}"; exit 1; }
    fi
}

compileSuckless() {
    printf "%b\n" "${YELLOW}Compiling suckless utils...${RC}"
    total_steps=3
    current_step=1

    cd "$HOME/suckless/st" && $ESCALATION_TOOL make clean install > /dev/null 2>&1 && cd || { printf "%b\n" "${RED}Failed to compile st.${RC}"; exit 1; }
    printf "%b\n" "${GREEN}st compiled (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    cd "$HOME/suckless/dwm" && $ESCALATION_TOOL make clean install > /dev/null 2>&1 && cd || { printf "%b\n" "${RED}Failed to compile dwm.${RC}"; exit 1; }
    printf "%b\n" "${GREEN}dwm compiled (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    cd "$HOME/suckless/dmenu" && $ESCALATION_TOOL make clean install > /dev/null 2>&1 && cd || { printf "%b\n" "${RED}Failed to compile dmenu.${RC}"; exit 1; }
    printf "%b\n" "${GREEN}dmenu compiled (${current_step}/${total_steps})${RC}"
}

success() {
    printf "%b\n" "${GREEN}Installation complete.${RC}"
}

warning
setEscalationTool
requestElevation
moveToHome
cloneRepo
installAURHelper
setSysOps
setupAutoLogin
installDeps
setupConfigurations
compileSuckless
success
