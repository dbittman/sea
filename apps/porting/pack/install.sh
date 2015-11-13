#!/bin/bash

if [ "$PACKSDIR" == "" ]; then
	PACKSDIR=/usr/src/packs
fi

if [ "$DESTDIR" == "" ]; then
	DESTDIR=/
fi

if [ "$1" == "" ]; then
	echo Specify a package
	exit 1
fi

if [ "$TRIPLET" == "" ]; then
	TRIPLET=$(uname -m)-pc-$(uname -s | tr '[:upper:]' '[:lower:]')
fi

if [ ! -d $PACKSDIR/$1/install-$TRIPLET/root ]; then
	echo Package $1 not currently built for this platform
	exit 1
fi

echo Installing for host $TRIPLET
cp -rf $PACKSDIR/$1/install-$TRIPLET/root/* $DESTDIR
cp -f $PACKSDIR/$1/install-$TRIPLET/*.manifest $DESTDIR/var/pack/manifests/

