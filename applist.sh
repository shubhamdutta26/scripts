#!/bin/bash

# Install essential packages using apt
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    audacity \
    steam \
    curl \
    dirmngr \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    r-base \
    r-base-dev \
    r-recommended \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    build-essential \
    libblas-dev \
    liblapack-dev \
    gfortran \
    cmake \
    libv8-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfontconfig1-dev \
    neofetch \
    vlc \
    deja-dup \
    ffmpeg \
    meson \
    pkg-config \
    libsystemd-dev \
    ninja-build \
    git \
    python3 \
    pandoc \
    python3-venv \
    python3-pip \
    libdbus-1-dev \
    libinih-dev \
    solaar \
    libudunits2-dev \
    fonts-roboto \
    fonts-roboto-slab \
    fonts-firacode

# Add CRAN repository for R
curl -fSsL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/cran.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/cran.gpg] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" | sudo tee /etc/apt/sources.list.d/cran.list

# Install Flatpak apps
flatpak install -y flathub org.kde.kdenlive
flatpak install -y flathub org.standardnotes.standardnotes

# Update apt repositories again in case the new sources are added
sudo apt update -y

# Cleanup unused packages (optional, but good for system health)
sudo apt autoremove -y
