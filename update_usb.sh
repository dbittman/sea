#!/bin/sh

sudo mount $1 mnt
sudo mkdir -p ./mnt/sys/modules-${KERNEL_VERSION}/
sudo cp -rf seakernel/drivers/built/* ./mnt/sys/modules-${KERNEL_VERSION}/ 2>/dev/null
sudo cp -rf seakernel/initrd.img ./mnt/sys/initrd
sudo cp -rf skernel ./mnt/sys/kernel
sudo umount mnt

