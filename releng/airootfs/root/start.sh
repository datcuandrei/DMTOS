#!/usr/bin/env bash

systemctl enable sddm
systemctl set-default graphical.target
systemctl enable NetworkManager
systemctl enable bluetooth
