
DISABLE_AUTO_UPDATE="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#484E5B,underline"

plugins=(git)

export PATH=~/.local/bin:~/.cargo/bin:$PATH
export THEME="LateForLunch"
# ~/.config/console_colors.sh

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
autoload -Uz vcs_info
zstyle ':vcs_info:git*' formats "%r on %b⎇ "
precmd() {
    vcs_info
}
setopt prompt_subst
# PROMPT="%B%{$fg[cyan]%}%n%{$reset_color%}%B @ %{$fg[magenta]%}%m%{$fg[magenta]%} ~%{$fg[blue]%}❯%{$fg[magenta]%}❯%{$fg[cyan]%}❯ "
# PROMPT="%B%'{e[54m%}'%n%{$reset_color%}%B @ %{$fg[magenta]%}%m%{$fg[magenta]%} ~%{$fg[black]%}>%{$fg[magenta]%}>%{$fg[cyan]%}> "
PROMPT=$'%B%{\e[80m%}%n%{$reset_color%}%B @ %{$fg[magenta]%}%m%{$fg[magenta]%} ~%{\e[94m%}>%{\e[93m%}>%{\e[91m%}> '
RPROMPT='%{$fg[green]%}${vcs_info_msg_0_}'

stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments
setopt notify
setopt numericglobsort

# History in cache directory:
export HISTSIZE=500000
export SAVEHIST=500000

HISTFILE="$HOME/.zsh_history"

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

bindkey -s '^f' 'cd "$(dirname "$(fzf)")"\n'
bindkey '^[[P' delete-char

# Edit line in vim with ctrl-v:
autoload edit-command-line; zle -N edit-command-line
bindkey '^v' edit-command-line

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd/mm/yyyy"

# Cursor
echo -e -n "\x1b[\x31 q" # changes to blinking block also

# Find new executables in path
zstyle ':completion:*' rehash true

# Freeze and unfreeze processes (for example: stop firefox)
stop(){
  if [ $# -ne 1 ]; then
          echo 1>&2 Usage: stop process
  else
    PROCESS=$1
    echo "Stopping processes with the word ${tGreen}$1${tReset}"
    ps axw | grep -i $1 | awk -v PROC="$1" '{print $1}' | xargs kill -STOP
  fi
}

cont(){
  if [ $# -ne 1 ]; then
          echo 1>&2 Usage: cont process
  else
    PROCESS=$1
    echo "Continuing processes with the word ${tGreen}$1${tReset}"
    ps axw | grep -i $1 | awk -v PROC="$1" '{print $1}' | xargs kill -CONT
  fi
}

export EDITOR='hx'
export BROWSER='firefox-developer-edition'
export LUA='luajit'

#aliases
alias ls='exa --color=auto --group-directories-first --icons'
alias la='exa --color=auto --group-directories-first --icons -al'
alias mv='mv -v'
alias cp='cp -v'
alias rm='rm -v'
alias getsong='yt-dlp -f worstvideo+bestaudio --extract-audio --audio-format mp3 --embed-thumbnail --embed-metadata'
# alias vim='lvim'

## init starship
# eval "$(starship init zsh)"
## setup starship custom prompt
# export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

# Load plugins; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /etc/profile.d/debuginfod.sh # for valgrind



export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
