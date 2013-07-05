#!/bin/sh
loop=`cat .loop`
losetup -o1048576 $loop hd.img
mount $loop
