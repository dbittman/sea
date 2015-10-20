NAME=openssl
VERSION=1.0.1f

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='http://www.openssl.org/source/openssl-1.0.1f.tar.gz'
REMOTEFILE=$(NAME)-$(VERSION).tar.gz
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=$(NAME)-$(VERSION)-seaos-all.patch
DEPS=binutils gcc newlib

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	cp -r ../$(PATCHEDDIR)/* . && \
	../$(PATCHEDDIR)/Configure --prefix=$(DESTDIR)/$(TRIPLET) --openssldir=$(DESTDIR)/$(TRIPLET) no-shared $(TRIPLET) && \
	$(MAKE) build_libs && \
	$(MAKE) -i install_sw

