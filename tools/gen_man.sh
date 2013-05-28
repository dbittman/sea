#/bin/sh
mkdir -p tools/man_gen_tmp
cp -rf apps/data-i586-pc-seaos/usr/man apps/data-i586-pc-seaos/usr/share/man doc/man tools/man_gen_tmp/
rm -rf tools/man_gen_tmp/text
mkdir -p tools/man_gen_tmp/text

cd tools/man_gen_tmp/man
# for each manual directory (1 thru 8)
for dir in `ls`; do
	mkdir -p ../text/$dir
	cd $dir
	for file in `ls`; do
		echo -ne "converting in $dir: $file\e[K\r"
		man ./$file | col -bx > ../../text/$dir/${file%%.*}
	done
	cd ..
	
done

