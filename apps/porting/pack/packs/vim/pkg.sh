VERSION=7.4
NAME=vim
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2)
SOURCES_HASHES=(607e135c559be642f210094ad023dc65)
PATCHES=()

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.bz2
	fi
}

function build() {
	cp -rf ../src/vim74/* .
	if ! ./configure --host=$HOST_TRIPLET vim_cv_toupper_broken=no --with-tlib=ncurses vim_cv_terminfo=yes vim_cv_tty_mode=0620 vim_cv_tty_group=world vim_cv_getcwd_broken=no vim_cv_stat_ignores_slash=yes vim_cv_memmove_handles_overlap=yes --disable-sysmouse --disable-gpm --disable-xsmp --disable-xim LIBS="-lm -lncurses" X_PRE_LIBS= --prefix=/usr --disable-nls; then
		return 1
	fi

	sed -i "s/\-lICE//g" src/auto/config.mk
	sed -i "s/\-lSM//g" src/auto/config.mk

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

