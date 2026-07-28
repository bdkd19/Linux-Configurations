#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root."
    exit 1
fi

# Check if openssl is installed
if ! command -v openssl &>/dev/null; then
    echo "openssl is not installed."
    exit 1
fi

# Ask how many users to create
read -p "How many users do you want to add? " count

# Validate input
if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number."
    exit 1
fi

# Loop through users
for ((i=1; i<=count; i++))
do
    read -p "Enter username $i: " user

    # Skip empty username
    [[ -z "$user" ]] && {
        echo "Username cannot be empty."
        continue
    }

    # Check if user exists
    if id "$user" &>/dev/null; then
        echo "User '$user' already exists. Skipping..."
        continue
    fi

    # Password = username@123
    password="${user}@123"

    # Generate SHA-512 encrypted password
    encrypted_pass=$(openssl passwd -6 "$password")

    # Create user with encrypted password
    useradd -m -p "$encrypted_pass" "$user"

    # Force password change on first login
    chage -d 0 "$user"

    echo "---------------------------------------"
    echo "User      : $user"
    echo "Password  : $password"
    echo "Status    : Created Successfully"
    echo "---------------------------------------"
done

echo "All users processed."
