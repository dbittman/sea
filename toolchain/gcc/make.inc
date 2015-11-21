NAME:=gcc
VERSION:=5.2.0

TOOLS+=libstdc++
TOOLS+=libgcc

SOURCEDIR:=$(NAME)-$(VERSION)
PATCHEDDIR:=$(SOURCEDIR)-seaos
REMOTE:='ftp://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2'
REMOTEFILE:=$(NAME)-$(VERSION).tar.bz2
BUILDDIR:=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=$(NAME)-$(VERSION)-seaos-all.patch
DEPS=binutils

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	mkdir -p $(SYSROOTDIR)/usr/include && \
	../$(PATCHEDDIR)/configure --target=$(TRIPLET) --prefix=$(TOOLCHAINDIR) --disable-nls --enable-languages=c,c++ --enable-lto --with-sysroot=$(SYSROOTDIR) && \
	$(MAKE) -j1 all-gcc install-gcc
	-rm $(TOOLCHAINDIR)/bin/$(TRIPLET)-cc 2>/dev/null
	-ln -s $(TRIPLET)-gcc $(TOOLCHAINDIR)/bin/$(TRIPLET)-cc 2>/dev/null

build-libgcc: NAME:=$(NAME)
build-libgcc: PATCHEDDIR:=$(PATCHEDDIR)
build-libgcc: BUILDDIR:=$(BUILDDIR)
build-libgcc: PATCHFILE:=$(PATCHFILE)
build-libgcc: $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	$(MAKE) -j1 all-target-libgcc install-target-libgcc


build-libstdc++: NAME:=$(NAME)
build-libstdc++: PATCHEDDIR:=$(PATCHEDDIR)
build-libstdc++: BUILDDIR:=$(BUILDDIR)
build-libstdc++: PATCHFILE:=$(PATCHFILE)
build-libstdc++: $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	$(MAKE) -j1 all install

do-build-libstdc++: NAME:=$(NAME)
do-build-libstdc++: do-build-newlib do-build-binutils do-build-gcc do-build-libgcc
	$(MAKE) build-libstdc++

do-build-libgcc: NAME:=$(NAME)
do-build-libgcc: do-build-newlib do-build-binutils do-build-gcc
	$(MAKE) build-libgcc

