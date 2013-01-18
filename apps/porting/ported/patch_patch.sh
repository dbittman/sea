wget http://ftp.gnu.org/gnu/patch/patch-2.6.tar.gz
tar xzf patch-2.6.tar.gz
cd patch-2.6
patch -p1 -i ../patches/patch-2.6-seaos.patch
