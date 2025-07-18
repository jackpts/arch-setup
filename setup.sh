#!/bin/bash

# paru install
cd $HOME/Downloads
git clone --depth 1 https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf $HOME/Downloads/paru
paru

# Keys update
sudo pacman-key --refresh-keys

# Cache clear
sudo pacman -Scc

# Mirrors update
sudo reflector --verbose --latest 20 --sort rate --protocol https --threads 4 --save /etc/pacman.d/mirrorlist

# Sync system time
sudo systemctl start systemd-timesyncd
sudo systemctl enable systemd-timesyncd

# Install dotfiles packages
sudo pacman -S stow
cd $HOME
git clone --depth 1 https://github.com/jackpts/dotfiles.git
cd $HOME/dotfiles
stow . --adopt
git stash

# Install base packages
cd $HOME/Downloads/arch-setup/
sudo ./pkg_install.sh pacman
./pkg_install.sh paru

# Restore Nemo settings
dconf load /org/nemo/ < ~/dotfiles/nemo-dconf-settings

# Change default shell to Fish
echo "Setup fish/fisher/tide..."
if ! command -v fish &>/dev/null; then
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

# Starship installation
cd $HOME/Downloads/
curl -sS https://starship.rs/install.sh | sh
starship init fish | source
echo 'eval "$(starship init bash)"' >>$HOME/.bashrc
echo 'eval "$(starship init zsh)"' >>$HOME/.zshrc
# echo 'starship init fish | source' >> $HOME/.config/fish/config.fish

# PowerLevel10k plugin installation for ZSH
paru -S --noconfirm zsh-theme-powerlevel10k-git
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# TMUX plugins installation
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
tmux source $HOME/.tmux.conf
tmux new -d -s temp_session
tmux run-shell $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-session -t temp_session

# LazyVim install from scratch
# git clone https://github.com/LazyVim/starter ~/.config/nvim

# SDDM Themify
# sh $HOME/scripts/sddm_setup_theme.sh
cd $HOME/Downloads/arch-setup/
sudo cp -f ./assets/themes/sddm/sddm.conf /etc/sddm.conf
sudo 7z x ./assets/themes/sddm/andromeda.7z -o/usr/share/sddm/themes
sudo systemctl disable gdm && sudo systemctl enable sddm

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
# Battle.net open ports:
sudo ufw allow out proto tcp to any port 1119,1120,3724,6113,6114
sudo ufw allow out proto udp to any port 1119,1120,3724,6113,6114
# KDE Connect ports
sudo ufw allow 1714:1764/tcp comment 'KDE Connect TCP'
sudo ufw allow 1714:1764/udp comment 'KDE Connect UDP'
sudo ufw allow from any to any port 5353 proto udp comment 'KDE Connect mDNS'

# Install DX9 for games
winetricks d3dx9 vcrun2015

# Others
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/mkv
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/quicktime

### Enable services
# sudo systemctl enable --now bluetooth.service
# systemctl --user enable --now hypridle.service

### Extend FailLock from default 3 tries to 5
file="/etc/security/faillock.conf"

if [[ -f "$file" ]]; then
    cp -p "$file" "$file.bak" || { echo "Failed to create a faillock conf backup!"; }

    # Use sed to replace the line "# deny = 3" with "deny = 5"
    sed -i 's/^#\s*deny\s*=\s*3/deny = 5/' "$file" || { echo "Error updating faillock tries!"; }

    echo "Faillock updated."
fi

### Install Otter launcher
git clone https://github.com/kuokuo123/otter-launcher /tmp/otter-launcher
cd /tmp/otter-launcher
cargo build --release
sudo cp /tmp/otter-launcher/target/release/otter-launcher /usr/bin/


### Install Sine mod manager for Zen Browser
cd ~/Downloads
wget https://github.com/CosmoCreeper/Sine/releases/download/v2.1.1/sine-linux-x64
chmod +x ./sine-linux-x64
sudo chown -R $USER /opt/zen-browser-bin/
# ./sine-linux-x64

### Install Windscribe
cd ~/Downloads/
wget -O windscribe.zst https://windscribe.com/install/desktop/linux_zst_x64
sudo pacman -U ./windscribe.zst

### Ghostty add modern cursor shaders
cd ~/Downloads/
git clone --depth 1 https://github.com/KroneCorylus/shader-playground.git
mkdir -p ~/.config/ghostty/shaders
cp ./shader-playground/shaders/cursor* ~/.config/ghostty/shaders/

### Add BT battery % showing by turning On Experimental flag
BT_CONFIG_FILE="/etc/bluetooth/main.conf"
BT_SEARCH_STRING="#Experimental = false"
BT_REPLACE_STRING="Experimental = true"
if [ -f "$BT_CONFIG_FILE" ] && [ -w "$BT_CONFIG_FILE" ]; then
    if grep -qF "$BT_SEARCH_STRING" "$CONFIG_FILE"; then
        sudo sed -i "s|^$BT_SEARCH_STRING|$BT_REPLACE_STRING|g" "$BT_CONFIG_FILE"
        echo "File updated: $BT_CONFIG_FILE"
    fi
fi
sudo systemctl restart bluetooth

### Enable Packet static port on firewall
sudo ufw allow 9300
sudo ufw allow 9300/udp




