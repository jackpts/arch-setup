#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <pacman|paru>"
    exit 1
fi

package_list_file="$1.txt"
package_manager="$1"
echo "pkg manager: $1"
echo "pkg list file: $1.txt"

# Check if the file exists
if [ ! -f "$package_list_file" ]; then
    echo "File $package_list_file does not exist."
    exit 1
fi

# Check if the package manager is valid
if [[ "$package_manager" != "pacman" && "$package_manager" != "paru" ]]; then
    echo "Invalid package manager. Use 'pacman' or 'paru'."
    exit 1
fi

# Read the file line by line
while IFS= read -r line; do
    # Ignore empty lines and lines starting with #
    if [[ -z "$line" || "$line" =~ ^# ]]; then
        continue
    fi

    # Install the package using the specified package manager
    if [ "$package_manager" == "pacman" ]; then
        sudo pacman -S --needed --noconfirm "$line"
    elif [ "$package_manager" == "paru" ]; then
        paru -S --needed --noconfirm "$line"
    fi

done <"$package_list_file"

echo "All packages have been installed using $package_manager."
