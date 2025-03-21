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

# LazyVim install from scratch
# git clone https://github.com/LazyVim/starter ~/.config/nvim

# Install dotfiles packages
sudo pacman -S stow
git clone --depth 1 https://github.com/jackpts/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow .

# Install Hyprshot UI
git clone --depth 1 https://github.com/s-adi-dev/hyprshot-gui.git ~/Downloads
cd ~/Downloads/hyprshot-gui
./install.sh

# Install Dracula Icons - https://github.com/m4thewz/dracula-icons
git clone --depth 1 https://github.com/m4thewz/dracula-icons ~/.icons/dracula-icons

# Install gnome extensions dump
if command -v gnome-shell &>/dev/null && command -v dconf &>/dev/null; then
    dconf load /org/gnome/shell/extensions/ <./assets/ext-dump.txt
else
    echo "GNOME OR dconf isn't installed!"
fi

# Install Arc Darkest theme
7z x ./assets/themes/arc-darkest.7z -o/home/$USER/.themes


