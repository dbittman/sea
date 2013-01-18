wget http://ftp.gnu.org/gnu/tar/tar-1.26.tar.gz
tar xfz tar-1.26.tar.gz
cd tar-1.26
patch -p1 -i ../patches/tar-1.26-seaos.patch

