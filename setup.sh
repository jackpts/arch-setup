#!/bin/bash

# paru install
cd $HOME/Downloads
git clone --depth 1 https://aur.archlinux.org/paru.git 
cd paru
makepkg -si
cd ..
rm -rf $HOME/Downloads/paru
paru

# Mirrors update
sudo reflector --verbose --latest 20 --sort rate --protocol https --threads 4 --save /etc/pacman.d/mirrorlist

# Install dotfiles packages
sudo pacman -S stow
cd $HOME
git clone --depth 1 https://github.com/jackpts/dotfiles.git
cd $HOME/dotfiles
stow .

# Install base packages
cd $HOME/Downloads/arch-setup/
sudo ./pkg_install.sh pacman
./pkg_install.sh paru

# Change default shell to Fish
echo "Setup fish/fisher/tide..."
if ! command -v fish &> /dev/null
then
    echo "Fish shell is not installed!"
    # exit 1
fi

fish_prompt="$HOME/.config/fish/functions/fish_prompt.fish"
if [ -f "$fish_prompt" ]; then
  mv "$fish_prompt" "$fish_prompt.bak"
  echo "File fish_prompt found & renamed to: $fish_prompt.bak"
fi
# TODO: It's difficult to install Fisher inside Fish, probably it's need to move to Starship
# fish -c "curl -sL https://git.io/fisher | source"
# fisher --version
# fisher install IlanCosman/tide@v5
chsh -s /usr/bin/fish

# LazyVim install from scratch
# git clone https://github.com/LazyVim/starter ~/.config/nvim

# SDDM Themify
# sh $HOME/scripts/sddm_setup_theme.sh
sudo cp -f ./assets/themes/sddm/sddm.conf /etc/sddm.conf
7z x ./assets/themes/sddm/andromeda.7z -o/usr/share/sddm/themes
sudo systemctl enable --now sddm

# Install Hyprshot UI
cd $HOME/Downloads/
git clone --depth 1 https://github.com/s-adi-dev/hyprshot-gui.git
cd hyprshot-gui
sudo ./install.sh
cd ..
rm -rf $HOME/Downloads/hyprshot-gui

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
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darkest"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Plymouth setup
sudo mkdir -p /usr/share/plymouth/themes/
git clone --depth 1 https://github.com/MrVivekRajan/Plymouth-Themes.git ~/Downloads
cd ~/Downloads/Plymouth-Themes
sudo cp -vr {Deadlight,Ironman,Cube,Anonymous} /usr/share/plymouth/themes/
sudo cp -f ./assets/themes/plymouth/plymouthd.conf /etc/plymouth/plymouthd.conf
sudo plymouth-set-default-theme --rebuild-initrd
sudo mkinitcpio -P
# TODO: uncomment lines below after testing
# cd ..
# rm -rf ~/Downloads/Plymouth-Themes

# GRUB theme
cd $HOME/Downloads/arch-setup/assets/themes/grub/
7z x ./CyberGRUB-2077.7z
sudo ./CyberGRUB-2077/install.sh
# TODO: uncomment lines below after testing
# cd $HOME/Downloads
# rm -rf $HOME/Downloads/arch-setup/assets/themes/grub/CyberGRUB-2077

# UFW
sudo systemctl enable --now ufw.service
sudo ufw default deny
sudo ufw enable

# Others
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/mkv
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/quicktime

### Enable services
# sudo systemctl enable --now bluetooth.service
# systemctl --user enable --now hypridle.service
