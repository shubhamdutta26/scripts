#!/usr/bin/env bash
set -euo pipefail

start_time=$(date +%s)

cd ~/Downloads

# Update and upgrade
sleep 5
echo ""
echo "Updating and upgrading Zorin OS..."
echo ""
sudo apt update && sudo apt upgrade -y

# Install apt packages
echo ""
echo "Installing dependencies..."
echo ""
sudo apt install -y \
  build-essential gfortran libreadline-dev libx11-dev \
  exfatprogs exfat-fuse fdisk libclang-dev libclang-18-dev \
  libxt-dev libpng-dev libjpeg-dev libcairo2-dev libssl-dev \
  libcurl4-openssl-dev texinfo texlive texlive-fonts-extra \
  screen libbz2-dev libzstd-dev liblzma-dev libicu-dev \
  libharfbuzz-dev libfribidi-dev libfreetype6-dev libindicator7 \
  libtiff5-dev libxml2-dev libnode-dev make cmake libgsl-dev \
  libwebp-dev libxss1 libgstreamer1.0-0 npm curl wget flatpak \
  libsecret-1-dev libmagick++-dev fonts-firacode stow ffmpeg 7zip \
  libobjc-13-dev libclang-common-18-dev libobjc4 libgc1 \
  jq poppler-utils fd-find ripgrep fzf zoxide imagemagick kitty syncthing

# Rust
sleep 5
echo ""
echo "Installing Rust..."
echo ""
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
rustup toolchain install nightly

# Starship
sleep 5
echo ""
echo "Installing Starship..."
echo ""
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Neovim
sleep 5
echo ""
echo "Installing Neovim..."
echo ""
wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
# git clone https://github.com/shubhamdutta26/nvim-config.git ~/.config/nvim
# git clone https://github.com/shubhamdutta26/custom-quarto-lvim.git ~/.config/lazyvim

# Obsidian
sleep 5
echo ""
echo "Installing Obsidian..."
echo ""
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.11.5/obsidian_1.11.5_amd64.deb
sudo dpkg -i ./obsidian_*.deb

# R
sleep 5
echo ""
echo "Installing R..."
echo ""
wget https://cran.r-project.org/src/base/R-4/R-4.5.2.tar.gz
tar -xvf R-4.5.2.tar.gz
cd R-4.5.2
./configure --enable-R-shlib
make -j"$(nproc)"
sudo make install
cd ..

# RStudio
sleep 5
echo ""
echo "Installing RStudio..."
echo ""
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2026.01.0-392-amd64.deb
sudo dpkg -i ./rstudio-*.deb

# Positron
sleep 5
echo ""
echo "Installing Positron..."
echo ""
wget https://cdn.posit.co/positron/releases/deb/x86_64/Positron-2026.01.0-147-x64.deb
sudo dpkg -i ./Positron-*.deb

# Quarto
sleep 5
echo ""
echo "Installing Quarto..."
echo ""
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.27/quarto-1.8.27-linux-amd64.deb
sudo dpkg -i quarto*.deb
quarto install tinytex

# Veracrypt
sleep 5
echo ""
echo "Installing Veracrypt..."
echo ""
wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Ubuntu-24.04-amd64.deb
sudo dpkg -i veracrypt*.deb

# ProtonVPN
sleep 5
echo ""
echo "Installing ProtonVPN..."
echo ""
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
sudo apt install -y \
  proton-vpn-gnome-desktop \
  libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 \
  gnome-shell-extension-appindicator
  
# Decktape
sleep 5
echo ""
echo "Installing Decktape..."
echo ""
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
nvm use 20
npm install -g decktape

# Google chrome
sleep 5
echo ""
echo "Installing Google chrome..."
echo ""
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i ./google-chrome*.deb

# Syncthing
sleep 5
echo ""
echo "Installing Syncthing..."
echo ""
wget https://github.com/syncthing/syncthing/releases/download/v2.0.13/syncthing-linux-amd64-v2.0.13.tar.gz
tar -xzf syncthing-linux-*.tar.gz
cd syncthing-linux-amd64-v2.0.13
sudo mv ./syncthing /usr/bin
cd ..

# Install Brave browser if OS is not Zorin OS
sleep 5
echo ""
echo "Installing Brave browser..."
echo ""
if [ -f /etc/os-release ] && ! grep -q 'ID=zorin' /etc/os-release; then
    sleep 5
    echo ""
    echo 'Compatible OS detected (not Zorin). Installing Brave Browser...'
    echo ""
    curl -fsS https://dl.brave.com/install.sh | sudo sh
else
    sleep 5
    echo ""
    echo 'Zorin OS detected. Skipping Brave installation.'
    echo ""
fi

# Flatpaks
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sleep 5
echo ""
echo "Installing Signal messenger..."
echo ""
flatpak install --system -y flathub org.signal.Signal

# FiraCode Nerd font
sleep 5
echo ""
echo "Installing FiraCode Nerd font..."
echo ""
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
mkdir -p ~/.local/share/fonts/FiraCode
unzip FiraCode.zip -d ~/.local/share/fonts/FiraCode
fc-cache -f -v

# Clean-up
sleep 5
echo ""
echo "Cleaning up..."
echo ""
rm -f *.deb
rm -f *.gz
rm -f *.zip
rm -rf R-4.5.2 R-4.5.2.tar.gz
rm -rf ~/Sync
rm -rf syncthing-linux-amd64-v2.0.13
sudo apt autoremove -y

end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo "Installation complete."
printf "Elapsed time: %02d:%02d:%02d\n" $((elapsed/3600)) $(( (elapsed/60) % 60 )) $((elapsed % 60))
