#!/bin/sh
test -e built
if [ $? = 0 ]; then
	echo Toolchain already built. Remove library/toolchain/built file to force a rebuild
	exit 1
fi

test -e ../.toolchain
if [ $? != 0 ]; then
	echo Toolchain path not specified. Are you sure you\'ve run ./configure?
	exit 1
fi

read INSTALL_LOC < ../.toolchain
export INSTALL_LOC=$INSTALL_LOC

rm -rf $INSTALL_LOC/* &>/dev/null
export INSTALL_LOC
echo "Installing toolchain..."
test -e build-binutils
if [ $? != 0 ]; then
	make -s extract
fi
make compile_install_tools1
if [ $? != 0 ]; then
	echo "Error binutils install"
	exit 1
fi

export PATH=$PATH:$INSTALL_LOC/bin/
make compile_install_tools2
if [ $? != 0 ]; then
	echo "Error in gcc install"
	exit 1
fi

make compile_library_full
if [ $? != 0 ]; then
	echo "Error in library compile"
	exit 1
fi

make install_library
if [ $? != 0 ]; then
	echo "Error in library install"
	exit 1
fi

cd build-gcc
make all-target-libgcc
if [ $? != 0 ]; then
	echo "Error in gcc part 2 install"
	exit 1
fi
make install-target-libgcc
cd ..
echo "1" > built
sh ./install_extras.sh
