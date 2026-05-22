#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
#  Colours & Formatting
# ─────────────────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[0;37m'

# ─────────────────────────────────────────────
#  Dry-run flag
# ─────────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

# ─────────────────────────────────────────────
#  Spinner & Execution Wrappers
# ─────────────────────────────────────────────
spinner() {
  local pid=$1
  local msg=${2:-"Working..."}
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0
  tput civis 2>/dev/null || true   # hide cursor
  
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${MAGENTA}${frames[i % ${#frames[@]}]}${RESET}  ${DIM}%s${RESET}" "$msg"
    i=$((i + 1))
    sleep 0.1
  done
  
  printf "\r\033[K"                # clear the spinner line
  tput cnorm 2>/dev/null || true   # restore cursor
}

# Wraps standard commands to use the spinner and hide output unless they fail
execute() {
  if $DRY_RUN; then
    echo -e "  ${DIM}${CYAN}dry-run ❯${RESET} ${DIM}$*${RESET}"
    sleep 0.05
  else
    local tmp_log
    tmp_log=$(mktemp)
    "$@" > "$tmp_log" 2>&1 &
    local pid=$!
    
    spinner "$pid" "Processing..."
    wait "$pid"
    local status=$?
    
    if [ $status -ne 0 ]; then
      echo -e "\r\033[K  ${RED}✖ Command failed:${RESET} $*"
      cat "$tmp_log"
      rm -f "$tmp_log"
      exit $status
    fi
    rm -f "$tmp_log"
  fi
}

# Wraps piped commands
execute_pipe() {
  if $DRY_RUN; then
    echo -e "  ${DIM}${CYAN}dry-run ❯${RESET} ${DIM}$*${RESET}"
    sleep 0.05
  else
    local tmp_log
    tmp_log=$(mktemp)
    eval "$*" > "$tmp_log" 2>&1 &
    local pid=$!
    
    spinner "$pid" "Processing..."
    wait "$pid"
    local status=$?
    
    if [ $status -ne 0 ]; then
      echo -e "\r\033[K  ${RED}✖ Command failed:${RESET} $*"
      cat "$tmp_log"
      rm -f "$tmp_log"
      exit $status
    fi
    rm -f "$tmp_log"
  fi
}

# ─────────────────────────────────────────────
#  Logging Helpers
# ─────────────────────────────────────────────
info()    { echo -e "\n${BOLD}${CYAN}[+]${RESET} ${BOLD}${WHITE}$1${RESET}"; }
success() { echo -e "  ${GREEN}╰─ ✔${RESET}  $1"; }
warn()    { echo -e "  ${YELLOW}╰─ ⚠${RESET}  $1"; }
error()   { 
  tput cnorm 2>/dev/null || true
  echo -e "\n${RED}${BOLD}[ERROR]${RESET} $1 ${DIM}(line ${BASH_LINENO[0]})${RESET}" >&2
  exit 1
}
divider() { echo -e "\n${DIM}$(printf '─%.0s' {1..60})${RESET}"; }
step()    { divider; info "$1"; }

trap_error() { error "A command failed unexpectedly."; }
trap trap_error ERR

# Ensure cursor is restored if script is aborted (Ctrl+C)
trap 'tput cnorm 2>/dev/null || true; rm -rf "$TEMP_DIR"' EXIT

# ─────────────────────────────────────────────
#  Init
# ─────────────────────────────────────────────
START_TIME=$(date +%s)
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

clear
echo -e "${BOLD}${CYAN}"
cat << 'EOF'
  ██████╗ ███████╗██╗   ██╗    ███████╗███████╗████████╗██╗   ██╗██████╗
  ██╔══██╗██╔════╝██║   ██║    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
  ██║  ██║█████╗  ██║   ██║    ███████╗█████╗     ██║   ██║   ██║██████╔╝
  ██║  ██║██╔══╝  ╚██╗ ██╔╝    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝
  ██████╔╝███████╗ ╚████╔╝     ███████║███████╗   ██║   ╚██████╔╝██║
  ╚═════╝ ╚══════╝  ╚═══╝      ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝
EOF
echo -e "${RESET}"
echo -e "  ${DIM}Ubuntu Workstation Installer · $(date '+%Y-%m-%d %H:%M')${RESET}"
echo -e "  ${DIM}$(uname -srm)${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}${BOLD}⚠  DRY-RUN MODE — no changes will be made${RESET}"
divider
echo -e "\n  Initializing setup. Sit back — this may take a while.\n"
sleep 2

# ─────────────────────────────────────────────
#  System update & upgrade
# ─────────────────────────────────────────────
step "System update & upgrade"
execute sudo apt update -qq
execute sudo apt upgrade -y
success "System is up to date"

# ─────────────────────────────────────────────
#  Base dependencies
# ─────────────────────────────────────────────
step "Installing base dependencies"
execute sudo apt install -y \
  flatpak curl gnome-tweaks gnome-shell-extension-manager \
  libfuse2t64 \
  build-essential libcurl4-openssl-dev libclang-dev \
  libclang-18-dev libobjc-13-dev libobjc-13-dev \
  libclang-common-18-dev libclang-common-18-dev libobjc4 libgc1 \
  cmake git libcairo2-dev libfontconfig1-dev libfreetype6-dev \
  libfribidi-dev libgit2-dev libharfbuzz-dev libicu-dev \
  libjpeg-dev libnode-dev libpng-dev libtiff-dev libuv1-dev \
  libwebp-dev libx11-dev libxml2-dev pandoc \
  libblas-dev liblapack-dev gfortran
success "Base dependencies installed"

# ─────────────────────────────────────────────
#  Starship prompt
# ─────────────────────────────────────────────
step "Installing Starship prompt"
execute_pipe "curl -sS https://starship.rs/install.sh | sudo sh -s -- -y"
execute_pipe "grep -qxF 'eval \"\$(starship init bash)\"' ~/.bashrc || echo 'eval \"\$(starship init bash)\"' >> ~/.bashrc"
success "Starship installed"

# ─────────────────────────────────────────────
#  Signal
# ─────────────────────────────────────────────
step "Installing Signal"
execute sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
execute sudo flatpak install --system -y flathub org.signal.Signal
success "Signal installed via Flatpak"

# ─────────────────────────────────────────────
#  VLC
# ─────────────────────────────────────────────
step "Installing VLC Media Player"
execute sudo flatpak install --system -y flathub org.videolan.VLC
success "VLC installed via Flatpak"

# ─────────────────────────────────────────────
#  Fonts (FiraCode, Inter, Maple Mono)
# ─────────────────────────────────────────────
step "Installing Fonts"
# FiraCode Nerd Font
execute wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
execute mkdir -p ~/.local/share/fonts/FiraCode
execute unzip -q FiraCode.zip -d ~/.local/share/fonts/FiraCode

# Inter
execute wget -q https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
execute mkdir -p ~/.local/share/fonts/Inter
execute unzip -q Inter-4.1.zip -d ~/.local/share/fonts/Inter

# Maple Mono
execute wget -q https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-Variable.zip
execute mkdir -p ~/.local/share/fonts/MapleMono
execute unzip -q MapleMono-Variable.zip -d ~/.local/share/fonts/MapleMono

# Cache Fonts
execute fc-cache -f -v
success "FiraCode, Inter, and Maple Mono fonts installed"

# ─────────────────────────────────────────────
#  Bibata Cursor Theme
# ─────────────────────────────────────────────
step "Installing Bibata Cursor Theme"
execute wget -q https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic.tar.xz
execute mkdir -p ~/.local/share/icons
execute tar -xf Bibata-Modern-Classic.tar.xz -C ~/.local/share/icons/
success "Bibata Cursor Theme installed"

# ─────────────────────────────────────────────
#  Obsidian
# ─────────────────────────────────────────────
step "Installing Obsidian"
execute wget -q https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian_1.12.7_amd64.deb
execute sudo dpkg -i obsidian_1.12.7_amd64.deb
execute sudo apt --fix-broken install -y
success "Obsidian installed"

# ─────────────────────────────────────────────
#  R (CRAN)
# ─────────────────────────────────────────────
step "Installing R from CRAN"
execute sudo apt update -qq
execute sudo apt install -y --no-install-recommends software-properties-common dirmngr
execute_pipe "wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
  | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc > /dev/null"
execute sudo add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
execute sudo apt install -y --no-install-recommends r-base

if command -v R &>/dev/null; then
  R_VER=$(R --version | head -1 | awk '{print $3}')
else
  R_VER="[version]"
fi
success "R $R_VER installed"

# ─────────────────────────────────────────────
#  RStudio
# ─────────────────────────────────────────────
step "Installing RStudio"
execute wget -q https://download1.rstudio.org/electron/jammy/amd64/rstudio-2026.01.1-403-amd64.deb
execute sudo dpkg -i rstudio-2026.01.1-403-amd64.deb
execute sudo apt --fix-broken install -y
success "RStudio installed"

# ─────────────────────────────────────────────
#  Positron
# ─────────────────────────────────────────────
step "Installing Positron"
execute wget -q https://cdn.posit.co/positron/releases/deb/x86_64/Positron-2026.04.1-10-x64.deb
execute sudo dpkg -i Positron-2026.04.1-10-x64.deb
execute sudo apt --fix-broken install -y
success "Positron installed"

# ─────────────────────────────────────────────
#  Quarto
# ─────────────────────────────────────────────
step "Installing Quarto"
execute wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.36/quarto-1.9.36-linux-amd64.deb
execute sudo dpkg -i quarto-1.9.36-linux-amd64.deb
execute sudo apt --fix-broken install -y

if command -v quarto &>/dev/null; then
  Q_VER=$(quarto --version)
else
  Q_VER="[version]"
fi
success "Quarto $Q_VER installed"

# ─────────────────────────────────────────────
#  TinyTeX (via Quarto)
# ─────────────────────────────────────────────
step "Installing TinyTeX"
execute quarto install tinytex --no-prompt
success "TinyTeX installed"

# ─────────────────────────────────────────────
#  VeraCrypt
# ─────────────────────────────────────────────
step "Installing VeraCrypt"
execute wget -q https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Ubuntu-24.04-amd64.deb
execute sudo dpkg -i veracrypt-1.26.24-Ubuntu-24.04-amd64.deb
execute sudo apt --fix-broken install -y
success "VeraCrypt installed"

# ─────────────────────────────────────────────
#  ProtonVPN
# ─────────────────────────────────────────────
step "Installing ProtonVPN"
execute wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
execute sudo dpkg -i protonvpn-stable-release_1.0.8_all.deb
execute sudo apt update -qq
execute sudo apt install -y \
  proton-vpn-gnome-desktop \
  libayatana-appindicator3-1 \
  gir1.2-ayatanaappindicator3-0.1 \
  gnome-shell-extension-appindicator
success "ProtonVPN installed"

# ─────────────────────────────────────────────
#  LocalSend
# ─────────────────────────────────────────────
step "Installing LocalSend"
execute wget -q https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-1.17.0-linux-x86-64.deb
execute sudo dpkg -i LocalSend-1.17.0-linux-x86-64.deb
execute sudo apt --fix-broken install -y
success "LocalSend installed"

# ─────────────────────────────────────────────
#  Brave Browser
# ─────────────────────────────────────────────
step "Installing Brave Browser"
if $DRY_RUN; then
  echo -e "  ${DIM}${CYAN}dry-run ❯${RESET} ${DIM}curl -fsS https://dl.brave.com/install.sh | sudo sh${RESET}"
elif command -v brave-browser &>/dev/null; then
  warn "Brave browser already installed — skipping"
else
  execute_pipe "curl -fsS https://dl.brave.com/install.sh | sudo sh"
fi
success "Brave Browser ready"

# ─────────────────────────────────────────────
#  Syncthing
# ─────────────────────────────────────────────
step "Installing Syncthing"
execute sudo apt install -y syncthing
execute wget -q https://github.com/syncthing/syncthing/releases/download/v2.0.16/syncthing-linux-amd64-v2.0.16.tar.gz
execute tar -xzf syncthing-linux-amd64-v2.0.16.tar.gz
execute sudo mv syncthing-linux-amd64-v2.0.16/syncthing /usr/bin/syncthing
success "Syncthing installed"

# ─────────────────────────────────────────────
#  Cleanup
# ─────────────────────────────────────────────
step "System Cleanup"
execute sudo apt autoremove -y
success "APT cache cleaned"

# ─────────────────────────────────────────────
#  Summary
# ─────────────────────────────────────────────
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
H=$((ELAPSED / 3600))
M=$(( (ELAPSED / 60) % 60 ))
S=$((ELAPSED % 60))

divider
echo -e ""
echo -e "  ${BOLD}${GREEN}✔  All done! Installation complete.${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}(dry-run — nothing was actually installed)${RESET}"
echo -e ""
echo -e "  ${DIM}┌──────────────────────────────────────────────┐${RESET}"
echo -e "  ${DIM}│${RESET}  ${BOLD}Installed Components${RESET}                        ${DIM}│${RESET}"
echo -e "  ${DIM}├──────────────────────────────────────────────┤${RESET}"
printf  "  ${DIM}│${RESET}  %-47s${DIM}│${RESET}\n" "Starship · Fonts · Bibata Cursor · VLC"
printf  "  ${DIM}│${RESET}  %-46s${DIM}│${RESET}\n" "Brave Browser · R · RStudio"
printf  "  ${DIM}│${RESET}  %-46s${DIM}│${RESET}\n" "Positron · Quarto · TinyTeX"
printf  "  ${DIM}│${RESET}  %-46s${DIM}│${RESET}\n" "Signal · Obsidian · LocalSend"
printf  "  ${DIM}│${RESET}  %-46s${DIM}│${RESET}\n" "ProtonVPN · VeraCrypt · Syncthing"
echo -e "  ${DIM}└──────────────────────────────────────────────┘${RESET}"
echo -e ""
printf  "  ${DIM}Total execution time: %02d:%02d:%02d${RESET}\n\n" "$H" "$M" "$S"
