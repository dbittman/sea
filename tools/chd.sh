#!/bin/sh
loop=`cat .loop`

rm -f $2 2>/dev/null
echo -n "processing $2..."
dd if=/dev/zero of=$2 bs=1024 count=1 2> /dev/null
dd if=/dev/zero of=$2 bs=1024 count=1 seek=1999999 2> /dev/null
echo -n "partition..."

sfdisk -q $2 << EOF
2048,,,*
EOF
echo -n "formatting..."
sudo losetup -o1048576 /dev/loop2 $2
mke2fs -q -I128 -b1024 /dev/loop2 
sync
losetup -d /dev/loop2
echo "installing grub..."
sh ./tools/open_hdimage.sh $2
mkdir -p /mnt/boot/grub
cp -r data/boot/grub/* /mnt/boot/grub/
sh ./tools/close_hdimage.sh
(echo -e "device (hd0) $2\nroot (hd0,0)\nembed /boot/grub/e2fs_stage1_5 (hd0)\ninstall (hd0,0)/boot/grub/stage1 (hd0) (hd0)1+17 p (hd0,0)/boot/grub/stage2\nquit" | tools/bin/grub --device-map data/boot/grub/device.map --batch)

sh ./tools/copy_to_hd.sh $1 $2
