#!/usr/bin/env bash
# NixOS Update Manager for Waybar
# Replaces the Arch-specific update-manager.sh

# Colors
R='\033[0;31m'   # Red
G='\033[0;32m'   # Green
Y='\033[0;33m'   # Yellow
B='\033[0;34m'   # Blue
P='\033[0;35m'   # Purple
C='\033[0;36m'   # Cyan
W='\033[1;37m'   # White bold
D='\033[0;90m'   # Dim
N='\033[0m'      # Reset

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nixos-updates"
rm -f "$CACHE_DIR" 2>/dev/null; mkdir -p "$CACHE_DIR"

refresh_waybar() {
    pkill -SIGRTMIN+8 waybar 2>/dev/null || true
}

check_nixos_updates() {
    echo -e "\n${B}╭──────────────────────────────────────────────────────────────────╮${N}"
    echo -e "${B}│${N}  ${W}󱄅  NixOS Update Manager${N}                                         ${B}│${N}"
    echo -e "${B}╰──────────────────────────────────────────────────────────────────╯${N}\n"
    
    echo -e "${B}│  󰏗  NixOS System Updates                                         │${N}"
    echo -e "${B}╰──────────────────────────────────────────────────────────────────╯${N}"
    
    echo -ne "  ${D}󰍉 Checking for NixOS updates...${N}"
    
    # Check current and available nixpkgs version
    local current_rev=$(nix flake metadata /etc/nixos 2>/dev/null | grep "Locked URL" | grep -oP 'rev=\K[a-f0-9]+' | head -c 7)
    local latest_check=$(timeout 15 nix flake metadata nixpkgs --json 2>/dev/null | jq -r '.locked.rev // empty' 2>/dev/null | head -c 7)
    
    echo -e " ${G}󰄬${N}"
    
    if [[ -n "$current_rev" ]]; then
        echo -e "\n  ${W}Current nixpkgs:${N} ${C}$current_rev${N}"
    fi
    
    if [[ -n "$latest_check" && "$current_rev" != "$latest_check" ]]; then
        echo -e "  ${W}Latest nixpkgs:${N}  ${G}$latest_check${N} ${Y}(update available)${N}"
    else
        echo -e "  ${G}󰄬 System is up to date${N}"
    fi
    
    # Show current generation
    local current_gen=$(readlink /nix/var/nix/profiles/system | grep -oP 'system-\K\d+')
    echo -e "\n  ${D}Current generation: ${current_gen}${N}"
    
    # Count generations
    local gen_count=$(ls -1 /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l)
    echo -e "  ${D}Total generations: ${gen_count}${N}"
}

show_generations() {
    echo -e "\n${B}╭──────────────────────────────────────────────────────────────────╮${N}"
    echo -e "${B}│${N}  ${W}Recent Generations${N}                                              ${B}│${N}"
    echo -e "${B}╰──────────────────────────────────────────────────────────────────╯${N}\n"
    
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null | tail -10 | while read line; do
        if echo "$line" | grep -q "(current)"; then
            echo -e "  ${G}󰄬 $line${N}"
        else
            echo -e "  ${D}  $line${N}"
        fi
    done
}

show_menu() {
    echo -e "\n${B}╭──────────────────────────────────────────────────────────────────╮${N}"
    echo -e "${B}│${N}  ${W}Available Actions${N}                                                ${B}│${N}"
    echo -e "${B}╰──────────────────────────────────────────────────────────────────╯${N}\n"
    
    echo -e "    ${C}1${N}   Update flake inputs         ${D}nix flake update${N}"
    echo -e "    ${G}2${N}   Rebuild system              ${D}nixos-rebuild switch${N}"
    echo -e "    ${Y}3${N}   Update + Rebuild            ${D}Full update${N}"
    echo -e "    ${P}4${N}   Show generations            ${D}nix-env --list-generations${N}"
    echo -e "    ${B}5${N}   Garbage collect             ${D}nix-collect-garbage -d${N}"
    echo -e "    ${R}6${N}   Rollback to previous        ${D}nixos-rebuild --rollback${N}"
    echo -e ""
    echo -e "    ${D}q${N}   Quit"
    echo -e ""
    
    read -rp "  Select option: " choice
    
    case "$choice" in
        1)
            echo -e "\n${Y}󰁪 Updating flake inputs...${N}"
            sudo nix flake update /etc/nixos
            refresh_waybar
            ;;
        2)
            echo -e "\n${Y}󰁪 Rebuilding system...${N}"
            sudo nixos-rebuild switch --flake /etc/nixos#mnemosyne
            refresh_waybar
            ;;
        3)
            echo -e "\n${Y}󰁪 Updating and rebuilding...${N}"
            sudo nix flake update /etc/nixos && \
            sudo nixos-rebuild switch --flake /etc/nixos#mnemosyne
            refresh_waybar
            ;;
        4)
            show_generations
            read -rp "  Press Enter to continue..."
            show_menu
            ;;
        5)
            echo -e "\n${Y}󰁪 Running garbage collection...${N}"
            sudo nix-collect-garbage -d
            echo -e "${G}󰄬 Done${N}"
            ;;
        6)
            echo -e "\n${R}󰁪 Rolling back to previous generation...${N}"
            sudo nixos-rebuild --rollback switch
            refresh_waybar
            ;;
        q|Q)
            echo -e "\n${D}Goodbye!${N}\n"
            exit 0
            ;;
        *)
            echo -e "\n${R}Invalid option${N}"
            show_menu
            ;;
    esac
}

# Main
check_nixos_updates
show_menu
