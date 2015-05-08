include local_make.inc

BUILDCFG ?= default
export BUILDCFG
KDIR=seakernel
BUILDCONTAINER=build
BUILDDIR=$(BUILDCONTAINER)/$(BUILDCFG)
ARCH ?= i586

include $(KDIR)/make.inc

QEMU_NET=-netdev tap,helper=/usr/lib/qemu/qemu-bridge-helper,id=br0 -device rtl8139,netdev=br0,id=nic1

QEMU_NET_SOCKET=-device rtl8139,netdev=net0 -netdev socket,id=net0,connect=127.0.0.1:8010
QEMU_NET_SOCKET_SERVER=-device rtl8139,netdev=net0 -netdev socket,id=net0,listen=:8010

QEMU_EXTRA=-device ahci,id=ahci0 -drive if=none,file=$(BUILDDIR)/hd.img,format=raw,id=drive-sata0-0-0 -device ide-drive,bus=ahci0.0,drive=drive-sata0-0-0,id=sata0-0-0 

QEMU_PCI_PASSTHROUGH=-device pci-assign,host=$(PCI_DEVICE)

all: $(BUILDDIR) updatehd

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/initrd.tar: $(shell find data-initrd/noarch data-initrd/$(ARCH) $(KDIR)/$(BUILDDIR)/drivers/built)
	@echo "Building initrd..."
	tar cf $(BUILDDIR)/initrd.tar -C data-initrd/noarch .
	tar rf $(BUILDDIR)/initrd.tar -C data-initrd/$(ARCH) .
	tar rf $(BUILDDIR)/initrd.tar -C $(KDIR)/$(BUILDDIR)/drivers/built .

$(BUILDDIR)/hd.img:
	@sudo sh tools/chd.sh $(ARCH)-pc-seaos $(BUILDDIR)/hd.img

$(KDIR)/$(BUILDDIR)/skernel: FORCE
	make -s -C $(KDIR)

FORCE:

reset:
	@-sudo umount /mnt
	@-sudo losetup -d /dev/loop2

updatehd: $(KDIR)/$(BUILDDIR)/skernel $(BUILDDIR)/initrd.tar $(BUILDDIR)/hd.img
	@echo updating hd image...
	@sudo sh tools/open_hdimage.sh $(BUILDDIR)/hd.img
	@sudo mkdir -p /mnt/sys/modules-${VERSION}/
	@sudo cp -rf $(KDIR)/$(BUILDDIR)/drivers/built/* /mnt/sys/modules-${VERSION}/ 2>/dev/null
	@sudo cp -rf $(BUILDDIR)/initrd.tar /mnt/sys/initrd
	@sudo cp -rf $(KDIR)/$(BUILDDIR)/skernel /mnt/sys/kernel
	@sudo sh tools/close_hdimage.sh
	@sudo chmod a+rw $(BUILDDIR)/hd.img 

.PHONY: apps apps64 apps_port apps_seaos
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
	
man:
	sh tools/gen_man.sh

config:
	@make -s -C seakernel config

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
	@qemu-system-x86_64 -localtime -m 2000 -serial stdio -serial pty -S -s -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_NET) $(QEMU_LOCAL)

qemu_pci:
	@sudo -E qemu-system-x86_64 -boot order=c -localtime -m 2000 -serial stdio -drive file=$(BUILDDIR)/hd.img,if=ide,cache=writeback $(QEMU_EXTRA) $(QEMU_PCI_PASSTHROUGH) $(QEMU_LOCAL)

bochs:
	@bochs

gcc_print_optimizers:
	@PATH=$$PATH:`cat .toolchain`/bin $(MAKE) -s -C seakernel gcc_print_optimizers

