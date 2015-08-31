VERSION=3.2
NAME=diffutils
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.gz)
SOURCES_HASHES=(22e4deef5d8949a727b159d6bc65c1cc)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
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

