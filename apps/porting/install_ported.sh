export MTHREAD=
cd ported
MOST_PKGS="autoconf automake bash binutils coreutils diffutils e2fsprogs findutils fortune gawk grep grub less make nano nasm ncurses newlib patch readline seaos-util sed termcap which"
ALL_PKGS="$MOST_PKGS gcc"
BROKEN="gzip tar"
PKGS="$@"
if [ "$PKGS" = "all" ]; then
	PKGS="$ALL_PKGS"
fi
if [ "$PKGS" = "" ]; then
	PKGS="$ALL_PKGS"
fi
if [ "$PKGS" = "most" ]; then
	PKGS="$MOST_PKGS"
fi
if [ "$PKGS" = "broken" ]; then
	PKGS="$BROKEN"
fi

echo building: $PKGS

for i in $PKGS; do
	echo Cleaning $i...
	rm -rf $i-* 2>/dev/null
	echo Building $i...
	sh patch_$i.sh
	if [ $? = 1 ]; then
		exit 1
	fi
	sh install_$i.sh
	if [ $? = 1 ]; then
		exit 1
	fi
done
echo Cleaning up...
for i in $PKGS; do
	rm -rf $i-* 2>/dev/null
done
rm -rf seaos-util
cd ..
