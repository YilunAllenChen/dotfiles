sudo apt install $(paste -sd " " ./requirements)


# python related stuff
pip install -r ./pip_requirements


# npm related stuff
curl -L https://git.io/n-install | bash -s -- -y lts latest 4.1
npm install -g -s $(paste -sd " " ./npm_requirements)


# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
rm lazygit.tar.gz

# nerdfont
echo "[-] Download fonts [-]"
echo "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/DroidSansMono.zip"
unzip DroidSansMono.zip -d ~/.fonts
fc-cache -fv
echo "done!"

#zsh
chsh -s $(which zsh)

./update_config.sh

