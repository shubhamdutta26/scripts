#!/bin/bash
set -e

# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    --no-install-recommends software-properties-common \
    --no-install-recommends dirmngr \
    --no-install-recommends r-base \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
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
    python3-venv \
    python3-pip \
    libdbus-1-dev \
    libinih-dev \
    solaar\
    libudunits2-dev
    fonts-roboto \
    fonts-roboto-slab \
    fonts-firacode

echo "Installation complete."
