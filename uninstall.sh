#!/bin/sh

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

warning() {
    if ! command -v pacman > /dev/null 2>&1; then
        printf "%b\n" "${RED}Automated uninstallation is only available for Arch-based distributions, uninstall manually.${RC}"
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

requestElevation() {
    if [ "$ESCALATION_TOOL" = "sudo" ]; then
        { sudo -v && clear; } || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
    elif [ "$ESCALATION_TOOL" = "doas" ]; then
        { doas true && clear; } || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
    fi
}

moveToHome() {
    cd "$HOME" || { printf "%b\n" "${RED}Failed to move to home directory.${RC}"; exit 1; }
}

declareFuncs() {
    DWM_DIR="$HOME/dwm"
    mkdir -p "$HOME/.config"
    XDG_CONFIG_HOME="$HOME/.config"
}

restoreSysOps() {
    printf "%b\n" "${YELLOW}Restoring Parallel Downloads...${RC}"
    $ESCALATION_TOOL sed -i 's/^ParallelDownloads = 5$/#ParallelDownloads = 5/' /etc/pacman.conf > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to restore ParallelDownloads in pacman.conf.${RC}"; }

    printf "%b\n" "${YELLOW}Restoring default cursor...${RC}"
    $ESCALATION_TOOL sed -i 's/^Inherits=BreezeX-Black$/Inherits=Adwaita/' /usr/share/icons/default/index.theme > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to restore default cursor.${RC}"; }
}

removeAutoLogin() {
    printf "%b\n" "${YELLOW}Removing TTY auto-login...${RC}"
    $ESCALATION_TOOL rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove TTY auto-login.${RC}"; }
}

removeDeps() {
    printf "%b\n" "${YELLOW}Removing dependencies...${RC}"
    printf "%b\n" "${YELLOW}This might take a minute or two...${RC}"

    $ESCALATION_TOOL pacman -Rns --noconfirm maim bleachbit \
    fastfetch xclip ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-liberation ttf-dejavu \
    ttf-fira-sans ttf-fira-mono polkit-kde-agent xdg-desktop-portal zip unzip qt5-graphicaleffects \
    qt5-quickcontrols2 noto-fonts-extra noto-fonts-cjk librewolf-bin cmatrix neovim hsetroot \
    pamixer mpv feh dash easyeffects qt5ct bashtop zoxide cava pipes.sh > /dev/null 2>&1
}

removeConfigurations() {
    printf "%b\n" "${YELLOW}Removing configuration files...${RC}"
    find "$XDG_CONFIG_HOME" -type l -exec rm {} + || { printf "%b\n" "${RED}Failed to remove configuration files.${RC}"; }

    printf "%b\n" "${YELLOW}Restoring old configuration files...${RC}"
    mv "$XDG_CONFIG_HOME/nvim-bak" "$XDG_CONFIG_HOME/nvim" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/qt5ct-bak" "$XDG_CONFIG_HOME/qt5ct" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/gtk-3.0-bak" "$XDG_CONFIG_HOME/gtk-3.0" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/fastfetch-bak" "$XDG_CONFIG_HOME/fastfetch" > /dev/null 2>&1
    mv "$XDG_CONFIG_HOME/cava-bak" "$XDG_CONFIG_HOME/cava" > /dev/null 2>&1

    rm -rf "$HOME/.xinitrc" "$HOME/Documents/debloat.sh" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove debloat.sh and .xinitrc.${RC}"; }

    $ESCALATION_TOOL rm -rf /usr/share/icons/BreezeX-Black /usr/share/themes/catppuccin-mocha > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove system-wide themes.${RC}"; }
    $ESCALATION_TOOL sed -i '/QT_QPA_PLATFORMTHEME=qt5ct/d' /etc/environment > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove QT_QPA_PLATFORMTHEME from environment.${RC}"; }
    $ESCALATION_TOOL ln -sf /bin/bash /bin/sh > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to restore symlink.${RC}"; }

    if [ -d /usr/share/grub/themes/catppuccin-mocha-grub ]; then
        $ESCALATION_TOOL rm -rf /usr/share/grub/themes/catppuccin-mocha-grub > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove GRUB theme.${RC}"; }
        $ESCALATION_TOOL sed -i '/GRUB_THEME/d' /etc/default/grub > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove GRUB theme from config.${RC}"; }
        $ESCALATION_TOOL grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to update GRUB config.${RC}"; }
    fi
}

uninstallSuckless() {
    printf "%b\n" "${YELLOW}Uninstalling suckless utils...${RC}"
    total_steps=3
    current_step=1

    { cd "$DWM_DIR/suckless/st" && $ESCALATION_TOOL make uninstall > /dev/null 2>&1 && cd - > /dev/null; } || { printf "%b\n" "${RED}Failed to uninstall st.${RC}"; }
    printf "%b\n" "${GREEN}st uninstalled (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    { cd "$DWM_DIR/suckless/dwm" && $ESCALATION_TOOL make uninstall > /dev/null 2>&1 && cd - > /dev/null; } || { printf "%b\n" "${RED}Failed to uninstall dwm.${RC}"; }
    printf "%b\n" "${GREEN}dwm uninstalled (${current_step}/${total_steps})${RC}"
    current_step=$((current_step + 1))

    { cd "$DWM_DIR/suckless/dmenu" && $ESCALATION_TOOL make uninstall > /dev/null 2>&1 && cd - > /dev/null; } || { printf "%b\n" "${RED}Failed to uninstall dmenu.${RC}"; }
    printf "%b\n" "${GREEN}dmenu uninstalled (${current_step}/${total_steps})${RC}"

    rm -rf "$HOME/dwm" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to remove dwm directory.${RC}"; exit 1; }
}

success() {
    printf "%b\n" "${YELLOW}Please reboot your system to apply the changes.${RC}"
    printf "%b\n" "${GREEN}Uninstallation complete.${RC}"
}

warning
setEscalationTool
requestElevation
moveToHome
declareFuncs
restoreSysOps
removeAutoLogin
removeDeps
removeConfigurations
uninstallSuckless
success