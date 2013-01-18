wget http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz
tar xzf binutils-2.22.tar.gz
cd binutils-2.22
patch -p1 -i ../patches/binutils-2.22-seaos.patch
cp ../files/seaos_i386.sh ld/emulparams/
