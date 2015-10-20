NAME=mpc
VERSION=1.0.3

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz'
REMOTEFILE=$(NAME)-$(VERSION).tar.gz
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=$(NAME)-$(VERSION)-seaos-all.patch
DEPS=binutils gcc newlib gmp mpfr

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --build=$(BUILD_TRIPLET) --host=$(TRIPLET) --prefix=$(TOOLCHAINDIR)/$(TRIPLET) && \
	$(MAKE) CC=$(TRIPLET)-gcc AR=$(TRIPLET)-ar LD=$(TRIPLET)-ld CFLAGS="" all install

