#!/bin/bash
loop=`cat .loop`
echo generating $2
rm -f $2 2>/dev/null
dd if=/dev/zero of=$2 bs=1024 count=1 2> /dev/null
dd if=/dev/zero of=$2 bs=1024 count=1 seek=1999999 2> /dev/null

sfdisk -q $2 &>/dev/null << EOF
2048,,,*
EOF
sfdisk --activate $2 1
echo "formatting..."
sudo losetup /dev/loop1 $2
sudo losetup -o1048576 /dev/loop2 $2
mke2fs -q -I128 -b1024 /dev/loop2 
sync
mount /dev/loop2 /mnt

echo "installing grub..."
sudo grub-install --root-directory=/mnt --locales= --no-floppy --modules="normal part_msdos ext2 multiboot" /dev/loop1
umount /mnt
losetup -d /dev/loop2
losetup -d /dev/loop1

. ./tools/copy_to_hd.sh $1 $2 $3

