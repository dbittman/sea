NAME=binutils
VERSION=2.25.1

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='http://ftp.gnu.org/gnu/$(NAME)/$(NAME)-$(VERSION).tar.bz2'
REMOTEFILE=$(NAME)-$(VERSION).tar.bz2
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE=$(NAME)-$(VERSION)-seaos-all.patch
DEPS=

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --target=$(TRIPLET) --prefix=$(TOOLCHAINDIR) --disable-nls --disable-werror --with-sysroot=$(SYSROOTDIR) && \
	MAKEINFO=makeinfo $(MAKE) -j1 all install

