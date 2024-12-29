starship init fish | source

set fish_color_error red --bold
set fish_color_command 55FFFF
function fish_greeting
    echo \<$hostname\> Welcome to Fish Allen. Lets get some work done. | lolcat
end

alias sb="source ~/.config/fish/config.fish"
alias eb="nvim ~/.config/fish/config.fish"

alias py="python"
alias lg="lazygit"
alias cde="conda deactivate"

alias r="cd ~/repos/"
alias d="cd ~/Downloads/"
alias n="nvim"
alias cvim="cd ~/.config/nvim/ && nvim ./init.lua"
alias nv="neovide --fork && exit"

function conda-init -d "initialize conda shell functions"
    if type conda | grep -q alias
        echo "initializing conda..."
        eval /home/alchen/miniconda3/bin/conda "shell.fish" hook $argv | source
    end
end

function python3 -d python3
    conda-init
    functions -e python3
    python3 $argv
end

function py -d python3
    conda-init
    functions -e py
    alias py python3
    python3 $argv
end

function ipy -d ipython
    conda-init
    functions -e ipy
    ipython $argv
    alias ipy ipython
end

alias conda="conda-init; conda"


function bright -d "Adjust brightness for specified outputs"
    for output in DP-0
        xrandr --output $output --brightness $argv[1]
    end
end

# Loop through the array and add paths to PATH if they are not already there
set -l custom_paths \
    "/home/alchen/.ghcup/bin" \
    "/home/alchen/.cabal/bin" \
    "/home/alchen/.modular" \
    "/usr/local/go/bin" \
    "/home/alchen/bin", \
	"/home/alchen/.npm/", \
	"/snap/node/current/bin/"

for path in $custom_paths
    if not string match -q "*$path:*" $PATH
        set -x PATH $path $PATH
    end
end

function watch -d "watch for file changes"
	while true
	    find . -type f -name "*.$argv[1]" | entr -c -s "$argv[2..-1]"
	end
end
