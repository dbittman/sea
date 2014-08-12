#!/bin/sh

echo "INSTALLING x86"
echo "" | ruby ./package.rb
echo "INSTALLING x86_64"
echo "x86_64" | ruby ./package.rb
rm -rf /srv/http/dbittman.mooo.com/sea/repo/*
mkdir /srv/http/dbittman.mooo.com/sea/repo -p
cp -rf ported/install-bases-individual-i586-pc-seaos/packaged/* /srv/http/dbittman.mooo.com/sea/repo/
cp -rf ported/install-bases-individual-x86_64-pc-seaos/packaged/* /srv/http/dbittman.mooo.com/sea/repo/

cat ported/install-bases-individual-i586-pc-seaos/packaged/core.manifest ported/install-bases-individual-x86_64-pc-seaos/packaged/core.manifest > /srv/http/dbittman.mooo.com/sea/repo/core.manifest

md5sum /srv/http/dbittman.mooo.com/sea/repo/core.manifest | awk '{print $1}' | tr -d '\n' > /srv/http/dbittman.mooo.com/sea/repo/core.manifest.md5

