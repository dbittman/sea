cd tar-1.26
./configure --prefix=/usr --host=i586-pc-seaos
make 
make install DESTDIR="`pwd`/../../../data/"

