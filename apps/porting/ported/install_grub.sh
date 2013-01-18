cd grub-0.97
./configure --host=i586-pc-seaos --prefix=/usr --without-curses
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
