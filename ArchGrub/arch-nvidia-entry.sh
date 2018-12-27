#!/bin/sh

Curnel="'Arch Linux'"
grubFolder=$(echo `lsb_release -is` | awk '{print tolower($0)}')
systemName=$(lsb_release -is)
if [[ $1 != '-f' && $1 != '--force' ]];then
	if [[ `sudo sed -n '/^menuentry/,/}/p;' /boot/grub/grub.cfg | sed '/}/q' | grep "$Curnel"` == '' ]]; then
		printf "$Curnel"
		printf "\nYou are not on the latest kernel.\n\n" 1>&2
		exit 1
	fi
fi

# printf "\nConfiguring GRUB Menu...\n"
Dgrub=/etc/default/grub
if [[ `grep modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm $Dgrub` == '' ]]; then
    sudo sed -i "/GRUB_CMDLINE/s/\"/\ modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm\"/2" $Dgrub
fi
# Enables nouveau by default
sudo sed -i 's/\<rd.driver.blacklist=nouveau\> //g' $Dgrub
sudo sed -i 's/\<modprobe.blacklist=nouveau\> //g' $Dgrub
sudo sed -i 's/\<nvidia-drm.modeset=1\> //g' $Dgrub
if [[ `grep modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm $Dgrub` == '' || \
	`grep rd.driver.blacklist=nouveau $Dgrub` || `grep modprobe.blacklist=nouveau $Dgrub` || \
	`grep nvidia-drm.modeset=1 $Dgrub` ]]; then
	printf "\nFailed to configure $Dgrub\n" 1>&2
	exit 3
fi
# sudo cat $Dgrub

# printf "\nCreating new boot menu entry with Nvidia modules enabled...\n"
Custom=/etc/grub.d/40_custom
echo "\
#!/bin/sh
exec tail -n +3 \$0
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
`sudo sed -n '/^menuentry/,/}/p;' /boot/grub/grub.cfg | sed '/}/q' | sed 's/'$systemName' Linux'/$systemName' Linux (Nvidia)/' | sed 's/modprobe.blacklist=nvidia,nvidia_drm,nvidia_modeset,nvidia_uvm//'`" | sudo tee $Custom > /dev/null

if [[ `sudo grep rd.driver.blacklist=nouveau $Custom` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ rd.driver.blacklist=nouveau/' $Custom
fi
if [[ `sudo grep modprobe.blacklist=nouveau $Custom` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ modprobe.blacklist=nouveau/' $Custom
fi
if [[ `sudo grep nvidia-drm.modeset=1 $Custom` == '' ]]; then
    sudo sed -i '/vmlinuz/s/$/ nvidia-drm.modeset=1/' $Custom
fi
if [[ `sudo grep $systemName\(Nvidia\) $Custom` == '' || `sudo grep rd.driver.blacklist=nouveau $Custom` == '' || \
	`sudo grep modprobe.blacklist=nouveau $Custom` == '' || `sudo grep nvidia-drm.modeset=1 $Custom` == '' ]]; then
	printf "\nFailed to configure custom grub entry.\n" 1>&2
fi
# sudo cat $Custom
sudo chmod 744 $Custom
sudo grub-mkconfig -o /boot/grub/grub.cfg

printf "\nSuccess! Changes will take effect on next boot."
