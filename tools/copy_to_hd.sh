#!/bin/sh

sh ./tools/open_hdimage.sh
echo copying apps/data/ to hd.img...
cp -f -r apps/data-$1/* ./mnt
rm -rf `find ./mnt -name man 2>/dev/null`
echo copying data/ to hd.img...
cp -f -r data/* ./mnt/
mkdir -p ./mnt/usr/man
cp -rf tools/man_gen_tmp/text/* ./mnt/usr/man/
echo copying source code to hd.img...
mkdir -p ./mnt/usr/src
cp -rf seakernel ./mnt/usr/src/sea
cp -rf apps/seaos-util ./mnt/usr/src/seaos-util
make -C ./mnt/usr/src/sea clean
rm ./mnt/usr/src/sea/tools/confed ./mnt/usr/src/sea/tools/mkird
rm -rf `find ./mnt -name .git 2>/dev/null`
rm -f `find ./mnt -name .directory 2>/dev/null`

sh ./tools/close_hdimage.sh
