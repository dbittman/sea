cd nano-2.3.1
./configure --host=i586-pc-seaos --prefix=/usr
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
