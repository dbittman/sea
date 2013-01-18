cd automake-1.13
./configure --prefix=/usr --host=i586-pc-seaos
make 
make install DESTDIR="`pwd`/../../../data/"

