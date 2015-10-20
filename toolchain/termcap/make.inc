NAME=termcap
VERSION=1.3.1

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='ftp://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz'
REMOTEFILE=$(NAME)-$(VERSION).tar.gz
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=
DEPS=binutils gcc newlib

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --build=$(BUILD_TRIPLET) --host=$(TRIPLET) --prefix=$(TOOLCHAINDIR)/$(TRIPLET) && \
	$(MAKE) CC=$(TRIPLET)-gcc AR=$(TRIPLET)-ar RANLIB=$(TRIPLET)-ranlib all install

