wget http://ftp.gnu.org/gnu/diffutils/diffutils-3.2.tar.gz
tar xzf diffutils-3.2.tar.gz
cd diffutils-3.2
patch -p1 -i ../patches/diffutils-3.2-seaos.patch
