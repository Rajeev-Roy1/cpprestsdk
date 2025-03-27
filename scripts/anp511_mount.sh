#!/bin/sh

loadUserQSpi()
{
	echo "Loading MTD5..."
	dd if=/dev/mtd5 of=fs.img
	mount -o loop fs.img /mnt
}

writeUserQspi()
{
	echo "Writing Disk to MTD"
	umount /mnt

	flash_erase /dev/mtd5 0 0
	dd if=fs.img of=/dev/mtd5 
	echo "Disk Written successfully..."	
}

