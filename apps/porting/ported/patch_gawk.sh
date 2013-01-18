wget http://ftp.gnu.org/gnu/gawk/gawk-4.0.1.tar.gz
tar xfz gawk-4.0.1.tar.gz
cd gawk-4.0.1
patch -p1 -i ../patches/gawk-4.0.1-seaos.patch

