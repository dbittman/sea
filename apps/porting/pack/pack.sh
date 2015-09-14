#!/bin/bash
# pack.sh - Build a package.
PACKS=$PACKSDIR
if [ "$PACKS" == "" ]; then PACKS=/usr/src/packs; fi
export INDIV_PARALLEL=4
function handle_interrupt() {
    echo "Interrupted"
	exit 1
}
trap handle_interrupt SIGINT

if [ -z "$2" ]; then
	export HOST_TRIPLET=x86_64-pc-seaos
else
	export HOST_TRIPLET=$2
fi

PACKDIR=$1
if [ "$PACKDIR" == "" ]; then
	echo You must specify a package to build.
	exit 1
fi

if ! cd $PACKS/$PACKDIR; then
	echo Cannot find $PACKDIR.
	exit 1
fi

if [[ ! -f pkg.sh ]]; then
	echo "Malformed package directory (need pkg.sh)."
	exit 1;
fi

source pkg.sh

echo --Building $NAME version $VERSION : $HOST_TRIPLET --

if ! mkdir -p src build-$HOST_TRIPLET install-$HOST_TRIPLET; then
	echo "Could not create build and src directories"
	exit 1
fi

index=0
for i in "${SOURCES[@]}"; do
	if ! (echo "${SOURCES_HASHES[$index]} src/$(basename $i)" | md5sum -c &>/dev/null); then
		echo "$NAME: Downloading $i"
		curl -L $i > src/$(basename $i)
		# verify integrity
		if ! (echo "${SOURCES_HASHES[$index]} src/$(basename $i)" | md5sum -c &>/dev/null); then
			echo "**" File $(basename $i) from $i failed integrity check.
			exit 1
		fi
	fi
	((index++))
done

cd src

echo "$NAME: Preparing sources"
prepare
touch ../build-$HOST_TRIPLET.log
truncate -s 0 ../build-$HOST_TRIPLET.log
for i in "${PATCHES[@]}"; do
	patch -p0 -N -s -r /dev/null -i ../$i &>> ../build-$HOST_TRIPLET.log
done

echo "$NAME: Building"
rm -rf install-$HOST_TRIPLET/*
mkdir -p install-$HOST_TRIPLET/root
export INSTALL_ROOT=$(realpath ../install-$HOST_TRIPLET/root)
cd ../build-$HOST_TRIPLET
build &>> ../build-$HOST_TRIPLET.log

if [ "$?" == "0" ]; then
	cd ../install-$HOST_TRIPLET/root
	find | sed "s/^\.//g" | grep "/.*" > ../$NAME-$VERSION.manifest
	echo "--Package $NAME version $VERSION built successfully--"
else
	echo "**Package $NAME version $VERSION FAILED to build--"
	exit 1
fi

