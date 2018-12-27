#!/bin/bash

install(){
	sudo mkdir /opt/Systemd-Nvidia-Entry/ -p
	echo "Making directory /opt/Systemd-Nvidia-Entry"
	sudo cp config-optimus.sh /opt/Systemd-Nvidia-Entry/
	sudo chmod 775 /opt/Systemd-Nvidia-Entry/config-optimus.sh
	sudo cp systemd-nvidia-entry.service /etc/systemd/system/
	sudo systemctl enable systemd-nvidia-entry.service
	sudo cp grub-nvidia-entry.sh /usr/bin/grub-nvidia-entry
	sudo chmod +x /usr/bin/grub-nvidia-entry
	sudo systemctl disable nvidia-fallback.service
	sudo mv /usr/lib/systemd/system/nvidia-fallback.service /opt/Systemd-Nvidia-Entry/
	chmod +x grub-nvidia-entry.sh
	sh grub-nvidia-entry.sh
}

uninstall(){
	mountPoint="/mnt/Systemd-Nvidia-Entry"
	partitionEFI=$(lsblk -o NAME,FSTYPE -l | grep vfat)
	partitionEFI=${partitionEFI::-5}
	if ! [[ `cat /proc/mounts | grep /boot/efi` == "" ]]; then
		mountPoint="/boot/efi"
	fi

	sudo mv /opt/Systemd-Nvidia-Entry/system/nvidia-fallback.service /usr/lib/systemd/
	sudo systemctl enable nvidia-fallback.service

	echo "Removing directory /opt/Systemd-Nvidia-Entry"
	sudo rm -f /usr/bin/Systemd-Nvidia-Entry
	sudo rm -rf /opt/Systemd-Nvidia-Entry/
	sudo systemctl disable systemd-nvidia-entry.service
	sudo rm /etc/systemd/system/systemd-nvidia-entry.service
}

if [[ $1 == "rm" ]]; then
	uninstall
else
	install
fi
