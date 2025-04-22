#!/bin/bash

# Script to emulate Arch Linux installation

set -e # Exit immediately if a command exits with a non-zero status

# --- Configuration ---
LOCALE="en_US UTF_8 ru_RU"
HOSTNAME="arch"
ROOT_PASSWORD="123"
USERNAME="j"
USER_PASSWORD="123"
TIMEZONE="UTC+03"
# DISK_SIZE_1="512M"
# DISK_SIZE_2="all" # All remaining space

# --- Functions ---

function install_locales() {
  locale-gen $LOCALE
}

function partition_disk() {
  # Create partitions (adjust sizes as needed)
  parted /dev/sda mklabel msdos
  # parted /dev/sda create 1 esp boot
  parted /dev/sda create 1 esp
  # parted /dev/sda create 2
  # parted /dev/sda set 1 boot on
  # parted /dev/sda set 2 flags partition

  # Format partitions
  mkfs.vfat -F 32 /dev/sda1
  mkfs.ext4 /dev/sda2
}

function install_bootloader() {
  grub-install --target=i386-pc /dev/sda
  update-grub
}

function create_user() {
  useradd -m $USERNAME -G wheel,audio,video,power -s /bin/bash $USERNAME
  echo "$USERNAME:$USER_PASSWORD" | chpasswd
  sudo chmod 660 /etc/sudoers
  # Add user to sudo group (if not already)
  gpasswd -a $USERNAME wheel
}

function install_packages() {
  pacman -S --noconfirm gnome gnome-extra gdm3 xorg-server xorg-xinit firefox network-manager pipewire pipewire-alsa sddm lightdm git kitty nano
}

function install_paru() {
    # Install Paru using pacman
    pacman -S --noconfirm paru
}


function set_timezone() {
  timedatectl set-timezone "$TIMEZONE"
}

# --- Main Execution ---

echo "--- Starting Arch Linux Installation Script ---"

# 1. Install Locales
pacman -S --noconfirm glibc # Install glibc before locales
install_locales

# 2. Partitioning Disk
partition_disk

# 3. Install Bootloader
install_bootloader

# 4. Create User Account
create_user

# 5. Install Packages - GNOME Desktop Environment
install_packages

# 6. Install Paru
install_paru

# 7. Set Timezone
set_timezone

# 8. Configure NetworkManager (Requires GNOME) - This is a basic setup, may need adjustments
systemctl enable NetworkManager

# 9. Configure SDDM Greeter
echo "Setting up SDDM greeter..."
sed -i 's/^GRUB_CMDLINE_LINUX="quiet splash"/GRUB_CMDLINE_LINUX="quiet splash greeter=sdm"' /etc/default/grub

# 10. Set Root Password
echo "$ROOT_PASSWORD" | sudo passwd root

# 11. Set Hostname
hostnamectl set-hostname $HOSTNAME

# 12.  Inform user to reboot manually
echo "Installation complete! Please reboot your system manually."

echo "--- Installation Complete ---"
