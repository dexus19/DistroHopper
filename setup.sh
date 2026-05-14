#!/usr/bin/env bash
# =============================================================================
#  setup.sh — Cross-distro bootstrap script
#  Supports: apt · dnf · pacman · zypper
#  Author: WAN
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()     { echo -e "${GREEN}[✔]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✘]${RESET} $*"; exit 1; }
section() { echo -e "\n${CYAN}${BOLD}══ $* ══${RESET}"; }

# ── Detect package manager ────────────────────────────────────────────────────
detect_pm() {
    if   command -v apt    &>/dev/null; then PM="apt"
    elif command -v dnf    &>/dev/null; then PM="dnf"
    elif command -v pacman &>/dev/null; then PM="pacman"
    elif command -v zypper &>/dev/null; then PM="zypper"
    else error "No supported package manager found (apt/dnf/pacman/zypper)."
    fi
    log "Detected package manager: ${BOLD}$PM${RESET}"
}

# ── Package manager wrappers ──────────────────────────────────────────────────
pm_update() {
    case $PM in
        apt)    sudo apt update -y ;;
        dnf)    sudo dnf check-update -y || true ;;
        pacman) sudo pacman -Sy --noconfirm ;;
        zypper) sudo zypper refresh ;;
    esac
}

pm_install() {
    case $PM in
        apt)    sudo apt install -y "$@" ;;
        dnf)    sudo dnf install -y "$@" ;;
        pacman) sudo pacman -S --noconfirm --needed "$@" ;;
        zypper) sudo zypper install -y "$@" ;;
    esac
}

# ── Per-distro package name map ───────────────────────────────────────────────
# Maps logical names → distro-specific package names
resolve_pkg() {
    local pkg="$1"
    case $PM in
        apt)
            case $pkg in
                btop)     echo "btop" ;;
                fish)     echo "fish" ;;
                fzf)      echo "fzf" ;;
                ffmpeg)   echo "ffmpeg" ;;
                flatpak)  echo "flatpak" ;;
                yt-dlp)   echo "yt-dlp" ;;
                handbrake) echo "handbrake" ;;
                *)        echo "$pkg" ;;
            esac ;;
        dnf)
            case $pkg in
                btop)     echo "btop" ;;
                fish)     echo "fish" ;;
                fzf)      echo "fzf" ;;
                ffmpeg)   echo "ffmpeg" ;;       # needs RPM Fusion
                flatpak)  echo "flatpak" ;;
                yt-dlp)   echo "yt-dlp" ;;
                handbrake) echo "HandBrake-gui" ;;
                *)        echo "$pkg" ;;
            esac ;;
        pacman)
            case $pkg in
                btop)     echo "btop" ;;
                fish)     echo "fish" ;;
                fzf)      echo "fzf" ;;
                ffmpeg)   echo "ffmpeg" ;;
                flatpak)  echo "flatpak" ;;
                yt-dlp)   echo "yt-dlp" ;;
                handbrake) echo "handbrake" ;;
                *)        echo "$pkg" ;;
            esac ;;
        zypper)
            case $pkg in
                btop)     echo "btop" ;;
                fish)     echo "fish" ;;
                fzf)      echo "fzf" ;;
                ffmpeg)   echo "ffmpeg" ;;
                flatpak)  echo "flatpak" ;;
                yt-dlp)   echo "yt-dlp" ;;
                handbrake) echo "handbrake" ;;
                *)        echo "$pkg" ;;
            esac ;;
    esac
}

# ── Install apps ──────────────────────────────────────────────────────────────
install_apps() {
    section "Installing Packages"

    local APPS=(git curl wget btop fish fzf ffmpeg flatpak yt-dlp handbrake)
    local to_install=()

    for app in "${APPS[@]}"; do
        local pkg
        pkg=$(resolve_pkg "$app")
        # Skip if the primary binary is already available
        if command -v "$app" &>/dev/null; then
            warn "$app already installed — skipping."
        else
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log "Installing: ${to_install[*]}"
        pm_install "${to_install[@]}"
    else
        log "All packages already installed."
    fi

    # Enable Flatpak remote if flatpak was just set up
    if command -v flatpak &>/dev/null; then
        if ! flatpak remotes | grep -q flathub; then
            log "Adding Flathub remote..."
            flatpak remote-add --if-not-exists flathub \
                https://dl.flathub.org/repo/flathub.flatpakrepo || true
        fi
    fi
}

