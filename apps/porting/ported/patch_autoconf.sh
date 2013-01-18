wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz
tar xfJ autoconf-2.69.tar.xz
cd autoconf-2.69
patch -p1 -i ../patches/autoconf-2.69-seaos.patch

