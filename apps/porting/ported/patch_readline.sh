wget http://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz
tar xzf readline-6.2.tar.gz
cd readline-6.2
patch -p1 -i ../patches/readline-6.2-seaos.patch
