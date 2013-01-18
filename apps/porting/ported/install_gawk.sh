cd gawk-4.0.1
./configure --prefix=/usr --host=i586-pc-seaos
make 
make install DESTDIR="`pwd`/../../../data/"

