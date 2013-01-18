wget http://ftp.gnu.org/gnu/sed/sed-4.2.tar.gz
tar xzf sed-4.2.tar.gz
cd sed-4.2
patch -p1 -i ../patches/sed-4.2-seaos.patch
