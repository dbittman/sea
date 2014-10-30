#!/bin/sh

umount /dev/loop2 2> /dev/null
losetup -d /dev/loop2
