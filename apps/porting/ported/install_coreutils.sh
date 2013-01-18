cd coreutils-8.16
./configure --host=i586-pc-seaos --prefix=/ --disable-nls --enable-no-install-program=hostname,su --datarootdir=/usr/share
make $MTHREAD OPTIONAL_PKGLIB_PROGS=
make install DESTDIR="`pwd`/../../../data/" OPTIONAL_PKGLIB_PROGS=
cp src/su ../../../data/bin/
