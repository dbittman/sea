cd autoconf-2.69
./configure --prefix=/usr --host=i586-pc-seaos
make 
make install DESTDIR="`pwd`/../../../data/"

