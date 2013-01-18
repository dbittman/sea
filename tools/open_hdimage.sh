#!/bin/sh
#sudo /sbin/losetup /dev/loop0 hd.img
#sudo mount -t ext2 /dev/loop0 /mnt-seaos
loop=`cat .loop`
losetup -o1048576 $loop hd.img
mount $loop
