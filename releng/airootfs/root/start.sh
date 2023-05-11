#!/usr/bin/env bash

echo "Enabling and starting NetworkManager..."

systemctl enable NetworkManager
systemctl start NetworkManager

echo "Fixing the GnuPG keys..."
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate

chmod a+rwx /dmtos-install.sh
echo ""
echo "Set a password for the live user environment"
useradd -m -d /home/liveuser -s /bin/bash liveuser
passwd liveuser

echo "Set a password for root for the live environment:"
passwd

systemctl enable gdm

systemctl start graphical.target
