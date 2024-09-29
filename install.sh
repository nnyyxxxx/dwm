#!/bin/sh

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

warning() {
    if ! command -v pacman > /dev/null 2>&1; then
        printf "%b\n" "${RED}Automated installation is only available for Arch-based distributions, install manually.${RC}"
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
      { sudo -v && clear; } || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; }
  elif [ "$ESCALATION_TOOL" = "doas" ]; then
      { doas true && clear; } || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; }
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

declareFuncs() {
    DWM_DIR="$HOME/dwm"
    mkdir -p "$HOME/.config"
    XDG_CONFIG_HOME="$HOME/.config"
    USERNAME=$(whoami)
}

installAURHelper() {
    if ! command -v yay > /dev/null 2>&1 && ! command -v paru > /dev/null 2>&1; then
        $ESCALATION_TOOL pacman -S --needed --noconfirm base-devel > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install build dependencies.${RC}"; exit 1; }
        git clone https://aur.archlinux.org/yay-bin.git "$HOME/yay-bin" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to clone yay.${RC}"; }
        cd "$HOME/yay-bin"
        makepkg -si --noconfirm > /dev/null 2>&1
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
    $ESCALATION_TOOL sed -i 's/^#ParallelDownloads = 5$/ParallelDownloads = 5/' /etc/pacman.conf > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set Parallel Downloads.${RC}"; }

    printf "%b\n" "${YELLOW}Setting up default cursor...${RC}"
    $ESCALATION_TOOL mkdir -p /usr/share/icons/default
    $ESCALATION_TOOL touch /usr/share/icons/default/index.theme
    $ESCALATION_TOOL sed -i 's/^Inherits=Adwaita$/Inherits=BreezeX-Black/' /usr/share/icons/default/index.theme > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set breeze cursor.${RC}"; }
}

setupAutoLogin() {
    printf "%b\n" "${YELLOW}Setting up TTY auto-login for user ${USERNAME}...${RC}"
    
    $ESCALATION_TOOL mkdir -p /etc/systemd/system/getty@tty1.service.d
    echo "[Service]
    ExecStart=
    ExecStart=-/sbin/agetty --autologin ${USERNAME} --noclear %I \$TERM" | $ESCALATION_TOOL tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up TTY auto-login.${RC}"; }
}

installDeps() {
    printf "%b\n" "${YELLOW}Installing dependencies...${RC}"
    printf "%b\n" "${YELLOW}This might take a minute or two...${RC}"
    total_steps=2
    current_step=1

    $ESCALATION_TOOL pacman -Rns --noconfirm \
        sddm lightdm gdm lxdm lemurs emptty xorg-xdm ly pulseaudio > /dev/null 2>&1

    $ESCALATION_TOOL pacman -S --needed --noconfirm \
        maim bleachbit xorg-xsetroot xorgproto xorg-xset xorg-xrdb xorg-fonts-encodings \
        xorg-xrandr xorg-xprop xorg-setxkbmap xorg-server-common xorg-server xorg-xauth \
        xorg-xmodmap xorg-xkbcomp xorg-xinput xorg-xinit xorg-xhost fastfetch xclip \
        pipewire ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-liberation ttf-dejavu \
        ttf-fira-sans ttf-fira-mono polkit-kde-agent xdg-desktop-portal zip unzip \
        qt5-graphicaleffects qt5-quickcontrols2 noto-fonts-extra noto-fonts-cjk noto-fonts \
        cmatrix gtk3 neovim hsetroot pamixer vlc feh zsh dash pipewire-pulse easyeffects qt5ct \
        bashtop zoxide zsh-syntax-highlighting > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dependencies.${RC}"; }
    printf "%b\n" "${GREEN}Dependencies installed (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    $AUR_HELPER -S --needed --noconfirm \
        cava pipes.sh checkupdates-with-aur picom-ftlabs-git > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install AUR dependencies.${RC}"; }
    printf "%b\n" "${GREEN}AUR dependencies installed (${current_step}/${total_steps})${RC}"
}

