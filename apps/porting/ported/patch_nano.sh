wget http://ftp.gnu.org/gnu/nano/nano-2.3.1.tar.gz
tar xzf nano-2.3.1.tar.gz
cd nano-2.3.1
patch -p1 -i ../patches/nano-2.3.1-seaos.patch
