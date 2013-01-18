rm tools/list
cd apps/data/bin
for i in `find .`; do
	if [ ! "$i" == "." ]; then
	if [ -f $i ]; then
		echo \"../apps/data/bin/$i\" \"/bin/${i:2}\" >> ../../../tools/list
	fi
	fi
done

cd ../../../data/
for i in `find .`; do
	if [ ! "$i" == "." ]; then
	if [ -f $i ]; then
		echo \"../data/$i\" \"${i:1}\" >> ../tools/list
	fi
	fi
done
cd ../system
make -s
cp skernel ../tools/cd/kernel

cd drivers/built
for i in `find .`; do
	if [ ! "$i" == "." ]; then
	if [ -f $i ]; then
		echo \"drivers/built/$i\" \"/sys/modules/${i:2}\" >> ../../../tools/list
	fi
	fi
done
cd ../..
xargs -a ../tools/list tools/mkird ../tools/cd/preinit.sh /preinit.sh

cp initrd.img ../tools/cd/initrd

cd ../tools
genisoimage -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o cd.iso cd
cd ..
