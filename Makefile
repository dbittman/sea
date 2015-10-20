include local_make.inc

SHELL=/bin/bash
BUILDCFG ?= default
export BUILDCFG
KDIR=seakernel
BUILDCONTAINER=build
BUILDDIR=$(BUILDCONTAINER)/$(BUILDCFG)
TOOLCHAINDIR=$(shell realpath $(BUILDCONTAINER)/toolchain)
include $(BUILDCONTAINER)/$(BUILDCFG)/make.inc
ARCH ?= x86_64

include $(KDIR)/make.inc

QEMU_NET=-netdev tap,helper=/usr/lib/qemu/qemu-bridge-helper,id=br0 -device rtl8139,netdev=br0,id=nic1

QEMU_NET_SOCKET=-device rtl8139,netdev=net0 -netdev socket,id=net0,connect=127.0.0.1:8010
QEMU_NET_SOCKET_SERVER=-device rtl8139,netdev=net0 -netdev socket,id=net0,listen=:8010

QEMU_EXTRA=-device ahci,id=ahci0 -drive if=none,file=$(BUILDDIR)/hd.img,format=raw,id=drive-sata0-0-0 -device ide-drive,bus=ahci0.0,drive=drive-sata0-0-0,id=sata0-0-0 

QEMU_PCI_PASSTHROUGH=-device pci-assign,host=$(PCI_DEVICE)

all: $(BUILDDIR) updatehd

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/initrd.tar: $(shell find data-initrd $(KDIR)/$(BUILDDIR)/drivers/built) $(addprefix apps/install-base-$(ARCH)-pc-seaos/, $(INITRD_ARCH_FILES))
	@echo "Building initrd..."
	@tar cf $(BUILDDIR)/initrd.tar -C data-initrd .
	@tar rf $(BUILDDIR)/initrd.tar -C apps/install-base-$(ARCH)-pc-seaos $(INITRD_ARCH_OPTIONS) $(INITRD_ARCH_FILES)
	@tar rf $(BUILDDIR)/initrd.tar -C $(KDIR)/$(BUILDDIR)/drivers/built .

newhd $(BUILDDIR)/hd.img:
	@sudo bash tools/chd.sh $(ARCH)-pc-seaos $(BUILDDIR)/hd.img $(BUILDCFG)

$(KDIR)/$(BUILDDIR)/skernel: FORCE
	PATH=$$PATH:$(TOOLCHAINDIR)/bin make $(MAKE_FLAGS) -s -C $(KDIR)

kernel: $(KDIR)/$(BUILDDIR)/skernel

FORCE:

reset:
	@-sudo umount /mnt
	@-sudo losetup -d /dev/loop2

.PHONY: updatehd
updatehd: $(KDIR)/$(BUILDDIR)/skernel $(BUILDDIR)/initrd.tar $(BUILDDIR)/hd.img
	@echo updating hd image...
	@sudo sh tools/open_hdimage.sh $(BUILDDIR)/hd.img
	@sudo mkdir -p /mnt/sys/modules-${VERSION}/
	@sudo cp -rf $(KDIR)/$(BUILDDIR)/drivers/built/* /mnt/sys/modules-${VERSION}/ 2>/dev/null
	@sudo cp -rf $(BUILDDIR)/initrd.tar /mnt/sys/initrd
	@sudo cp -rf $(KDIR)/$(BUILDDIR)/skernel /mnt/sys/kernel
	@sudo gzip -f /mnt/sys/initrd
	@sudo sh tools/close_hdimage.sh
	@sudo chmod a+rw $(BUILDDIR)/hd.img 

.PHONY: apps64 apps_port apps_seaos

apps:
	@export PATH=$$(pwd)/apps/porting/pack:$$PATH:$(TOOLCHAINDIR)/bin ; export PACKSDIR=$$(pwd)/apps/porting/pack/packs; apps/porting/pack/build-all.sh x86_64-pc-seaos; apps/porting/pack/aggregate.sh apps/install-base-x86_64-pc-seaos x86_64-pc-seaos

apps_clean:
	rm -rf apps/install-base-*; cd apps/porting/pack && PACKSDIR=packs ./clean-all.sh

apps_distclean:
	rm -rf apps/install-base-*; cd apps/porting/pack && PACKSDIR=packs ./clean-all.sh -s

.PHONY : toolchain
toolchain:
	echo $(TOOLCHAINDIR)
	mkdir -p $(TOOLCHAINDIR)
	@PATH=$$PATH:$(TOOLCHAINDIR)/bin cd toolchain && $(MAKE) TOOLCHAINDIR=$(TOOLCHAINDIR) TRIPLET=$(ARCH)-pc-seaos
	
man:
	sh tools/gen_man.sh

config:
	@BUILDCFG=$(BUILDCFG) make -s -C seakernel config

clean:
	@make -s -C seakernel clean
	@rm -rf $(BUILDDIR)

qemu:
	@qemu-system-x86_64 -rtc base=utc,clock=host -m 2000 -serial stdio -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_LOCAL)

qemu_net:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_NET) $(QEMU_LOCAL)

qemu_net_socket:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_NET_SOCKET) $(QEMU_LOCAL)

qemu_net_socket_server:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_NET_SOCKET_SERVER) $(QEMU_LOCAL)

qemu_kvm:
	@qemu-system-x86_64 -cpu qemu64,+vmx -m 2000 -localtime -serial stdio -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_LOCAL)

qemu_gdb:
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -serial pty -S -s -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_LOCAL)

qemu_pci:
	@sudo -E qemu-system-x86_64 -boot order=c -localtime -m 2000 -serial stdio -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_PCI_PASSTHROUGH) $(QEMU_LOCAL)

bochs:
	@bochs

gcc_print_optimizers:
	@PATH=$$PATH:$(TOOLCHAINDIR)/bin $(MAKE) -s -C seakernel gcc_print_optimizers

install:
	true

