NAME=gmp
VERSION=5.1.1

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='ftp://ftp.gnu.org/gnu/gmp/gmp-5.1.1.tar.bz2'
REMOTEFILE=$(NAME)-$(VERSION).tar.bz2
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=$(NAME)-$(VERSION)-seaos-all.patch
DEPS=binutils gcc newlib

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --build=$(BUILD_TRIPLET) --host=$(TRIPLET) --prefix=$(DESTDIR)/$(TRIPLET) CC_FOR_BUILD=gcc CXX_FOR_BUILD=g++ && \
	$(MAKE) -j1 all install

