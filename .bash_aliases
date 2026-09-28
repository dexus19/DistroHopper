#!/usr/bin/env bash
# Personal aliases. Copy this file to ~/.bash_aliases on another Bash system.

# Color support
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Listing and navigation
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Package management (Debian/Ubuntu)
alias update='sudo apt update'
alias upgrade='sudo apt upgrade -y'
alias update-upgrade='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias purge='sudo apt purge'
alias search='apt search'
alias autoremove='sudo apt autoremove -y'
alias clean='sudo apt clean && sudo apt autoclean'
alias list-installed='dpkg --get-selections | grep -v deinstall'

# System
alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'
alias services='systemctl list-units --type=service'
alias ports='ss -tulnp'
alias myip='curl ifconfig.me'

# Files and directories
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# Disk and memory
alias df='df -h'
alias du='du -sh *'
alias free='free -h'

# Tailscale
alias nodedown='sudo tailscale set --exit-node='
alias nodeup='sudo tailscale set --exit-node=100.105.164.41'
alias tsu='sudo tailscale up'
alias tsd='sudo tailscale down'
alias tss='tailscale status'

# History and notifications
alias h='history'
alias hg='history | grep'
alias alert='notify-send --urgency=low -i "$( [ $? = 0 ] && echo terminal || echo error )" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
