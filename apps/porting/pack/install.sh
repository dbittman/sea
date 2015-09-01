#!/bin/bash

if [ "$PACKSDIR" == "" ]; then
	PACKSDIR=/usr/src/packs
fi

if [ "$1" == "" ]; then
	echo Specify a package
	exit 1
fi

TRIPLET=$(uname -m)-pc-$(uname -s | tr '[:upper:]' '[:lower:]')

if [ ! -d $PACKSDIR/$1/install-$TRIPLET/root ]; then
	echo Package $1 not currently built for this platform
	exit 1
fi

echo Installing for host $TRIPLET
cp -rf $PACKSDIR/$1/install-$TRIPLET/root/* /
cp -f $PACKSDIR/$1/install-$TRIPLET/*.manifest /var/pack/manifests/

