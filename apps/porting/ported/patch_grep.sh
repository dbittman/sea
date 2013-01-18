wget http://ftp.gnu.org/gnu/grep/grep-2.12.tar.xz
tar xJf grep-2.12.tar.xz
cd grep-2.12
patch -p1 -i ../patches/grep-2.12-seaos.patch
