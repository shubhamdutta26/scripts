#!/bin/bash
set -e

echo "🔄 Updating system package index..."
sudo apt-get update -qq

echo "📦 Installing helper packages for CRAN repo setup..."
sudo apt-get install -y --no-install-recommends software-properties-common dirmngr wget gnupg

echo "🔑 Adding CRAN signing key..."
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc > /dev/null

echo "➕ Adding CRAN repository for R..."
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

echo "📦 Updating again and installing R..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends r-base

echo "📦 Installing all other required system and development packages..."
sudo apt-get install -y \
    automake \
    bwidget \
    build-essential \
    cargo \
    chromium \
    cmake \
    coinor-libclp-dev \
    coinor-libsymphony-dev \
    coinor-symphony \
    dcraw \
    default-jdk \
    deja-dup \
    ffmpeg \
    flatpak \
    fonts-firacode \
    fonts-roboto \
    fonts-roboto-slab \
    gdal-bin \
    git \
    gsfonts \
    haveged \
    imagej \
    jags \
    libapparmor-dev \
    libarchive-dev \
    libavfilter-dev \
    libblas-dev \
    libboost-all-dev \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libdbus-1-dev \
    libfftw3-dev \
    libflint-dev \
    libfluidsynth-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgdal-dev \
    libgeos-dev \
    libgit2-dev \
    libgl1-mesa-dev \
    libglib2.0-dev \
    libglpk-dev \
    libglu1-mesa-dev \
    libgmp3-dev \
    libgpgme11-dev \
    libgrpc++-dev \
    libgsl0-dev \
    libharfbuzz-dev \
    libhdf5-dev \
    libhiredis-dev \
    libicu-dev \
    libimage-exiftool-perl \
    libinih-dev \
    libjpeg-dev \
    libjq-dev \
    libleptonica-dev \
    liblzma-dev \
    libmagic-dev \
    libmagick++-dev \
    libmecab-dev \
    libmpfr-dev \
    libmysqlclient-dev \
    libnetcdf-dev \
    libnode-dev \
    libopencv-dev \
    libopenmpi-dev \
    libpng-dev \
    libpoppler-cpp-dev \
    libpoppler-glib-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libprotoc-dev \
    libqgis-dev \
    libquantlib0-dev \
    librdf0-dev \
    librsvg2-dev \
    libsasl2-dev \
    libsecret-1-dev \
    libsndfile1-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssh-dev \
    libssh2-1-dev \
    libssl-dev \
    libsystemd-dev \
    libtesseract-dev \
    libtiff-dev \
    libtiff5-dev \
    libudunits2-dev \
    libv8-dev \
    libwebp-dev \
    libx11-dev \
    libxml2-dev \
    libxslt-dev \
    libzmq3-dev \
    libzstd-dev \
    make \
    meson \
    neofetch \
    ninja-build \
    nvidia-cuda-dev \
    ocl-icd-opencl-dev \
    pandoc \
    pandoc-citeproc \
    pari-gp \
    patch \
    perl \
    pkg-config \
    protobuf-compiler \
    protobuf-compiler-grpc \
    python3 \
    python3-pip \
    python3-venv \
    rustc \
    saga \
    tcl \
    tesseract-ocr-eng \
    texlive \
    tk \
    tk-dev \
    tk-table \
    unixodbc-dev \
    vlc \
    xz-utils \
    zlib1g-dev

echo "⚙️ Reconfiguring Java for R..."
sudo R CMD javareconf

echo "📦 Adding Flathub and installing Flatpak apps..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub com.valvesoftware.Steam
flatpak install -y flathub org.standardnotes.standardnotes

echo "🎮 Cloning and building GameMode (v1.8.2)..."
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode
git checkout 1.8.2
./bootstrap.sh
cd ..
rm -rf gamemode

echo "✅ All installations and configurations are complete!"
