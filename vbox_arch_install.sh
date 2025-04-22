#!/bin/bash

# Script to emulate Arch Linux installation

set -e # Exit immediately if a command exits with a non-zero status

# --- Configuration ---
LOCALE="en_US.UTF_8 UTF-8 ru_RU.UTF-8 UTF-8 ru_RU.KOI8-R KOI8-R"
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
    parted /dev/sda mklabel gpt
    parted /dev/sda mkpart primary fat32 0% 512MiB
    parted /dev/sda mkpart primary ext4 512MiB 100%

    # Format partitions
    mkfs.vfat -F 32 /dev/sda1
    mkfs.ext4 /dev/sda2

    parted /dev/sda print

    # Mount partitions
    sudo mount /dev/sda2 /mnt
    sudo mkdir -p /mnt/boot/efi
    sudo mount /dev/sda1 /mnt/boot/efi

    # Mount virtual systems for chroot mode
    mount --bind /dev /mnt/dev
    mount --bind /proc /mnt/proc
    mount --bind /sys /mnt/sys

    # Install base system
    pacstrap /mnt base linux linux-firmware grub efibootmgr

    # Generate fstab
    genfstab -U /mnt >>/mnt/etc/fstab
}

function install_bootloader() {
    arch-chroot /mnt <<EOF
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
    exit
    EOF
    # update-grub
    # grub-mkconfig -o /mnt/boot/grub/grub.cfg
    # sudo pacman -S refind gdisk
    # refind-install
    umount -R /mnt
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

# 6. Set Timezone
set_timezone

# 7. Configure NetworkManager (Requires GNOME) - This is a basic setup, may need adjustments
systemctl enable NetworkManager

# 8. Configure SDDM Greeter
echo "Setting up SDDM greeter..."
sed -i 's/^GRUB_CMDLINE_LINUX="quiet splash"/GRUB_CMDLINE_LINUX="quiet splash greeter=sdm"' /etc/default/grub

# 9. Set Root Password
echo "$ROOT_PASSWORD" | sudo passwd root

# 10. Set Hostname
hostnamectl set-hostname $HOSTNAME

# 11.  Inform user to reboot manually
echo "Installation complete! Please reboot your system manually."

echo "--- Installation Complete ---"
