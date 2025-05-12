# vim: ft=sh

BLACK="\[\e[1;30m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
YELLOW="\[\e[1;33m\]"
BLUE="\[\e[1;34m\]"
PINK="\[\e[1;35m\]"
CYAN="\[\e[1;36m\]"
WHITE="\[\e[1;37m\]"
RESET="\[\e[m\]"

GIT_PS1="\$(__git_ps1 '(%s)')"

export PS1="${RED}[\u@\h ${BLUE}\W${CYAN}${GIT_PS1}${RED}]\$ ${RESET}"
export PS1_SSH="${BLUE}[\u@\h ${RED}\W${CYAN}${GIT_PS1}${BLUE}]\$ ${RESET}"
export PS1_NX="${WHITE}[\u@\h \W${CYAN}${GIT_PS1}${WHITE}]\$ ${RESET}"
export PS1_NL="${RED}[\u@\h ${BLUE}\W${CYAN}${GIT_PS1}${RED} *]\$ ${RESET}"
export PS1_NLSSH="${BLUE}[\u@\h ${RED}\W${CYAN}${GIT_PS1}${BLUE} *]\$ ${RESET}"

