cp ~/dotfiles/config ~/.config -r
cp ~/dotfiles/.bashcustomize ~/

LINE='source ~/.bashcustomize'
FILE='/home/alchen/.bashrc'
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
