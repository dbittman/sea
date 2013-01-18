cd ncurses-5.9
./configure --host=i586-pc-seaos --enable-termcap --disable-database --prefix=/usr/ --without-cxx --without-cxx-binding --oldincludedir=/usr/include --includedir=/usr/include
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
