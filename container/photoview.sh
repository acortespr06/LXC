#!/bin/bash

check_linux_version() {
  version=$(lsb_release -rs)
  if [ "$version" != "22.04" ] && [ "$version" != "22.04 LTS" ]; then
    echo "This script requires Ubuntu 22.04, but you are running version $version."
    exit 1
  fi
}

# Call the function to check the Linux version
check_linux_version

# Update and upgrade computer
sudo apt update
yes | sudo apt upgrade

# Install necessary tools
yes | sudo apt install git curl wget software-properties-common libdlib-dev libblas-dev libatlas-base-dev liblapack-dev libjpeg-turbo8-dev build-essential libdlib19 libdlib-dev libjpeg-dev libheif-dev pkg-config gpg

# Add repositories for libheif and libde265
sudo add-apt-repository ppa:strukturag/libheif --yes
sudo add-apt-repository ppa:strukturag/libde265 --yes

# Install Node 16 and NPM
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
yes | sudo apt install nodejs

# Download and install Go
wget https://golang.org/dl/go1.16.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.16.linux-amd64.tar.gz
rm go1.16.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc" && source "$HOME/.bashrc"
go version

# Clone Photoview repository and build UI
cd /opt
git clone https://github.com/photoview/photoview.git
cd photoview/ui
npm install
npm audit fix
yes | npx update-browserslist-db@latest
curl -o /opt/photoview/ui/vite.config.js https://raw.githubusercontent.com/acortespr06/LXC/main/misc/config/vite.config.js
npm run build

# Build the API back-end and copy needed files
cd ..
cd opt/photoview/api
sudo apt-get update
sudo apt-get install golang-go
go build -v -o photoview .
cd ..
mkdir app
cp -r ui/build/ app/ui/
cp api/photoview app/photoview
cp -r api/data/ app/data/
