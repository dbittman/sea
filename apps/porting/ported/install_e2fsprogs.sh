cd e2fsprogs-1.42.2
./configure --host=i586-pc-seaos --prefix=/usr --disable-nls --disable-uuidd
make $MTHREAD RDYNAMIC=
make install DESTDIR="`pwd`/../../../data/"
