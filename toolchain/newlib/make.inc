NAME=newlib
VERSION=2.0.0

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz'
REMOTEFILE=$(NAME)-$(VERSION).tar.gz
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE=$(NAME)-$(VERSION)-seaos-all.patch
DEPS=binutils gcc

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --target=$(TRIPLET) --prefix=/usr && \
	$(MAKE) -j1 DESTDIR=$(SYSROOTDIR) all install && \
	cp -ar $(SYSROOTDIR)/usr/$(TRIPLET)/* $(SYSROOTDIR)/usr/

