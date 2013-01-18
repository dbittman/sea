cd ported
archived="`basename $1`"
rm -f $archived 2>/dev/null
wget $1
NAME="$2"
echo "extracting $archived..."
if [[ $archived == *.tar.gz ]]; then
	tar xzf $archived
	DIR="`basename $archived .tar.gz`"
	EXT=".tar.gz"
	TAR_ARG="z"
elif [[ $archived == *.tar.bz2 ]]; then
	tar xjf $archived
	DIR="`basename $archived .tar.bz2`"
	EXT=".tar.bz2"
	TAR_ARG="j"
elif [[ $archived == *.tar.xz ]]; then
	tar xJf $archived
	DIR="`basename $archived .tar.xz`"
	EXT=".tar.xz"
	TAR_ARG="J"
fi

cp -r $DIR $DIR-seaos
echo -n "searching for config.sub..."

if [ -e $DIR-seaos/config.sub ]; then
	CSLOC=config.sub
elif [ -e $DIR-seaos/build-aux/config.sub ]; then
	CSLOC=build-aux/config.sub
elif [ -e $DIR-seaos/config/config.sub ]; then
	CSLOC=config/config.sub
elif [ -e $DIR-seaos/support/config.sub ]; then
	CSLOC=support/config.sub
elif [ -e $DIR-seaos/scripts/config.sub ]; then
	CSLOC=scripts/config.sub
elif [ -e $DIR-seaos/tools/config.sub ]; then
	CSLOC=tools/config.sub
else
	echo "couldn't find config.sub."
	CSLOC="q"
	while [ $CSLOC = "q" ]; do
		echo -ne "please enter config.sub location: "
		read TMP_I
		if [ -e $DIR-seaos/$TMP_I ]; then
			CSLOC="$TMP_I"
		else
			echo "$DIR-seaos/$TMP_I does not exist!"
		fi
	done

fi
echo "found: $DIR-seaos/$CSLOC"
cp files/config.sub $DIR-seaos/$CSLOC
echo "press enter when you're ready to make the patch file"
echo -n ":"
read $TMP_I
echo generating patch file...
diff -crB $DIR $DIR-seaos > patches/$DIR-seaos.patch

echo creating scripts...

cat > install_$NAME.sh << EOF
cd $DIR
./configure --prefix=/usr --host=i586-pc-seaos
make $MTHREAD
make install DESTDIR="\`pwd\`/../../../data/"

EOF

cat > patch_$NAME.sh << EOF
wget $1
tar xf$TAR_ARG $archived
cd $DIR
patch -p1 -i ../patches/$DIR-seaos.patch

EOF

if [[ $3 != "--keep" ]]; then
	echo cleaning up...
	rm -rf $archived $DIR $DIR-seaos
fi

cd ..
