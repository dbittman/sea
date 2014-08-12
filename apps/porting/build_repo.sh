#!/bin/sh

git pull
rm -rf ported/install-bases-individual-i586-pc-seaos ported/install-bases-individual-x86_64-pc-seaos
echo -e "\n" | ruby ./build.rb clean-all cleansrc-seaosutil
echo -e "x86_64\n" | ruby ./build.rb clean-all
echo -e "\n" | ruby ./build.rb --sep all-all
echo -e "x86_64\n" | ruby ./build.rb --sep all-all

cd extra
sh build-all.sh /opt/sea-toolchain x86
sh build-all.sh /opt/sea-toolchain x86_64
sh install-sep.sh

