#!/usr/bin/env bash

set -euo pipefail

### Update and Upgrade System

sudo apt update
sudo apt upgrade -y

### Install APT Packages

sudo apt install -y \
ttf-mscorefonts-installer kdeconnect \
build-essential gfortran libreadline-dev libx11-dev \
libxt-dev libpng-dev libjpeg-dev libcairo2-dev libssl-dev \
libcurl4-openssl-dev texinfo texlive texlive-fonts-extra \
screen wget libbz2-dev libzstd-dev liblzma-dev libicu-dev \
libharfbuzz-dev libfribidi-dev libfreetype6-dev \
libtiff5-dev libxml2-dev libnode-dev make cmake libgsl-dev \
libpng-dev libtiff5-dev libjpeg-dev libwebp-dev \
libxss1 libgstreamer1.0-0 npm \
libsecret-1-dev libmagick++-dev fonts-firacode

### Install steam and associated packages

sudo dpkg --add-architecture i386
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt install steam-installer
sudo apt update

### Setup Flatpak and Install Flatpak Packages

sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub org.kde.kdenlive
flatpak install -y flathub com.notesnook.Notesnook
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub org.audacityteam.Audacity

### Install ProtonVPN (for Mint/Debian/Ubuntu, GNOME Desktop)

wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
sudo apt install -y proton-vpn-gnome-desktop
rm -f protonvpn-stable-release_1.0.8_all.deb
sudo apt install libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator


### Install R from Source

wget https://cran.r-project.org/src/base/R-4/R-4.5.1.tar.gz
tar -xvf R-4.5.1.tar.gz
cd R-4.5.1
./configure --enable-R-shlib
make -j"$(nproc)"
sudo make install
cd ..
rm -rf R-4.5.1 R-4.5.1.tar.gz

### Install decktape

sudo npm install -g decktape
echo 'export PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome' >> ~/.bashrc

### Install Anaconda (Silent Mode) and Clean Up Installer

curl -O https://repo.anaconda.com/archive/Anaconda3-2025.06-0-Linux-x86_64.sh
chmod +x ./Anaconda3-2025.06-0-Linux-x86_64.sh
./Anaconda3-2025.06-0-Linux-x86_64.sh

# Recommended Anaconda/conda configuration
conda config --set auto_activate_base false
conda update -y -n base conda
conda update -y anaconda-navigator
echo 'export QT_XCB_GL_INTEGRATION=none' >> ~/.bashrc
echo 'export enable_high_dpi_scaling=True' >> ~/.bashrc

# Reload at the end
source ~/.bashrc

### System Cleanup (Recommended)

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

echo "Setup complete: APT packages, Flatpaks, ProtonVPN, R, RStudio, and Anaconda installed and updated."

