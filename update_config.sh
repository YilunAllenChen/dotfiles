cp -R ~/dotfiles/config/. ~/.config
cp ~/dotfiles/.shcustomize ~/

LINE='source ~/.shcustomize'
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  FILE="$HOME/.bashrc"
  FZFLINE="[ -f ~/.fzf.bash ] && source ~/.fzf.bash"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  FILE="$HOME/.zshrc"
  FZFLINE="[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh"
fi

grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
grep -qF -- "$FZFLINE" "$FILE" || echo "$FZFLINE" >> "$FILE"
