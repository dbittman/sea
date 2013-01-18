wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.16.tar.xz
tar xJf coreutils-8.16.tar.xz

cd coreutils-8.16
patch -p1 -i ../patches/coreutils-8.16-seaos.patch
