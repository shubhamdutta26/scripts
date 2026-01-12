#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Log start
start_time=$(date +%s)
echo "🚀 Starting automated installation..."

# 1. System Update & Architecture
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y
sudo dpkg --add-architecture i386
sudo apt update && sudo apt upgrade -y

# 2. Main Dependency Block (Grouped for speed)
echo "📦 Installing system dependencies..."
sudo apt install -y \
  build-essential gfortran libreadline-dev libx11-dev \
  libxt-dev libpng-dev libjpeg-dev libcairo2-dev libssl-dev \
  libcurl4-openssl-dev texinfo texlive texlive-fonts-extra \
  screen libbz2-dev libzstd-dev liblzma-dev libicu-dev \
  libharfbuzz-dev libfribidi-dev libfreetype6-dev libindicator7 \
  libtiff5-dev libxml2-dev libnode-dev make cmake libgsl-dev \
  libwebp-dev libxss1 libgstreamer1.0-0 npm curl wget flatpak \
  libsecret-1-dev libmagick++-dev fonts-firacode stow ffmpeg 7zip \
  jq poppler-utils fd-find ripgrep fzf zoxide imagemagick kitty steam \
  git libclang-dev

# 3. Programming Languages & Environments
echo "🦀 Installing Rust..."
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y
# Ensure cargo is in the path for the rest of this script
source "$HOME/.cargo/env"
rustup toolchain install nightly
# Note: yazi-build requires specific rust version/deps
cargo install --force yazi-cli yazi-gen || echo "Yazi install failed, check dependencies"

echo "✨ Installing Starship and Neovim Config..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
mkdir -p ~/.config
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/shubhamdutta26/nvim-config.git ~/.config/nvim
fi

# 4. R Language (Source Build)
echo "📊 Compiling R Language..."
cd ~/Downloads
wget -q https://cran.r-project.org/src/base/R-4/R-4.5.2.tar.gz
tar -xzf R-4.5.2.tar.gz
cd R-4.5.2
./configure --enable-R-shlib --with-x=no # Added --with-x=no if you are on a server, remove if GUI needed
make -j"$(nproc)"
sudo make install
cd ..
rm -rf R-4.5.2 R-4.5.2.tar.gz

# 5. External .deb Packages (Using apt install for dependency resolution)
echo "📥 Installing Productivity Tools (.deb)..."

# RStudio
wget -q https://download1.rstudio.org/electron/jammy/amd64/rstudio-2025.09.2-418-amd64.deb
sudo apt install -y ./rstudio-*.deb

# Positron
wget -q https://cdn.posit.co/positron/releases/deb/x86_64/Positron-2025.12.1-4-x64.deb
sudo apt install -y ./Positron-*.deb

# Quarto
wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.26/quarto-1.8.26-linux-amd64.deb
sudo apt install -y ./quarto-*.deb
quarto install tinytex --no-prompt

# Neovim (Binary install)
wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# VeraCrypt
wget -q https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Ubuntu-24.04-amd64.deb
sudo apt install -y ./veracrypt-*.deb

# ProtonVPN
wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo apt install -y ./protonvpn-stable-release_1.0.8_all.deb
sudo apt update
sudo apt install -y proton-vpn-gnome-desktop libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator

# Google Chrome
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome*.deb

# Cleanup .debs
rm -f *.deb

# 6. Node Version Manager (NVM)
echo "🟢 Installing Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
npm install -g decktape

# 7. Flatpaks
echo "📦 Installing Flatpaks..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub \
    org.kde.kdenlive \
    com.notesnook.Notesnook \
    com.discordapp.Discord \
    org.audacityteam.Audacity

# 8. Cleanup
sudo apt autoremove -y

end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo "--------------------------------------"
echo "✅ Installation complete!"
printf "Total time: %02d:%02d:%02d\n" $((elapsed/3600)) $(( (elapsed/60) % 60 )) $((elapsed % 60))
