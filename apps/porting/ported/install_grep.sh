cd grep-2.12
./configure --prefix=/usr --host=i586-pc-seaos
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/"
