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
else 
	echo "In your case, your system doesn't have UEFI enabled. Use DOS."
fi
echo "Make sure you have a partition for the bootloader, a Swap partition and a Root partition."
echo "First, select the **disk** (not part) you want to use, using the full path. For example: /dev/sda"
lshw -class disk | grep "logical name" | cut -d " " -f10
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
sh
echo "4/10 Let's change the mirrorlist so that you have faster download speed."
pacman -S reflector
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
echo "Please enter your country's code... (for example: US, DE, RO)"
read countrycode
reflector -c "$countrycode" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
echo "5/10 Awesome, please provide the root partition so we can start the installation:"
read rootpart
mount $rootpart /mnt
pacstrap /mnt base linux linux-firmware vim nano
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
echo "6/10 We are almost done! Let's set up the timezone and locale"
timedatectl list-timezones
echo "Please provide the timezone:"
read tz
timedatectl set-timezone $tz
echo "Now let's set the locale."
cat /etc/locale.gen
echo "Enter a locale just as it is written: "
read locale
echo $locale >> /etc/locale.gen
locale-gen
echo LANG=$locale > /etc/locale.conf
export LANG=$locale
echo "7/10 Let's get some networking done. We must choose the hostname!"
echo "Enter a hostname:"
read hostname
echo $hostname > /etc/hostname
touch /etc/hosts
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1	localhost" >> /etc/hosts
echo "127.0.1.1	$hostname" >> /etc/hosts
echo "8/10 Let's setup a user and the root password."
echo "Enter a name for the user account: "
read $username
useradd -m -d /home/$username -s /bin/bash $username
echo "Enter a password for $username"
passwd $username
echo "Enter a password for the root account."
passwd
usermod -aG wheel,audio,video,storage $username
pacman -S sudo
sed '/root	ALL=(ALL:ALL) ALL/a $username	ALL=(ALL:ALL) ALL' file
echo "9/10 Aaand finally, the bootloader."
if [[ -e /sys/firmware/efi/efivars ]]; then
       	echo "Since you are booted as UEFI, we will configure GRUB to boot accordingly."
       	pacman -S grub efibootmgr
	mkdir /boot/efi
	echo "Please provide the boot partition:"
	read $bootpart
	mount $bootpart /boot/efi
	grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
	grub-mkconfig -o /boot/grub/grub.cfg	
else
        echo "Since you are booted as BIOS, we will configure GRUB to boot accordingly"
	pacman -S grub
	echo "Please provide the boot **disk**:"
        read $bootdisk
	grub-install $bootdisk
	grub-mkconfig -o /boot/grub/grub.cfg
fi
echo "10/10 Finally, the last step is to install the desktop experience. This distribution comes with a custom rice of i3wm by default, but you can install any DE or WM afterwards."
pacman -S i3-wm dmenu i3status xfce4-terminal networkmanager git gnome-screenshot feh hsetroot picom pavucontrol
git clone https://github.com/datcuandrei/da-dotfiles/tree/i3/
mkdir -p /home/$username/Pictures
wget -O /home/$username/Pictures/0001.jpg https://arc-anglerfish-washpost-prod-washpost.s3.amazonaws.com/public/OPIWPJSIGII6VENLZZBZVJOHYE.jpg
