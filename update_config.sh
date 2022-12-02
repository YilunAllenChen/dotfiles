cp -R ~/dotfiles/config/. ~/.config
cp ~/dotfiles/.bashcustomize ~/

LINE='source ~/.bashcustomize'
FILE='/Users/allenchen/.bashrc'
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
