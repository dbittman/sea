cd termcap-1.3.1
./configure --host=i586-pc-seaos --prefix=/usr
make $MTHREAD CC=i586-pc-seaos-gcc AR=i586-pc-seaos-ar RANLIB=i586-pc-seaos-ranlib
cp libtermcap.a ../../../data/usr/lib/
