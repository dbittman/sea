cd nasm-2.10
./configure --host=i586-pc-seaos --prefix=/usr
make $MTHREADS
cp nasm ../../../data/usr/bin
