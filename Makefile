include seakernel/make.inc

include local_make.inc

QEMU_NET=-net nic,model=rtl8139,vlan=2 -net socket,vlan=2,connect=127.0.0.1:8010 

all: build

apps_port:
	@PATH=$$PATH:`cat .toolchain` cd apps/porting && ruby build.rb all-all

apps_seaos:
	@PATH=$$PATH:`cat .toolchain` cd apps/porting && ruby build.rb all-seaosutil

newhd:
	@sudo zsh tools/chd.sh i586-pc-seaos

newhd64:
	@sudo zsh tools/chd.sh x86_64-pc-seaos

writehd:
	@zsh tools/copy_to_hd.sh

toolchain: toolchain/built

toolchain/built:
	@cd toolchain && ruby build.rb all

seakernel/skernel:
	@PATH=$$PATH:`cat .toolchain`/bin $(MAKE) -j2 -s -C seakernel all

man:
	sh tools/gen_man.sh

hd.img: newhd

config:
	@make -s -C seakernel config

defconfig:
	@make -s -C seakernel defconfig

build: seakernel/skernel
	@echo updating hd image...
	@sudo sh tools/open_hdimage.sh
	@sudo mkdir -p ./mnt/sys/modules-${KERNEL_VERSION}/
	@sudo cp -rf seakernel/drivers/built/* ./mnt/sys/modules-${KERNEL_VERSION}/ 2>/dev/null
	@sudo cp -rf seakernel/initrd.img ./mnt/sys/initrd
	@sudo cp -rf seakernel/skernel ./mnt/sys/kernel
	@sudo mv seakernel/skernel skernel
	@sudo sh tools/close_hdimage.sh
	@sudo chmod a+rw hd.img 
clean:
	@make -s -C seakernel clean
	@rm hd.img hd2.img

test_t:
	@qemu-system-x86_64 -localtime -m 512 -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_NET) $(QEMU_LOCAL)

test_1:
	@-sudo mkdir /tmp_t 2> /dev/null
	@sudo mount -t tmpfs -o size=2g tmpfs /tmp_t
	@cp hd.img /tmp_t/hd.img
	@qemu-system-x86_64 -serial stdio -smp 1 -drive file=/tmp_t/hd.img,if=ide,cache=unsafe,media=disk -localtime -m 1024 -boot a
	@sudo umount /tmp_t
