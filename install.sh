#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)_$(uname -m)" in
	Linux_x86_64)  OS_NAME=Linux;  ARCH_NAME=x86_64 ;;
	Linux_aarch64) OS_NAME=Linux;  ARCH_NAME=arm64  ;;
	Darwin_x86_64) OS_NAME=Darwin; ARCH_NAME=x86_64 ;;
	Darwin_arm64)  OS_NAME=Darwin; ARCH_NAME=arm64  ;;
	*) echo "Unsupported platform: $(uname -s)/$(uname -m)"; exit 1 ;;
esac
IS_MAC=0
[ "$OS_NAME" = "Darwin" ] && IS_MAC=1

NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

IDS=(lazygit starship fish fzf fnm nvim nvim_config uv rust fd rg entr flameshot pi_config)
LABELS=(
	"lazygit"
	"starship prompt"
	"fish shell"
	"fzf (fuzzy finder)"
	"node (via fnm)"
	"neovim"
	"neovim config"
	"uv (python)"
	"rust (rustup)"
	"fd"
	"ripgrep"
	"entr"
	"flameshot"
	"pi agent config"
)
CHECKS=(
	"command -v lazygit"
	"command -v starship"
	"command -v fish"
	"command -v fzf"
	"command -v node"
	"command -v nvim"
	"test -d '$NVIM_CONFIG_DIR'"
	"command -v uv"
	"command -v cargo"
	"command -v fd"
	"command -v rg"
	"command -v entr"
	"command -v flameshot"
	"test -L '$HOME/.pi/agent/settings.json'"
)

# flameshot is Linux-only (X11 screenshot tool) — drop it on macOS
if [ "$IS_MAC" = "1" ]; then
	NEW_IDS=(); NEW_LABELS=(); NEW_CHECKS=()
	for ((i = 0; i < ${#IDS[@]}; i++)); do
		[ "${IDS[$i]}" = "flameshot" ] && continue
		NEW_IDS+=("${IDS[$i]}")
		NEW_LABELS+=("${LABELS[$i]}")
		NEW_CHECKS+=("${CHECKS[$i]}")
	done
	IDS=("${NEW_IDS[@]}")
	LABELS=("${NEW_LABELS[@]}")
	CHECKS=("${NEW_CHECKS[@]}")
fi

N=${#IDS[@]}
INSTALLED=()
for ((i = 0; i < N; i++)); do
	if eval "${CHECKS[$i]}" >/dev/null 2>&1; then
		INSTALLED[$i]=1
	else
		INSTALLED[$i]=0
	fi
done

# Indices (into IDS/LABELS) that are NOT installed — these are the only
# navigable/selectable rows. Installed items get their own static section.
AVAIL_IDX=()
for ((i = 0; i < N; i++)); do
	[ "${INSTALLED[$i]}" = "0" ] && AVAIL_IDX+=("$i")
done
NA=${#AVAIL_IDX[@]}

# ---------------------------------------------------------------------------
# Minimal TUI checklist (pure bash, no deps — works on bash 3.2 for macOS)
# ---------------------------------------------------------------------------
if [ "$NA" -eq 0 ]; then
	printf '\033[1mAlready installed:\033[0m\n'
	for ((i = 0; i < N; i++)); do
		printf '  \033[2m\xe2\x9c\x93 %s\033[0m\n' "${LABELS[$i]}"
	done
	printf '\nEverything already installed.\n'
	exit 0
fi

# SELECTED indexed by position within AVAIL_IDX (0..NA-1), default unselected
SELECTED=()
for ((k = 0; k < NA; k++)); do SELECTED[$k]=0; done

CURSOR=0
LINES_PRINTED=0

render() {
	if [ "$LINES_PRINTED" -gt 0 ]; then
		printf '\033[%dA' "$LINES_PRINTED"
	fi
	local lines=0 i k marker box
	if [ "$NA" -lt "$N" ]; then
		printf '\033[1mAlready installed\033[0m \033[2m(skipped)\033[0m\033[K\n'; lines=$((lines + 1))
		for ((i = 0; i < N; i++)); do
			if [ "${INSTALLED[$i]}" = "1" ]; then
				printf '  \033[2m\xe2\x9c\x93 %s\033[0m\033[K\n' "${LABELS[$i]}"
				lines=$((lines + 1))
			fi
		done
		printf '\033[K\n'; lines=$((lines + 1))
	fi
	printf '\033[1mSelect packages to install\033[0m\033[K\n'; lines=$((lines + 1))
	printf 'j/k or \xe2\x86\x91/\xe2\x86\x93 move, space toggle, a toggle-all, enter confirm\033[K\n'; lines=$((lines + 1))
	printf '\033[K\n'; lines=$((lines + 1))
	for ((k = 0; k < NA; k++)); do
		[ "$k" -eq "$CURSOR" ] && marker=">" || marker=" "
		if [ "${SELECTED[$k]}" = "1" ]; then box="[x]"; else box="[ ]"; fi
		printf ' %s %s %s\033[K\n' "$marker" "$box" "${LABELS[${AVAIL_IDX[$k]}]}"
		lines=$((lines + 1))
	done
	printf '\033[J'
	LINES_PRINTED=$lines
}

cleanup_tty() {
	stty "$STTY_ORIG" 2>/dev/null || true
	tput cnorm 2>/dev/null || true
}

STTY_ORIG="$(stty -g)"
tput civis 2>/dev/null || true
stty -echo -icanon min 1 time 0
trap cleanup_tty EXIT INT TERM

render
while true; do
	key=""
	IFS= read -rsn1 -d '' key
	case "$key" in
		$'\x1b')
			# Escape sequence (arrow keys): next bytes arrive as a burst.
			IFS= read -rsn1 -d '' k1 || k1=""
			if [ "$k1" = "[" ]; then
				IFS= read -rsn1 -d '' k2 || k2=""
				case "$k2" in
					A) CURSOR=$(( (CURSOR - 1 + NA) % NA )) ;;
					B) CURSOR=$(( (CURSOR + 1) % NA )) ;;
				esac
			fi
			;;
		k|K) CURSOR=$(( (CURSOR - 1 + NA) % NA )) ;;
		j|J) CURSOR=$(( (CURSOR + 1) % NA )) ;;
		' ')
			if [ "${SELECTED[$CURSOR]}" = "1" ]; then
				SELECTED[$CURSOR]=0
			else
				SELECTED[$CURSOR]=1
			fi
			;;
		a|A)
			# toggle-all: if any unselected, select all; else clear all
			any_unselected=0
			for ((k = 0; k < NA; k++)); do
				[ "${SELECTED[$k]}" = "0" ] && any_unselected=1 && break
			done
			for ((k = 0; k < NA; k++)); do SELECTED[$k]=$any_unselected; done
			;;
		$'\r'|$'\n')
			break
			;;
	esac
	render
