cd patch-2.6
./configure --prefix=/usr --host=i586-pc-seaos
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/"
