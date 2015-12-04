#!/bin/bash

sh ./tools/open_hdimage.sh $2

echo copying ported programs to hd.img...
rsync --exclude .git --exclude .directory -rlp apps/install-base-$1/* /mnt
rm -rf `find ./mnt -name man 2>/dev/null`
echo copying data/ to hd.img...
rsync --exclude .git --exclude .directory -rlp data/* /mnt/
if [ -d tools/man_gen_tmp/text ]; then
	echo copying man pages to hd.img...
	mkdir -p /mnt/usr/man
	cp -rf tools/man_gen_tmp/text/* /mnt/usr/man/
fi
echo copying source code to hd.img...
mkdir -p /mnt/usr/src
rsync --exclude .git --exclude .directory -rlp seakernel /mnt/usr/src
rm -rf /mnt/usr/src/seakernel/build/
mkdir -p /mnt/usr/src/seakernel/build/default
cp -f seakernel/build/$3/sea_defines.h /mnt/usr/src/seakernel/build/default/
cp -f seakernel/build/$3/sea_defines.inc /mnt/usr/src/seakernel/build/default/
cp -f seakernel/build/$3/.config.cfg /mnt/usr/src/seakernel/build/default/
mkdir -p /mnt/usr/src
rsync --exclude .git --exclude .directory -rlp apps/seaos-util /mnt/usr/src/
cp -f data-initrd/preinit.sh /mnt/sys/preinit.sh

echo fixing permissions...
chown -R root /mnt/*
chgrp -R 0 /mnt/*
chmod u+s /mnt/bin/login
chmod u+s /mnt/bin/passwd
chmod u+s /mnt/bin/useradd
chmod o-r /mnt/etc/shadow
chmod g-r /mnt/etc/shadow

sh ./tools/close_hdimage.sh

