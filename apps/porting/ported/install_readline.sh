cd readline-6.2
./configure --host=i586-pc-seaos --prefix=/usr --without-curses --disable-shared
make $MTHREAD SHOBJ_LDFLAGS=-ltermcap SHOBJ_CFLAGS=
make install DESTDIR="`pwd`/../../../data/" SHOBJ_LDFLAGS= SHOBJ_CFLAGS=
