wget http://ftp.gnu.org/gnu/gcc/gcc-4.7.1/gcc-4.7.1.tar.gz
tar xzf gcc-4.7.1.tar.gz
cd gcc-4.7.1
patch -p1 -i ../patches/gcc-4.7.1-seaos.patch
patch -p1 -i ../patches/gcc-4.7.2-texinfo.patch
cp ../files/seaos.h gcc/config/
cd libstdc++-v3
autoconf2.64
cd ..