# ── Aliases ───────────────────────────────────────────────────────────────────
setup_aliases() {
    section "Setting Up Aliases"

    # ── The alias block ──────────────────────────────────────────────────────
    local ALIAS_BLOCK
    ALIAS_BLOCK=$(cat <<'ALIASES'

# ── WAN's aliases ────────────────────────────────────────── added by setup.sh ──

## Navigation
alias ll='ls -lhF --color=auto'
alias la='ls -lAhF --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

## Package manager abstractions (auto-detected at runtime)
_pm() {
    if   command -v apt    &>/dev/null; then echo apt
    elif command -v dnf    &>/dev/null; then echo dnf
    elif command -v pacman &>/dev/null; then echo pacman
    elif command -v zypper &>/dev/null; then echo zypper
    fi
}
alias update='
    case $(_pm) in
        apt)    sudo apt update -y && sudo apt upgrade -y ;;
        dnf)    sudo dnf upgrade -y ;;
        pacman) sudo pacman -Syu --noconfirm ;;
        zypper) sudo zypper refresh && sudo zypper update -y ;;
    esac'
alias install='
    case $(_pm) in
        apt)    sudo apt install -y ;;
        dnf)    sudo dnf install -y ;;
        pacman) sudo pacman -S --noconfirm --needed ;;
        zypper) sudo zypper install -y ;;
    esac'
alias remove='
    case $(_pm) in
        apt)    sudo apt remove -y ;;
        dnf)    sudo dnf remove -y ;;
        pacman) sudo pacman -Rns ;;
        zypper) sudo zypper remove -y ;;
    esac'
alias search='
    case $(_pm) in
        apt)    apt search ;;
        dnf)    dnf search ;;
        pacman) pacman -Ss ;;
        zypper) zypper search ;;
    esac'

## System shortcuts
alias df='df -hT'
alias du='du -sh *'
alias free='free -h'
alias ps='ps aux'
alias top='btop'
alias ports='ss -tulpn'
alias myip='curl -s https://ifconfig.me && echo'

## Safety nets
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -pv'

# ── end WAN's aliases ─────────────────────────────────────────────────────────
ALIASES
)

    local shells=()
    [[ -f "$HOME/.bashrc" ]] && shells+=("$HOME/.bashrc")
    [[ -f "$HOME/.zshrc"  ]] && shells+=("$HOME/.zshrc")
    [[ ${#shells[@]} -eq 0 ]] && { warn "No .bashrc or .zshrc found — creating .bashrc"; touch "$HOME/.bashrc"; shells+=("$HOME/.bashrc"); }

    for rc in "${shells[@]}"; do
        if grep -q "WAN's aliases" "$rc" 2>/dev/null; then
            warn "Aliases already present in $rc — skipping."
        else
            echo "$ALIAS_BLOCK" >> "$rc"
            log "Aliases appended to $rc"
        fi
    done

    # Also append to fish config if fish is installed
    local fish_cfg="$HOME/.config/fish/config.fish"
    if command -v fish &>/dev/null; then
        mkdir -p "$(dirname "$fish_cfg")"
        if ! grep -q "WAN's aliases" "$fish_cfg" 2>/dev/null; then
            cat >> "$fish_cfg" <<'FISH_ALIASES'

# ── WAN's aliases (fish) ───────────────── added by setup.sh ──
abbr --add ll  'ls -lhF'
abbr --add la  'ls -lAhF'
abbr --add l   'ls -CF'
abbr --add ..  'cd ..'
abbr --add ... 'cd ../..'
abbr --add df  'df -hT'
abbr --add du  'du -sh *'
abbr --add free 'free -h'
abbr --add top  'btop'
abbr --add ports 'ss -tulpn'
abbr --add myip 'curl -s https://ifconfig.me'
# ── end WAN's aliases (fish) ──────────────────────────────────
FISH_ALIASES
            log "Fish abbreviations appended to $fish_cfg"
        else
            warn "Fish aliases already present — skipping."
        fi
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    echo -e "${CYAN}${BOLD}"
    echo "  ┌──────────────────────────────────────┐"
    echo "  │        WAN's Distro Bootstrap        │"
    echo "  │   apt · dnf · pacman · zypper        │"
    echo "  └──────────────────────────────────────┘"
    echo -e "${RESET}"

    detect_pm
    pm_update
    install_apps
    setup_aliases

    section "Done"
    log "Bootstrap complete! Run ${BOLD}source ~/.bashrc${RESET} (or restart your shell) to load aliases."
}

main "$@"
