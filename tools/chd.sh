#!/bin/sh
loop=`cat .loop`

rm -f hd.img 2>/dev/null
echo -n "processing hd.img..."
dd if=/dev/zero of=hd.img bs=1024 count=1 2> /dev/null
dd if=/dev/zero of=hd.img bs=1024 count=1 seek=1999999 2> /dev/null
echo -n "partition..."

sfdisk -q -L -u -S63 -H16 hd.img &>/dev/null << EOF
2048,,,*
EOF
echo -n "formatting..."
sudo losetup -o1048576 /dev/loop2 hd.img
mke2fs -q -I128 -b1024 /dev/loop2 
sync
losetup -d /dev/loop2
echo "installing grub..."
sh ./tools/open_hdimage.sh
mkdir -p /mnt/boot/grub
cp -r data/boot/grub/* /mnt/boot/grub/
sh ./tools/close_hdimage.sh
(echo -e "device (hd0) hd.img\nroot (hd0,0)\nembed /boot/grub/e2fs_stage1_5 (hd0)\ninstall (hd0,0)/boot/grub/stage1 (hd0) (hd0)1+17 p (hd0,0)/boot/grub/stage2\nquit" | tools/bin/grub --device-map data/boot/grub/device.map --batch)

echo processing hd2.img...
dd if=/dev/zero of=hd2.img bs=1024 count=1 2> /dev/null
dd if=/dev/zero of=hd2.img bs=1024 count=1 seek=100000 2> /dev/null
yes | (/sbin/mke2fs -q -I128 -b1024 hd2.img) > /dev/null

sh ./tools/copy_to_hd.sh $1
