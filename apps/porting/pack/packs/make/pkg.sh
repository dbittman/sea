VERSION=4.0
NAME=make
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.bz2)
SOURCES_HASHES=(571d470a7647b455e3af3f92d79f1c18)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.bz2
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --without-guile --disable-load --disable-nls; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

