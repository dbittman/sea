wget http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.42.2/e2fsprogs-1.42.2.tar.gz
tar xzf e2fsprogs-1.42.2.tar.gz
cd e2fsprogs-1.42.2
patch -p1 -i ../patches/e2fsprogs-1.42.2-seaos.patch
