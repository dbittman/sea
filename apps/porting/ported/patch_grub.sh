wget ftp://alpha.gnu.org/gnu/grub/grub-0.97.tar.gz
tar xzf grub-0.97.tar.gz

cd grub-0.97
patch -p1 -i ../patches/grub-0.97-seaos.patch
