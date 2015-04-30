#!/bin/sh

echo "INSTALLING x86"
echo "" | ruby ./package.rb
echo "INSTALLING x86_64"
echo "x86_64" | ruby ./package.rb
rm -rf repo/*
mkdir repo -p
cp -rf ported/install-bases-individual-i586-pc-seaos/packaged/* repo/
cp -rf ported/install-bases-individual-x86_64-pc-seaos/packaged/* repo/

cat ported/install-bases-individual-i586-pc-seaos/packaged/core.manifest ported/install-bases-individual-x86_64-pc-seaos/packaged/core.manifest > repo/core.manifest

md5sum /srv/http/dbittman.mooo.com/sea/repo/core.manifest | awk '{print $1}' | tr -d '\n' > repo/core.manifest.md5

