#!/usr/bin/env bash

echo "Enabling and starting NetworkManager..."

systemctl enable NetworkManager
systemctl start NetworkManager

echo "Fixing the GnuPG keys..."
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate

echo "Configuring Calamares..."
cp -avr /opt/calamares /usr/share/

echo "Customizing DE..."
gnome-extensions install /extensions/blur-my-shellaunetx.v46.shell-extension.zip --force
gnome-extensions install /extensions/dash-to-dockmicxgx.gmail.com.v80.shell-extension.zip --force
cp -vr /root/.local/share/gnome-shell/extensions/ /usr/share/gnome-shell/
dconf update
gnome-extensions enable blur-my-shell@aunetx
gnome-extensions enable dash-to-dock@micxgx.gmail.com

systemctl enable gdm