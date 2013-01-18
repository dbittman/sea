wget http://ftp.gnu.org/gnu/findutils/findutils-4.4.2.tar.gz
tar xzf findutils-4.4.2.tar.gz
cd findutils-4.4.2
patch -p1 -i ../patches/findutils-4.4.2-seaos.patch
