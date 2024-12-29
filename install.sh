
# test if lazygit is installed
if ! [ -x "$(command -v lazygit)" ]; then
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit -D -t /usr/local/bin/

# Check if starship is installed
if ! [ -x "$(command -v starship)" ]; then
    curl -sS https://starship.rs/install.sh | sh
fi

# fish shell
if ! [ -x "$(command -v fish)" ]; then
    apt-add-repository ppa:fish-shell/release-3 -y
    apt update
    apt install -y fish
fi

# fzf
if ! [ -x "$(command -v fzf)" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh
fi

# node/npm
if ! [ -x "$(command -v node)" ]; then
    snap install -y node --classic
fi

# neovim
if ! [ -x "$(command -v nvim)" ]; then
	snap install -y neovim --classic
fi

apt update
apt install -y fd-find ripgrep entr flameshot
