#!/bin/sh

umount `cat .loop` 2> /dev/null
losetup -d `cat .loop`
