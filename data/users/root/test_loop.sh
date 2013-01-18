#!/bin/sh
echo creating hd.img...

dd if=/dev/zero of=hd.img bs=1024 count=20000

echo looping...
losetup /dev/loop0 hd.img

echo formatting...
mke2fs -I128 -b1024 /dev/loop0

mount /dev/loop0 /mnt

echo hd.img mounted on /mnt
