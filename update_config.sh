cp -R ~/dotfiles/config/. ~/.config
cp ~/dotfiles/.shcustomize ~/

LINE='source ~/.shcustomize'
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  FILE="$HOME/.bashrc"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  FILE="$HOME/.zshrc"
fi

grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
