#!/bin/sh
mkdir -p build/mruby-1.0.0/INSTALL-$2/usr
cd build/mruby-1.0.0
wget https://github.com/mruby/mruby/archive/1.0.0.zip -O 1.0.0.zip
rm -rf mruby-1.0.0
unzip 1.0.0.zip
cd mruby-1.0.0

patch -p1 -i ../../../patches/mruby-1.0.0-seaos-$2.patch

PATH=$PATH:$1/bin make

cp -rf build/sea/* ../INSTALL-$2/usr

cd ../INSTALL-$2

sh ../../../inc-buildnr.sh

cat > mruby-1.0.0.manifest <<EOF
mruby:1.0.0:`cat buildnr`:$2::
EOF
