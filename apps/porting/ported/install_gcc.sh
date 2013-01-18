cd gcc-4.7.1
./configure --host=i586-pc-seaos --prefix=/usr --enable-lto --disable-nls --enable-languages=c,c++ CC_FOR_TARGET=i586-pc-seaos-gcc AR_FOR_TARGET=i586-pc-seaos-ar AS_FOR_TARGET=i586-pc-seaos-as RANLIB_FOR_TARGET=i586-pc-seaos-ranlib STRIP_FOR_TARGET=i586-pc-seaos-strip
for i in `find -name "config.h"`; do
	echo -e "#undef HAVE_MMAP\n#undef HAVE_MMAP_ANON\n#undef HAVE_MMAP_DEV_ZERO\n#undef HAVE_MMAP_FILE\n" >> $i
done

for i in `find -name "auto-host.h"`; do
	echo -e "#undef HAVE_MMAP\n#undef HAVE_MMAP_ANON\n#undef HAVE_MMAP_DEV_ZERO\n#undef HAVE_MMAP_FILE\n" >> $i
done

make all-gcc $MTHREAD  CC_FOR_TARGET=i586-pc-seaos-gcc AR_FOR_TARGET=i586-pc-seaos-ar AS_FOR_TARGET=i586-pc-seaos-as RANLIB_FOR_TARGET=i586-pc-seaos-ranlib STRIP_FOR_TARGET=i586-pc-seaos-strip
make install-gcc DESTDIR="`pwd`/../../../data/"   CC_FOR_TARGET=i586-pc-seaos-gcc AR_FOR_TARGET=i586-pc-seaos-ar AS_FOR_TARGET=i586-pc-seaos-as RANLIB_FOR_TARGET=i586-pc-seaos-ranlib STRIP_FOR_TARGET=i586-pc-seaos-strip
make all-target-libgcc  CC_FOR_TARGET=i586-pc-seaos-gcc AR_FOR_TARGET=i586-pc-seaos-ar AS_FOR_TARGET=i586-pc-seaos-as RANLIB_FOR_TARGET=i586-pc-seaos-ranlib STRIP_FOR_TARGET=i586-pc-seaos-strip
make install-target-libgcc DESTDIR="`pwd`/../../../data/"  CC_FOR_TARGET=i586-pc-seaos-gcc AR_FOR_TARGET=i586-pc-seaos-ar AS_FOR_TARGET=i586-pc-seaos-as RANLIB_FOR_TARGET=i586-pc-seaos-ranlib STRIP_FOR_TARGET=i586-pc-seaos-strip
