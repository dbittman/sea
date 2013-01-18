cd bash-4.2
./configure --without-bash-malloc --without-curses --disable-job-control --host=i586-pc-seaos --prefix=/ --datarootdir=/usr/share
echo "#undef GETCWD_BROKEN" >> config.h
echo "#define HAVE_GETCWD 1" >> config.h
make $MTHREAD
make install DESTDIR="`pwd`/../../../data/" 
