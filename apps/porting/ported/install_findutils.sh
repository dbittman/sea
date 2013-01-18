cd findutils-4.4.2
./configure --prefix=/usr --host=i586-pc-seaos
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/"
