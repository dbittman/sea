cd gzip-1.4
./configure --prefix=/usr --host=i586-pc-seaos
make 
make install DESTDIR="`pwd`/../../../data/"

