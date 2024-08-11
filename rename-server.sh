#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if a new hostname is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <new_hostname>"
  exit 1
fi

NEW_HOSTNAME=$1

hostnamectl set-hostname "$NEW_HOSTNAME"

# Update /etc/hostname
echo "$NEW_HOSTNAME" > /etc/hostname

# Update /etc/hosts
sed -i "s/127\.0\.1\.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

# Display the new hostname
echo "Hostname successfully changed to $NEW_HOSTNAME"
echo "Please reboot the system to apply the changes."
