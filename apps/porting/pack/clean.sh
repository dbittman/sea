#!/bin/bash

if [ "$1" == "" ]; then
	echo Specify a package to clean.
	exit 1
fi

if ! cd $PACKSDIR/$1; then
	echo Package $1 doesn\'t exist.
	exit 1
fi

rm -rf build-* install-*

if [ "$2" == "-s" ]; then
	rm -rf src
fi

