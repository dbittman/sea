include seakernel/make.inc

QEMU_NET=-net nic,model=rtl8139,vlan=2 -net socket,vlan=2,connect=127.0.0.1:8010 

all: build

apps_port:
	@PATH=$$PATH:`cat .toolchain` cd apps/porting && sh install_ported.sh all

apps_seaos:
	@PATH=$$PATH:`cat .toolchain` cd apps/porting && sh install_ported.sh seaos-util

newhd:
	@zsh tools/chd.sh

writehd:
	@zsh tools/copy_to_hd.sh

toolchain: toolchain/built

toolchain/built:
	@cd toolchain && ruby build.rb all

seakernel/skernel:
	@PATH=$$PATH:`cat .toolchain` $(MAKE) -j2 -s -C seakernel all

man:
	sh tools/gen_man.sh

hd.img: newhd

config:
	@make -s -C seakernel config

defconfig:
	@make -s -C seakernel defconfig

build: seakernel/skernel
	@echo updating hd image...
	@sh tools/open_hdimage.sh
	@mkdir -p ./mnt/sys/modules-${KERNEL_VERSION}/
	@-cp -rf seakernel/drivers/built/* ./mnt/sys/modules-${KERNEL_VERSION}/ 2>/dev/null
	@cp -rf seakernel/initrd.img ./mnt/sys/initrd
	@cp -rf seakernel/skernel ./mnt/sys/kernel
	@mv seakernel/skernel skernel
	@sh tools/close_hdimage.sh

clean:
	@make -s -C seakernel clean
	@rm hd.img hd2.img

test_t:
# <<<<<<< HEAD
	@qemu-system-i386 -localtime -smp 10 -enable-kvm -m 512 -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_NET)
# =======
#	@qemu-system-i386 -localtime  -m 512 -serial stdio -smp 1 -drive file=hd.img,if=ide,cache=none $(QEMU_NET)
#>>>>>>> 611ba890dff2d94d115633d7b9bed7d8e104eb09

test_1:
	@-sudo mkdir /tmp_t 2> /dev/null
	@sudo mount -t tmpfs -o size=2g tmpfs /tmp_t
	@cp hd.img /tmp_t/hd.img
	@qemu-system-i386 -serial stdio -smp 1 -drive file=/tmp_t/hd.img,if=ide,cache=unsafe,media=disk -localtime -m 1024 -boot a
	@sudo umount /tmp_t
