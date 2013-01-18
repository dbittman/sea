cd make-3.82
./configure --host=i586-pc-seaos --prefix=/usr
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