setupConfigurations() {
    printf "%b\n" "${YELLOW}Setting up configuration files...${RC}"

    find "$HOME" -type l -exec rm {} + || { printf "%b\n" "${RED}Failed to remove symlinks.${RC}"; }

    mv "$XDG_CONFIG_HOME/nvim" "$XDG_CONFIG_HOME/nvim-bak" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/picom" "$XDG_CONFIG_HOME/picom-bak" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/qt5ct" "$XDG_CONFIG_HOME/qt5ct-bak" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0-bak" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/fastfetch" "$XDG_CONFIG_HOME/fastfetch-bak" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/cava" "$XDG_CONFIG_HOME/cava-bak" > /dev/null 2>&1
    mv "$HOME/.zshrc" "$HOME/.zshrc-bak" > /dev/null 2>&1
    mv "$HOME/.zprofile" "$HOME/.zprofile-bak" > /dev/null 2>&1

    $ESCALATION_TOOL mkdir -p /etc/zsh/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to create zsh directory.${RC}"; }
    $ESCALATION_TOOL touch /etc/zsh/zshenv > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to create zshenv.${RC}"; }
    echo "export ZDOTDIR=\"$HOME\"" | $ESCALATION_TOOL tee -a /etc/zsh/zshenv > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set ZDOTDIR.${RC}"; }
    ln -sf "$DWM_DIR/extra/.zshrc" "$HOME/.zshrc" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up .zshrc.${RC}"; }
    ln -sf "$DWM_DIR/extra/.zprofile" "$HOME/.zprofile" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up .zprofile.${RC}"; }
    touch "$HOME/.zlogin" "$HOME/.zshenv" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to create zlogin and zshenv.${RC}"; }

    $ESCALATION_TOOL cp -R "$DWM_DIR/extra/BreezeX-Black" /usr/share/icons/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up breeze cursor.${RC}"; }
    $ESCALATION_TOOL cp -R "$DWM_DIR/extra/gtk-3.0/catppuccin-mocha" /usr/share/themes/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up catppuccin-mocha theme.${RC}"; }
    ln -sf "$DWM_DIR/extra/cava" "$XDG_CONFIG_HOME/cava" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up cava configuration.${RC}"; }
    ln -sf "$DWM_DIR/extra/fastfetch" "$XDG_CONFIG_HOME/fastfetch" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up fastfetch configuration.${RC}"; }
    ln -sf "$DWM_DIR/extra/nvim" "$XDG_CONFIG_HOME/nvim" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up nvim configuration.${RC}"; }
    ln -sf "$DWM_DIR/extra/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up gtk-3.0 configuration.${RC}"; }
    ln -sf "$DWM_DIR/extra/picom" "$XDG_CONFIG_HOME/picom" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up picom configuration.${RC}"; }
    ln -sf "$DWM_DIR/extra/qt5ct" "$XDG_CONFIG_HOME/qt5ct" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up qt5ct.${RC}"; }
    ln -sf "$DWM_DIR/extra/.xinitrc" "$HOME/.xinitrc" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up .xinitrc.${RC}"; }

    echo "QT_QPA_PLATFORMTHEME=qt5ct" | $ESCALATION_TOOL tee -a /etc/environment > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set qt5ct in environment.${RC}"; }

    systemctl --user enable pipewire > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up pipewire.${RC}"; }
    systemctl --user enable pipewire-pulse > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up pipewire-pulse.${RC}"; }

    $ESCALATION_TOOL ln -sf /bin/dash /bin/sh > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to create symlink for sh.${RC}"; }
    $ESCALATION_TOOL usermod -s /bin/zsh "$USERNAME" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to change shell.${RC}"; }

    mkdir -p "$HOME/Documents" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to create Documents directory.${RC}"; }
    chmod +x "$DWM_DIR/extra/debloat.sh" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to make debloat.sh executable.${RC}"; }
    ln -sf "$DWM_DIR/extra/debloat.sh" "$HOME/Documents/debloat.sh" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up debloat.sh.${RC}"; }

    if pacman -Q grub > /dev/null 2>&1; then
        $ESCALATION_TOOL cp -R "$DWM_DIR/extra/grub/catppuccin-mocha-grub/" /usr/share/grub/themes/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up grub theme.${RC}"; }
        $ESCALATION_TOOL cp "$DWM_DIR/extra/grub/grub" /etc/default/ > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to set up grub configuration.${RC}"; }
        $ESCALATION_TOOL grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to generate grub configuration.${RC}"; }
    fi
}

compileSuckless() {
    printf "%b\n" "${YELLOW}Compiling suckless utils...${RC}"
    total_steps=3
    current_step=1

    { cd "$DWM_DIR/suckless/st" && $ESCALATION_TOOL make clean install > /dev/null 2>&1 && cd - > /dev/null; } || { printf "%b\n" "${RED}Failed to compile st.${RC}"; }
    printf "%b\n" "${GREEN}st compiled (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    { cd "$DWM_DIR/suckless/dwm" && $ESCALATION_TOOL make clean install > /dev/null 2>&1 && cd - > /dev/null; } || { printf "%b\n" "${RED}Failed to compile dwm.${RC}"; }
    printf "%b\n" "${GREEN}dwm compiled (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    { cd "$DWM_DIR/suckless/dmenu" && $ESCALATION_TOOL make clean install > /dev/null 2>&1 && cd - > /dev/null; } || { printf "%b\n" "${RED}Failed to compile dmenu.${RC}"; }
    printf "%b\n" "${GREEN}dmenu compiled (${current_step}/${total_steps})${RC}"
}

success() {
    printf "%b\n" "${YELLOW}Please reboot your system to apply the changes.${RC}"
    printf "%b\n" "${GREEN}Installation complete.${RC}"
}

warning
setEscalationTool
requestElevation
moveToHome
cloneRepo
declareFuncs
installAURHelper
setSysOps
setupAutoLogin
installDeps
setupConfigurations
compileSuckless
success
