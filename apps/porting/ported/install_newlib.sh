cd newlib-2.0.0
./configure --target=i586-pc-seaos --prefix=/usr --exec-prefix=/usr --libdir=/usr/lib --includedir=/usr/include
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
