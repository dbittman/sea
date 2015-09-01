#!/bin/sh

SUBDIR=$PACKSDIR

DEST=$1
TRIPLET=$2

if [ "$DEST" == "" ]; then
	echo Specify a destination directory
	exit 1
fi

if [ "$TRIPLET" == "" ]; then
	echo Specify a host triplet "(i586-pc-seaos, x86_64-pc-seaos ...)"
	exit 1
fi

mkdir -p $DEST $DEST/var/pack/manifests $DEST/usr/src/packs

for i in $(ls $SUBDIR); do
	echo Aggregating $i...
	if [ -d $SUBDIR/$i/install-$TRIPLET/root ]; then
		rsync -a $SUBDIR/$i/install-$TRIPLET/root/* $DEST/
		rsync -a $SUBDIR/$i/install-$TRIPLET/*.manifest $DEST/var/pack/manifests/
		rsync -a --exclude build-\* --exclude install-\* --exclude src $SUBDIR/$i $DEST/usr/src/packs/
	else
		echo Package $i not built, skipping aggregation.
	fi
done
