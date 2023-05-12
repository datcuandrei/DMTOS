#!/usr/bin/env bash
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
pacman -Syy sudo
#sed '/root	ALL=(ALL:ALL) ALL/a $username	ALL=(ALL:ALL) ALL' /etc/sudoers
usermod -aG wheel $username
echo "9/10 Aaand finally, the bootloader."
if [[ -e /sys/firmware/efi/efivars ]]; then
       	echo "Since you are booted as UEFI, we will configure GRUB to boot accordingly."
       	pacman -Syy grub efibootmgr
	mkdir /boot/efi
	echo "Please provide the boot partition:"
	read $bootpart
	mount $bootpart /boot/efi
	grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
	grub-mkconfig -o /boot/grub/grub.cfg	
else
        echo "Since you are booted as BIOS, we will configure GRUB to boot accordingly"
	pacman -Syy grub
	echo "Please provide the boot **disk**:"
        read $bootdisk
	grub-install $bootdisk
	grub-mkconfig -o /boot/grub/grub.cfg
fi
echo "10/10 Finally, the last step is to install the desktop experience. This distribution comes with KDE Plasma by default, but you can install any DE or WM afterwards."
pacman -Syy plasma-meta
read -p "The installation is done, so we can reboot anytime you hit Enter.." -n1 -s
unmount -R /mnt
systemctl isolate reboot.target