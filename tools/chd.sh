#!/bin/sh
loop=`cat .loop`

rm hd.img 2>/dev/null
echo -n "processing hd.img..."
dd if=/dev/zero of=hd.img bs=1024 count=1 2> /dev/null
dd if=/dev/zero of=hd.img bs=1024 count=1 seek=999999 2> /dev/null

sfdisk -q -L -u -S63 -H16 hd.img 2>/dev/null << EOF
2048,,,*
EOF

losetup -o1048576 $loop hd.img
mke2fs -q -I128 -b1024 $loop 
sync
losetup -d $loop

sh ./tools/open_hdimage.sh
mkdir -p ./mnt/boot/grub
cp -r data/boot/grub/* ./mnt/boot/grub/
sh ./tools/close_hdimage.sh

(echo "device (hd0) hd.img\nroot (hd0,0)\nembed /boot/grub/e2fs_stage1_5 (hd0)\ninstall --stage2=data/boot/grub/stage2 /boot/grub/stage1 (hd0) (hd0)1+17 p (hd0,0)/boot/grub/stage2 /boot/grub/menu.lst\nquit" | grub --device-map data/boot/grub/device.map --batch) > /dev/null

echo processing hd2.img..
dd if=/dev/zero of=hd2.img bs=1024 count=1 2> /dev/null
dd if=/dev/zero of=hd2.img bs=1024 count=1 seek=100000 2> /dev/null
yes | (/sbin/mke2fs -q -I128 -b1024 hd2.img) > /dev/null

sh ./tools/copy_to_hd.sh
