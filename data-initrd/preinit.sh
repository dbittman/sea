echo "INIT started: root=$1"
echo -n "Loading modules..."
export PATH=$PATH:/:.:/usr/sbin
MODS="shiv keyboard pci partitions psm ata ahci ext2"
err=0
failed_mods=""
for i in $MODS; do
	if !  modprobe -d / $i ; then
		err=1
		failed_mods="$failed_mods $i"
	fi
	printf "."
done
if [[ $err == 0 ]]; then
	echo " ok"
else
	echo " FAIL"
fi

for i in $failed_mods; do
	echo "loading failed for module $i: see kernel log for details"
done

/bin/cond sh /init.sh $1
exit 0
if [[ "$1" = "/" ]]; then
	# the user instructed us to use the initrd as root. Just start a shell
	sh
else
	fsck -p -T -C $1
	printf "Mounting filesystems...\n"
	if ! mount $1 /mnt; then
		echo
		echo "Failed to mount root filesystem, falling back to initrd shell..."
		sh
	else
		chroot /mnt /bin/sh -c <<EOF "
			mount -t devfs /dev/null /dev
			. /etc/rc/boot; exit 0"
EOF
		if [ $? != 0 ] ; then
			printf "** chroot failed, dropping to initrd shell **\n"
			sh
			exit 1
		fi
	fi
fi

