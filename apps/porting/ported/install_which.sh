cd which-2.20
./configure --prefix=/usr --host=i586-pc-seaos
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/"
