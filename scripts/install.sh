#!/bin/sh

while [[ $# -gt 0 ]]; do
    case "$1" in
    	-a|--architecture)
			arch="$2"
        	shift
            shift
            ;;
        -p|--package)
			package="$2"
			shift
			shift
			;;
		*)
			shift
			;;
    esac
done

echo "Unpacking ${package}"

if [[ "$arch" == "ctl60x" ]];then
	source ./ctl60x_mount.sh
	mountUbiFs
elif [[ "$arch" == "anp511" ]]; then
	source ./anp511_mount.sh
	loadUserQSpi
else
	echo "Invalid Architecture Specified. Use either a53 or a8"
fi

tar -C /mnt/rootfs_overlay/ -xf ${package}.tar --strip 1

umount /mnt

echo "Installation Complete"
