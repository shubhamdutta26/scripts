#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y
sudo dpkg --add-architecture i386

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
  build-essential gfortran libreadline-dev libx11-dev \
  libxt-dev libpng-dev libjpeg-dev libcairo2-dev libssl-dev \
  libcurl4-openssl-dev texinfo texlive texlive-fonts-extra \
  screen libbz2-dev libzstd-dev liblzma-dev libicu-dev \
  libharfbuzz-dev libfribidi-dev libfreetype6-dev libindicator7 \
  libtiff5-dev libxml2-dev libnode-dev make cmake libgsl-dev \
  libwebp-dev libxss1 libgstreamer1.0-0 npm curl wget flatpak \
  libsecret-1-dev libmagick++-dev fonts-firacode steam

wget https://cran.r-project.org/src/base/R-4/R-4.5.1.tar.gz
tar -xvf R-4.5.1.tar.gz
cd R-4.5.1
./configure --enable-R-shlib
make -j"$(nproc)"
sudo make install
cd ..
rm -rf R-4.5.1 R-4.5.1.tar.gz

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20
nvm use 20
npm install -g decktape

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome*.deb
rm -rf google-chrome*.deb

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.kde.kdenlive
flatpak install -y flathub com.notesnook.Notesnook
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub org.audacityteam.Audacity

wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
sudo apt install -y proton-vpn-gnome-desktop
rm -f protonvpn-stable-release_1.0.8_all.deb
sudo apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator

sudo apt install -y libssl-dev libclang-dev
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2025.09.0-387-amd64.deb
sudo dpkg -i rstudio*.deb
rm -rf rstudio*.deb

wget https://cdn.posit.co/positron/releases/deb/x86_64/Positron-2025.09.0-139-x64.deb
sudo dpkg -i Positron*.deb
rm -rf Positron*.deb

wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.24/quarto-1.8.24-linux-amd64.deb
sudo dpkg -i quarto*.deb
rm -rf quarto*.deb
quarto install tinytex

curl -O https://repo.anaconda.com/archive/Anaconda3-2025.06-0-Linux-x86_64.sh
bash Anaconda3*.sh -b -p $HOME/anaconda3
rm -f Anaconda3*.sh

sudo update-locale LC_TIME=en_US.UTF-8

sudo apt autoremove -y

echo "Installation complete."
