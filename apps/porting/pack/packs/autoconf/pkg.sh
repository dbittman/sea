VERSION=2.69
NAME=autoconf
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.xz)
SOURCES_HASHES=(50f97f4159805e374639a73e2636f22e)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.xz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j$INDIV_PARALLEL all install; then
		return 1
	fi
}

