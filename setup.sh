#!/bin/bash

# yay install
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git ~/Downloads
cd ~/Downloads/yay
makepkg -si

# paru install
git clone https://aur.archlinux.org/paru.git ~/Downloads
cd ~/Downloads/paru
makepkg -si

./pkg_install.sh pacman.txt pacman
./pkg_install.sh yay.txt yay
