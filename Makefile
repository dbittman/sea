include seakernel/make.inc

include local_make.inc

QEMU_NET=-netdev tap,helper=/usr/lib/qemu/qemu-bridge-helper,id=br0 -device rtl8139,netdev=br0,id=nic1

QEMU_NET_SOCKET=-device rtl8139,netdev=net0 -netdev socket,id=net0,connect=127.0.0.1:8010
QEMU_NET_SOCKET_SERVER=-device rtl8139,netdev=net0 -netdev socket,id=net0,listen=:8010

QEMU_EXTRA=-device ahci,id=ahci0 -drive if=none,file=hd.img,format=raw,id=drive-sata0-0-0 -device ide-drive,bus=ahci0.0,drive=drive-sata0-0-0,id=sata0-0-0 

QEMU_PCI_PASSTHROUGH=-device pci-assign,host=$(PCI_DEVICE)

all: build

.PHONY: apps
apps:
	@cd apps && ./ship.rb --yes update sync +ALL

apps64:
	@cd apps && ./ship.rb -c ship64.yaml --yes update sync +ALL

apps_port:
	@PATH=$$PATH:`cat .toolchain` cd apps/porting && ruby build.rb all-all

apps_seaos:
	@PATH=$$PATH:`cat .toolchain` cd apps/porting && ruby build.rb clean-seaosutil cleansrc-seaosutil all-seaosutil

newhd:
	@sudo zsh tools/chd.sh i586-pc-seaos

newhd64:
	@sudo zsh tools/chd.sh x86_64-pc-seaos

writehd:
	@zsh tools/copy_to_hd.sh
.PHONY : toolchain
toolchain:
	@cd toolchain && ruby build.rb all-all
	
seakernel/skernel:
	@PATH=$$PATH:`cat .toolchain`/bin $(MAKE) -j2 -s -C seakernel all

modules:
	@PATH=$$PATH:`cat .toolchain`/bin $(MAKE) -j2 -s -C seakernel modules

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
	@sudo mkdir -p /mnt/sys/modules-${VERSION}/
	@sudo cp -rf seakernel/drivers/built/* /mnt/sys/modules-${VERSION}/ 2>/dev/null
	@sudo cp -rf seakernel/initrd.img /mnt/sys/initrd
	@sudo cp -rf seakernel/skernel /mnt/sys/kernel
	@sudo mv seakernel/skernel skernel
	@sudo sh tools/close_hdimage.sh
	@sudo chmod a+rw hd.img 
clean:
	@make -s -C seakernel clean
	@rm hd.img hd2.img

qemu:
	@qemu-system-x86_64 -rtc base=utc,clock=host -m 2000 -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_LOCAL)

qemu_net:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_NET) $(QEMU_LOCAL)

qemu_net_socket:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_NET_SOCKET) $(QEMU_LOCAL)

qemu_net_socket_server:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_NET_SOCKET_SERVER) $(QEMU_LOCAL)

qemu_kvm:
	@qemu-system-x86_64 -cpu qemu64,+vmx -m 2000 -localtime -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_LOCAL)

qemu_gdb:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -serial pty -S -s -drive file=hd.img,if=ide,cache=writeback $(QEMU_NET) $(QEMU_LOCAL)

qemu_pci:
	@sudo -E qemu-system-x86_64 -boot order=c -localtime -m 2000 -serial stdio -drive file=hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_PCI_PASSTHROUGH) $(QEMU_LOCAL)

bochs:
	@bochs

gcc_print_optimizers:
	@PATH=$$PATH:`cat .toolchain`/bin $(MAKE) -s -C seakernel gcc_print_optimizers
