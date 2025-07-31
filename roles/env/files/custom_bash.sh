HISTSIZE=100000
HISTFILESIZE=100000
HISTFILE=/home/$USER/.bash_history
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="&:[ ]*:exit:ls *:bg:fg:history:clear:pwd:cd *"

# custom aliases
# set aliases simliar to pbcopy/pbpaste, cbc/cbp=cliboard copy/paste
alias cbc='xclip -sel clip'
alias cbp='xclip -sel clip -o'
alias dateu='date && date -u'
alias ipa='ip -4 a | awk '\''BEGIN {print ""} /^[0-9]+:/ {iface=$2; sub(":", "", iface); print "\033[1;33m" iface "\033[0m"} /inet / {split($2, ip, "/"); printf "  \033[1;36m%-15s\033[0m\n", ip[1]} END {print ""}'\'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias update='sudo apt update && sudo apt dist-upgrade -y && sudo snap refresh && sudo apt autoremove -y && sudo apt clean'
alias g='git'

# google search from the command line
google() {
  xdg-open "https://www.google.com/search?q=$*" >/dev/null 2>&1 &
}

# pipx autocomplete
eval "$(register-python-argcomplete pipx)"
