#!/usr/bin/env bash

echo "Set a password for root for the live environment:"
passwd
chmod +x /dmtos-install.sh
/dmtos-install.sh