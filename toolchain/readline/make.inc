NAME=readline
VERSION=6.2

SOURCEDIR=$(NAME)-$(VERSION)
PATCHEDDIR=$(SOURCEDIR)-seaos
REMOTE='ftp://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz'
REMOTEFILE=$(NAME)-$(VERSION).tar.gz
BUILDDIR=build-$(TRIPLET)-$(NAME)-$(VERSION)
PATCHFILE:=readline-$(VERSION)-seaos-all.patch
DEPS=binutils gcc newlib ncurses libgcc

include varfix.mk
build-$(NAME): $(NAME)/$(BUILDDIR) $(NAME)/$(PATCHEDDIR)
	cd $(NAME)/$(BUILDDIR) && \
	../$(PATCHEDDIR)/configure --build=$(BUILD_TRIPLET) --host=$(TRIPLET) --prefix=$(TOOLCHAINDIR)/$(TRIPLET) --disable-shared && \
	$(MAKE) all install

