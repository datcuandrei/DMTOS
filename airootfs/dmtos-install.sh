#!/usr/bin/env bash
clear
echo "Hi there! Welcome to the DMTOS Installer. This installer will guide you step by step on how to install DMTOS and get the DMTOS experience."
echo "1/10 DMTOS uses by default the English US Keyboard Layout."
echo "Do you want to keep this layout? [Y/n]"
read choice
if [[ $choice == "N" || $choice == "n" ]]; then
	ls /usr/share/kbd/keymaps/**/*.map.gz
	echo "Please choose one of the following layouts and enter the exact same you want. For example, if you want the DE Latin, you would use de-latin1"
	echo "What keyboard layout would you like?"
	read kblayout
	loadkeys $kblayout
fi
echo "2/10 The next step is creating the partition scheme. For now, this must be done manually."
echo "Here are some tips: Depending on the method you used to boot, you can either use GPT or DOS, which is UEFI or BIOS (Legacy)."
if [[ -e /sys/firmware/efi/efivars ]]; then
	echo "In your case, your system has UEFI enabled. Use GPT."
	echo "Make sure you have a partition for the bootloader, a Swap partition and a Root partition."
else 
	echo "In your case, your system doesn't have UEFI enabled. Use DOS."
	echo "Make sure you have a Swap partition and a Root partition."
fi
echo "First, select the **disk** (not part) you want to use, using the full path. For example: /dev/sda"
lsblk
echo "Enter disk path:"
read dsk
read -p "Whenever you are ready, press Enter (return) to start cfdisk..." -n1 -s
cfdisk $dsk
echo "Great! Now we have to format the partitions."
echo "3/10 To format the partitions you will enter in an interactive shell."
echo "Here are a few tips: use this format mkfs.parttype /dev/sdaX, where:"
echo "- parttype can be ext4, fat, etc."
echo "- sda can be replaced with the disk you used for partitioning"
echo "In case of UEFI, you must partition the boot partition as FAT32 with: mkfs.fat -F32 /dev/sdaX"
read -p "Whenever you are ready, press Enter (return) to start the interactive shell, use exit to exit..." -n1 -s
echo ""
sh
echo "4/10 Let's change the mirrorlist so that you have faster download speed."
pacman -Syy reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
echo "Please enter your country's code... (for example: US, DE, RO)"
read countrycode
reflector -c "$countrycode" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
echo "5/10 Awesome, please provide the root partition so we can start the installation:"
read rootpart
mount $rootpart /mnt
pacstrap /mnt base linux linux-firmware vim nano
genfstab -U /mnt >> /mnt/etc/fstab
cp chroot-part2.sh /mnt/bin/chroot-part2.sh
chmod a+rwx /mnt/bin/chroot-part2.sh
arch-chroot /mnt <<EOF

EOF
