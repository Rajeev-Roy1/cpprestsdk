#!/bin/sh

mountUbiFs()
{
	mount -t ubifs /dev/ubi0_0 /mnt
}

umountUbiFs()
{
	umount /mnt	
}