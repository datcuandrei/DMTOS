#!/usr/bin/env bash

echo "Enabling and starting NetworkManager..."

systemctl enable NetworkManager
systemctl start NetworkManager

echo "Fixing the GnuPG keys..."
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate

echo "Configuring Calamares..."
cp -avr /root/calamares /usr/share/calamares

chmod a+rwx /dmtos-install.sh
echo ""
echo "Set a password for the live user environment"
useradd -m -d /home/live -s /bin/bash live
passwd live

echo "Set a password for root for the live environment:"
passwd

usermod -aG wheel,sudo live
systemctl enable gdm

systemctl start graphical.target
