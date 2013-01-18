wget http://ftp.gnu.org/gnu/bash/bash-4.2.tar.gz
tar xzf bash-4.2.tar.gz

cd bash-4.2
patch -p1 -i ../patches/bash-4.2-seaos.patch
cp ../files/psize.c builtins/psize.c
