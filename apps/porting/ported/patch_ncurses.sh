wget http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
tar xzf ncurses-5.9.tar.gz
cd ncurses-5.9
patch -p1 -i ../patches/ncurses-5.9-seaos.patch
