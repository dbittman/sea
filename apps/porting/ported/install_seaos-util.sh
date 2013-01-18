cd seaos-util
./configure --host=i586-pc-seaos --prefix=/
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
