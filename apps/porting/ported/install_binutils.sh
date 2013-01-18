cd binutils-2.22
./configure --host=i586-pc-seaos --prefix=/usr --disable-nls
make  $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 

cp `pwd`/../../../data/usr/bin/ar `pwd`/../../../data/usr/i586-pc-seaos/i586-pc-seaos-ar
cp `pwd`/../../../data/usr/bin/strip `pwd`/../../../data/usr/i586-pc-seaos/i586-pc-seaos-strip
cp `pwd`/../../../data/usr/bin/ld `pwd`/../../../data/usr/i586-pc-seaos/i586-pc-seaos-ld
