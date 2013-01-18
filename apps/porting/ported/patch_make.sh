wget http://ftp.gnu.org/gnu/make/make-3.82.tar.gz
tar xzf make-3.82.tar.gz
cd make-3.82
patch -p1 -i ../patches/make-3.82-seaos.patch
