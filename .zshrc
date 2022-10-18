export ZSH="$HOME/.oh-my-zsh"

source $ZSH/oh-my-zsh.sh

alias sb="source ~/.zshrc"
alias eb="nvim ~/.zshrc && source ~/.zshrc && echo updated"

ZSH_THEME="eastwood"

alias py="python"
alias remote="ssh alchen@chvld-alchen2"
alias er="conda activate fio-app-edo-risk && cd ~/repos/edo-risk"
alias al="conda activate fio-app-alsenal && cd ~/repos/alsenal/fio/app/alsenal/scripts"
alias dgp="conda activate fio-app-desk-greek-publisher && cd ~/repos/desk-greek-publisher/"
alias egp="conda activate fio-app-edo-greek-publisher && cd ~/repos/edo-greek-publisher/"
alias sgu="conda activate fio-sol-greeks-utils && cd ~/repos/sol-greeks-utils/"
alias em="conda activate fio-edo-metrics && cd ~/repos/edo-metrics/"
alias ppb="conda activate fio-app-preliminary-price-bars && cd ~/repos/preliminary-price-bars"
alias is="conda activate instrument-service && cd ~/repos/instrument-service"
alias sy="conda activate fio-symbology && cd ~/repos/symbology/"
alias ks="cd ~/repos/k8s/"
alias nv="cd ~/.config/nvim/"
alias lg="lazygit"

CASE_SENSITIVE="true"






# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/alchen/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/alchen/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/alchen/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/alchen/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/home/alchen/miniconda3/etc/profile.d/mamba.sh" ]; then
    . "/home/alchen/miniconda3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<


export FIO_LOGGING_DISABLE_JSON=1

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  )

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