done

cleanup_tty
printf '\n'

SELECTED_IDS=()
for ((k = 0; k < NA; k++)); do
	if [ "${SELECTED[$k]}" = "1" ]; then
		SELECTED_IDS+=("${IDS[${AVAIL_IDX[$k]}]}")
	fi
done

if [ ${#SELECTED_IDS[@]} -eq 0 ]; then
	printf 'Nothing selected. Exiting.\n'
	exit 0
fi

# ---------------------------------------------------------------------------
# Install functions
# ---------------------------------------------------------------------------
install_lazygit() {
	local ver tmp
	ver="$(curl -sL -o /dev/null -w '%{url_effective}' \
		https://github.com/jesseduffield/lazygit/releases/latest \
		| sed 's#.*/tag/v##')"
	tmp="$(mktemp -d)"
	curl -LsS -o "$tmp/lazygit.tar.gz" \
		"https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_${OS_NAME}_${ARCH_NAME}.tar.gz"
	tar -C "$tmp" -xf "$tmp/lazygit.tar.gz" lazygit
	sudo install "$tmp/lazygit" -t /usr/local/bin/
	rm -rf "$tmp"
}

install_starship() {
	curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_fish() {
	if [ "$IS_MAC" = "1" ]; then
		brew install fish
	else
		sudo apt update
		sudo apt install -y fish
	fi
}

install_fzf() {
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-zsh
}

install_fnm() {
	if [ "$IS_MAC" = "1" ]; then
		brew install fnm
	else
		curl -fsSL https://fnm.vercel.app/install | bash
	fi
	export PATH="$HOME/.local/share/fnm:$PATH"
	eval "$(fnm env --shell bash)"
	fnm install --lts
}

install_nvim() {
	if [ "$IS_MAC" = "1" ]; then
		brew install neovim
	else
		sudo apt update
		sudo apt install -y neovim
	fi
}

install_nvim_config() {
	git clone https://github.com/YilunAllenChen/nvim "$NVIM_CONFIG_DIR"
}

install_uv() {
	curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_rust() {
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

install_fd() {
	if [ "$IS_MAC" = "1" ]; then
		brew install fd
	else
		sudo apt update
		sudo apt install -y fd-find
		mkdir -p "$HOME/.local/bin"
		ln -sf "$(command -v fd-find)" "$HOME/.local/bin/fd"
	fi
}

install_rg() {
	if [ "$IS_MAC" = "1" ]; then
		brew install ripgrep
	else
		sudo apt update
		sudo apt install -y ripgrep
	fi
}

install_entr() {
	if [ "$IS_MAC" = "1" ]; then
		brew install entr
	else
		sudo apt update
		sudo apt install -y entr
	fi
}

install_flameshot() {
	sudo apt update
	sudo apt install -y flameshot
}

install_pi_config() {
	mkdir -p "$HOME/.pi/agent/extensions"
	ln -sf "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
	for f in "$DOTFILES_DIR"/pi/extensions/*.ts; do
		[ -e "$f" ] || continue
		ln -sf "$f" "$HOME/.pi/agent/extensions/$(basename "$f")"
	done
}

# ---------------------------------------------------------------------------
# Run selected installers
# ---------------------------------------------------------------------------
for id in "${SELECTED_IDS[@]}"; do
	printf '\n\033[1m==> %s\033[0m\n' "$id"
	"install_$id"
done

printf '\n\033[1mDone.\033[0m\n'
