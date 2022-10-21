cp ./.config ~/ -r
cp ./.bashcustomize ~/

LINE='source ~/.bashcustomize'
FILE='/home/alchen/.bashrc'
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
