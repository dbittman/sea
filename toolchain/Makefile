# Makefile for the toolchain
# INSTALL_LOC should be provided by the script
PREFIX=$(INSTALL_LOC)

install_tools:
	@./install_toolchain.sh

patch_binutils:
	wget http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.bz2
	tar xjf binutils-2.22.tar.bz2
	cd binutils-2.22; patch -p1 -i ../binutils-2.22-seaos.patch
	cp seaos_i386.sh seaos_x86_64.sh binutils-2.22/ld/emulparams/
	rm binutils-2.22.tar.bz2

patch_gcc:
	wget http://ftp.gnu.org/gnu/gcc/gcc-4.7.1/gcc-4.7.1.tar.gz
	tar xzf gcc-4.7.1.tar.gz
	cd gcc-4.7.1; patch -p1 -i ../gcc-4.7.1-seaos.patch
	cd gcc-4.7.1; patch -p1 -i ../gcc-4.7.2-texinfo.patch
	cp seaos.h seaos64.h gcc-4.7.1/gcc/config/
	cd gcc-4.7.1/libstdc++-v3; /opt/autoconf/2.64/bin/autoconf
	rm gcc-4.7.1.tar.gz

patch_newlib2:
	@tar xfz newlib-1.20.0.tar.gz
	@cd newlib-1.20.0; patch -p1 -i ../newlib-1.20.0-seaos.patch
	@cd newlib-1.20.0/newlib/libc/sys; autoconf; cp -rf ../../../../newlib-sys-seaos seaos; autoconf; cd seaos; ACLOCAL=aclocal-1.12 AUTOMAKE=automake-1.12 autoreconf; automake-1.12

patch_newlib:
	@wget ftp://sources.redhat.com/pub/newlib/newlib-1.20.0.tar.gz
	@make -s patch_newlib2

extract:
	@echo "Downloading and patching tools..."
	@mkdir build-newlib build-gcc build-binutils
	make -s patch_gcc
	make -s patch_binutils
	
compile_install_tools1:
	@echo -n "Configuring binutils... "
	@cd build-binutils; sh ../binutils-2.22/configure --target=$(TARGET) --prefix=$(PREFIX) --disable-werror
	@echo done!
	@echo -n "Compiling binutils... "
	@cd build-binutils; make MAKEINFO=makeinfo
	@echo done!
	@echo -n "Installing binutils... "
	@cd build-binutils; make install

compile_install_tools2:
	@echo -e -n "\nOkay, time to do gcc. Configuring... "
	@cd build-gcc; sh ../gcc-4.7.1/configure --target=$(TARGET) --prefix=$(PREFIX) --disable-nls --enable-languages=c,c++ --enable-lto
	@echo done!
	@echo -n "Compiling gcc... "
	@cd build-gcc; make all-gcc -j2
	@echo done!
	@echo -n "Installing gcc... "
	@cd build-gcc; make install-gcc
	@echo done!
	@echo Tools have been installed!

compile_library_full:
	@rm -rf newlib-1.20.0 build-newlib/*
	@make -s patch_newlib
	@echo -n -e "Configuring newlib... "
	@cd build-newlib; ../newlib-1.20.0/configure -q --target=$(TARGET) --prefix=$(PREFIX)
	@echo done!
	@make -s compile_library

compile_library:
	@echo -n "Compiling newlib... "
	@mkdir -p newlib-1.20.0/newlib/libc/sys/seaos/
	@cp -rf newlib-sys-seaos/* newlib-1.20.0/newlib/libc/sys/seaos/
	@cd build-newlib; make
	@echo done!

compile_ncurses:
	@echo "Compiling ncurses..."
	@cd ncurses-5.9/build; ../configure --host=$(TARGET) --target=$(TARGET) --prefix=$(PREFIX)/$(TARGET) --host=$(TARGET) --without-ada --without-cxx-binding --with-terminfo-dirs=/usr/share/terminfo --with-default-terminfo-dir=/usr/share/terminfo
	@cd ncurses-5.9/build; make

install_ncurses:
	@echo "Installing ncurses..."
	@cd ncurses-5.9/build; make install
	@cp ${INSTALL_LOC}/${TARGET}/include/ncurses/* ${INSTALL_LOC}/${TARGET}/include/
	
install_library:
	@echo -n "Installing newlib... "
	@cd build-newlib; PATH=$$PATH:${INSTALL_LOC} make install
	@echo done!

clean:
	@-rm -rf build-gcc build-newlib build-binutils
	@-mkdir build-binutils build-gcc build-newlib
