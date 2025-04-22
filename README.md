# My customized 󰣇 setup

## How to start

1. Install Arch Linux via `archinstall` (preferable with Gnome DE)
2. Run this arch-setup script after:

```sh
    pacman-key --init
    sudo pacman -S git
    cd $HOME/Downloads
    git clone --depth 1 https://github.com/jackpts/arch-setup.git
    sh ./arch-setup/setup.sh
```

## VBox installation with auto disk partitioning (boot + root as ext4)

1. Load arch ISO
2. Ensure you have Inet connection
3. Then run:

```bash
    sudo pacman -Sy git
    git clone https://github.com/jackpts/arch-setup.git
    cd arch-setup
    sh ./vbox_arch_install.sh

```
