echo updating gcc configuration
for i in `find -name "config.h"`; do
	echo -e "#undef HAVE_MMAP\n#undef HAVE_MMAP_ANON\n#undef HAVE_MMAP_DEV_ZERO\n#undef HAVE_MMAP_FILE\n" >> $i
done

for i in `find -name "auto-host.h"`; do
	echo -e "#undef HAVE_MMAP\n#undef HAVE_MMAP_ANON\n#undef HAVE_MMAP_DEV_ZERO\n#undef HAVE_MMAP_FILE\n" >> $i
done
