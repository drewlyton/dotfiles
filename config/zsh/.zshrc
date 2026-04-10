eval "$(/opt/homebrew/bin/brew shellenv)"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Increase open file limit
ulimit -n 4096
alias ssh-recsy-vps='ssh drew@64.71.152.76'
export TERM=xterm-256color

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(rbenv init - zsh)"

alias dsu="/Users/drew.lyton/Projects/delete-me/delete-staging-user/delete-staging-user.sh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/drew.lyton/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/drew.lyton/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/drew.lyton/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/drew.lyton/google-cloud-sdk/completion.zsh.inc'; fi

# bun completions
[ -s "/Users/drew/.bun/_bun" ] && source "/Users/drew/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# iCloud stuff
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/'

eval "$(zoxide init zsh)"

alias ts='~/.config/tmux/session-picker.sh'
alias cpf='~/.config/zsh/copy-file.sh'
export PATH="$HOME/.cargo/bin:$PATH"
# pnpm
export PNPM_HOME="/Users/drew.lyton/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.local/bin:$PATH"

# Source secrets (API tokens, etc.) - not tracked in dotfiles repo
[[ -f "${ZDOTDIR:-$HOME}/.secrets" ]] && source "${ZDOTDIR:-$HOME}/.secrets"
