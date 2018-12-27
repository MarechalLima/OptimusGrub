#!/bin/bash
if ! [ -d /opt/Systemd-Nvidia-Entry/ ]; then ## checks if the directory exist
	mkdir /opt/Systemd-Nvidia-Entry/ -p ## if it doesn't exist, here it's created
fi

modprobe bbswitch ## starting bbswitch

if ! [[ `lsmod | grep nvidia` == "" ]]; then ## Nvidia
	tee /proc/acpi/bbswitch <<<ON
else ## Intel
	tee /proc/acpi/bbswitch <<<OFF
fi
