#!/bin/bash

sh ./tools/open_hdimage.sh $2

echo copying data/ to hd.img...
rsync --exclude .git --exclude .directory -rlp data/* /mnt/

sh ./tools/close_hdimage.sh

