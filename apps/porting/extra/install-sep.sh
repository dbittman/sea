#!/bin/sh
LIST=`cat package-list`

cd build

for i in $LIST; do
  echo "installing " $i
  cd $i
  if [ -d INSTALL-x86 ]; then
    mkdir -p ../../../ported/install-bases-individual-i586-pc-seaos/$i
    cp -rf INSTALL-x86/* ../../../ported/install-bases-individual-i586-pc-seaos/$i/
  fi
  if [ -d INSTALL-x86_64 ]; then
    mkdir -p ../../../ported/install-bases-individual-x86_64-pc-seaos/$i
    cp -rf INSTALL-x86_64/* ../../../ported/install-bases-individual-x86_64-pc-seaos/$i/
  fi
  cd ..
done
