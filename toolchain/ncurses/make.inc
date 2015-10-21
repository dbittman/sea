NAME=ncurses
VERSION=6.0

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz'
REMOTEFILE=$(NAME)-$(VERSION).tar.gz
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=ncurses-$(VERSION)-seaos-all.patch
DEPS=binutils gcc newlib termcap libgcc

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --build=$(BUILD_TRIPLET) --host=$(TRIPLET) --prefix=$(TOOLCHAINDIR)/$(TRIPLET) --includedir=$(TOOLCHAINDIR)/$(TRIPLET)/include --oldincludedir=$(TOOLCHAINDIR)/$(TRIPLET)/include --enable-termcap --disable-database --enable-overwrite && \
	$(MAKE) all install -i

