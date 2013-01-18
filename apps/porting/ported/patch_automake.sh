wget http://ftp.gnu.org/gnu/automake/automake-1.13.tar.xz
tar xfJ automake-1.13.tar.xz
cd automake-1.13
patch -p1 -i ../patches/automake-1.13-seaos.patch

