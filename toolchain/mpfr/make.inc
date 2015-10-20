NAME=mpfr
VERSION=3.1.2

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='ftp://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.gz'
REMOTEFILE=$(NAME)-$(VERSION).tar.gz
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=$(NAME)-$(VERSION)-seaos-all.patch
DEPS=binutils gcc newlib gmp

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --build=$(BUILD_TRIPLET) --host=$(TRIPLET) --prefix=$(DESTDIR)/$(TRIPLET) CFLAGS='-fno-stack-protector' && \
	$(MAKE) -j1 all install

