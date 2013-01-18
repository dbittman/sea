cd less-443
./configure --host=i586-pc-seaos --prefix=/usr
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
