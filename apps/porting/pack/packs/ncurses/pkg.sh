VERSION=6.0
NAME=ncurses
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.gz)
SOURCES_HASHES=(ee13d052e1ead260d7c28071f46eefb1)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --oldincludedir=/usr/include --includedir=/usr/include --disable-termcap; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -i all install; then
		return 1
	fi
}

