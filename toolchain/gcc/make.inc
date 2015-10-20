NAME:=gcc
VERSION:=5.2.0

TOOLS+=libstdc++

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
	../$(PATCHEDDIR)/configure --target=$(TRIPLET) --prefix=$(DESTDIR) --disable-nls --enable-languages=c,c++ --enable-lto && \
	$(MAKE) -j1 all-gcc install-gcc all-target-libgcc install-target-libgcc
	rm $(DESTDIR)/bin/$(TRIPLET)-cc
	-ln -s $(TRIPLET)-gcc $(DESTDIR)/bin/$(TRIPLET)-cc 2>/dev/null

build-libstdc++: NAME:=$(NAME)
build-libstdc++: PATCHEDDIR:=$(PATCHEDDIR)
build-libstdc++: BUILDDIR:=$(BUILDDIR)
build-libstdc++: PATCHFILE:=$(PATCHFILE)
build-libstdc++: $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	$(MAKE) -j1 all install

do-build-libstdc++: NAME:=$(NAME)
do-build-libstdc++: do-build-newlib do-build-binutils do-build-gcc
	$(MAKE) build-libstdc++

