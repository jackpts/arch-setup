#!/bin/bash

sudo pacman -S --needed base-devel git

# yay install
# git clone https://aur.archlinux.org/yay.git ~/Downloads
# cd ~/Downloads/yay
# makepkg -si

# paru install
git clone https://aur.archlinux.org/paru.git ~/Downloads
cd ~/Downloads/paru
makepkg -si

# Install base packages
./pkg_install.sh pacman.txt pacman
./pkg_install.sh paru.txt paru

# Install dotfiles packages
sudo pacman -S stow
git clone --depth 1 https://github.com/jackpts/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow .

# Install Hyprshot UI
git clone https://github.com/s-adi-dev/hyprshot-gui.git ~/Downloads
cd ~/Downloads/hyprshot-gui
./install.sh


