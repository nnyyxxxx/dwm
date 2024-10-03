#!/bin/sh

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'

warning() {
    if ! command -v pacman > /dev/null 2>&1; then
        printf "%b\n" "${RED}Automated updates are only available for Arch-based distributions, update manually.${RC}"
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

declareFuncs() {
    DWM_DIR="$HOME/dwm"
}

checkUserChanges() {
    if [ -n "$(git diff)" ]; then
        printf "%b" "${YELLOW}Do you want to save your changes? (Y/n): ${RC}"
        read -r input
        case $input in
            n|N)
                SAVE_USER_CHANGES=0
                ;;
            *)
                SAVE_USER_CHANGES=1
                ;;
        esac
    else
        SAVE_USER_CHANGES=0
    fi
}

saveUserChanges() {
    if [ "$SAVE_USER_CHANGES" -eq 1 ]; then
        printf "%b\n" "${YELLOW}Saving user changes...${RC}"
        git stash > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to stash the changes.${RC}"; exit 1; }
    fi
}

updateRepository() {
    printf "%b\n" "${YELLOW}Updating...${RC}"
    git fetch origin main > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to fetch the repository.${RC}"; exit 1; }
    git reset --hard origin/main > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to reset the repository.${RC}"; exit 1; }
    git pull --rebase origin main > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to pull the repository.${RC}"; exit 1; }
}

reapplyUserChanges() {
    if [ "$SAVE_USER_CHANGES" -eq 1 ]; then
        printf "%b\n" "${YELLOW}Re-applying user changes...${RC}"
        git stash pop > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to pop the stash.${RC}"
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
    printf "%b\n" "${GREEN}Update complete.${RC}"
}

warning
setEscalationTool
requestElevation
declareFuncs
checkUserChanges
saveUserChanges
updateRepository
reapplyUserChanges
compileSuckless
success