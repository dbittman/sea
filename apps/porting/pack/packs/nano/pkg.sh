VERSION=2.4.2
NAME=nano
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://www.nano-editor.org/dist/v2.4/nano-2.4.2.tar.gz)
SOURCES_HASHES=(ce6968992fec4283c17984b53554168b)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --enable-utf8=no CURSES_LIB_NAME=ncurses; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT LIBS=-lncurses all install; then
		return 1
	fi
}

