wget http://ftp.gnu.org/gnu/gzip/gzip-1.4.tar.gz
tar xfz gzip-1.4.tar.gz
cd gzip-1.4
patch -p1 -i ../patches/gzip-1.4-seaos.patch

