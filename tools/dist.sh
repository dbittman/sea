#!/bin/sh
sh tools/build_cd.sh
mkdir -p tools/seaos-build-`cat build_number`
mkdir -p tools/seaos-src-`cat build_number`
echo "packing hard drive..."
cp hd.img tools/seaos-build-`cat build_number`
cp tools/cd.iso tools/seaos-build-`cat build_number`
cd tools
cp -rf dist/* seaos-build-`cat ../build_number`
tar -cjf seaos-`cat ../build_number`-build.tar.bz2 seaos-build-`cat ../build_number`

echo "packing source code..."

cp -rf ../system ./seaos-src-`cat ../build_number`/kernel
cp -rf ../apps/seaos-util ./seaos-src-`cat ../build_number`

NUM=`cat ../build_number`

sudo rm -rf `sudo find seaos-src-$NUM -name .svn`
sudo rm -f `sudo find seaos-src-$NUM -name .directory`

tar -cjf seaos-`cat ../build_number`-src.tar.bz2 seaos-src-`cat ../build_number`

echo cleaning up...

rm -rf seaos-build-`cat ../build_number`
rm -rf seaos-src-`cat ../build_number`
