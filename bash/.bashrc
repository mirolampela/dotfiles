#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# eza: modern ls with icons and git status
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --git --group-directories-first'
alias tree='eza --tree --icons --level=2'

# bat: cat with syntax highlighting, uses terminal colors (Tokyo Night)
alias cat='bat --paging=never'
export BAT_THEME="ansi"

# colored man pages via bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$HOME/.local/bin:$PATH"
fastfetch
eval "$(starship init bash)"
